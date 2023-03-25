import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ai_pencil/model/drawing_canvas/slider_type.dart';
import 'package:ai_pencil/model/drawing_canvas/undo_redo_stack.dart';
import 'package:ai_pencil/model/image/types.dart';
import 'package:ai_pencil/screens/inference_complete_screen.dart';
import 'package:ai_pencil/utils/dialog_helper.dart';
import 'package:ai_pencil/utils/event_analytics.dart';
import 'package:ai_pencil/utils/image_helpers.dart';
import 'package:ai_pencil/utils/snackbar.dart';
import 'package:ai_pencil/widgets/drawing_canvas/drawing_canvas.dart';
import 'package:ai_pencil/widgets/draw_screen/icon_box.dart';
import 'package:ai_pencil/widgets/draw_screen/slider_preview_modal.dart';
import 'package:ai_pencil/widgets/draw_screen/drawing_tool_bar.dart';
import 'package:ai_pencil/model/drawing/drawing_layer.dart';
import 'package:ai_pencil/model/drawing/drawing_project.dart';
import 'package:ai_pencil/model/drawing/drawing_tools.dart';
import 'package:ai_pencil/screens/inference_screen.dart';
import 'package:ai_pencil/screens/layer_popover.dart';
import 'package:ai_pencil/widgets/draw_screen/tools_sliders.dart';
import 'package:flutter/material.dart';
import 'package:ai_pencil/model/drawing_canvas/drawing_mode.dart';
import 'package:ai_pencil/model/drawing_canvas/sketch.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawScreen extends HookWidget {
  final DrawingProject project;
  final int projectIndex;

  const DrawScreen({
    Key? key,
    required this.project,
    required this.projectIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Add lines and shapes tool?
    // TODO: Eraser undo takes 2 clicks

    final drawingTools = DrawingTools();
    // Unused - Polygon mode
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);

    final backgroundImage = useState<ui.Image?>(null);
    final backgroundColor = useState<Color>(Color(project.backgroundColor));
    final canvasGlobalKey = GlobalKey();

    // Canvas sketches
    ValueNotifier<Sketch?> currentSketch = useState(null);
    ValueNotifier<List<Sketch>> allSketches =
        useState(project.layers[project.activeLayerIndex].sketches);
    ValueNotifier<int> activeLayerIndex = useState(project.activeLayerIndex);
    ValueNotifier<List<DrawingLayer>> layers = useState(project.layers);

    // Sliders
    final sliderModalVisible = useState<bool>(false);
    final activeSlider = useState<SliderType>(SliderType.strokeSize);

    final undoRedoStack = useState(UndoRedoStack(
      sketchesNotifier: allSketches,
      currentSketchNotifier: currentSketch,
    ));

    final isGeneratingImage = useState(false);

    void saveActiveLayer() {
      if (activeLayerIndex.value >= layers.value.length) {
        return;
      }
      List<DrawingLayer> tempLayers = layers.value;
      tempLayers[activeLayerIndex.value].sketches = allSketches.value;
      tempLayers[activeLayerIndex.value]
          .updateImage(canvasGlobalKey.currentContext?.size);
      layers.value = tempLayers.toList(); // notify listeners of change
    }

    void updateBackgroundImage() async {
      Uint8List? activeBackgroundImage =
          layers.value[activeLayerIndex.value].backgroundImage;
      if (activeBackgroundImage != null) {
        backgroundImage.value =
            await decodeImageFromList(activeBackgroundImage);
      } else {
        backgroundImage.value = null;
      }
      saveActiveLayer();
    }

    useEffect(() {
      updateBackgroundImage();
      return null;
    }, []);

    Future<void> persistProject() async {
      // TODO: this logic should be a callback passed by select project screen
      // TODO: Add prompt
      var prefs = await SharedPreferences.getInstance();
      var updatedProject = DrawingProject(
        title: project.title,
        layers: layers.value,
        activeLayerIndex: activeLayerIndex.value,
        aspectWidth: project.aspectWidth,
        aspectHeight: project.aspectHeight,
        advancedOptions: project.advancedOptions,
        prompt: project.prompt,
        backgroundColor: backgroundColor.value.value,
        thumbnailImageBytes: project.thumbnailImageBytes,
      );
      var projects = prefs.getStringList('projects') ?? [];
      projects[projectIndex] = jsonEncode(updatedProject.toJson());
      prefs.setStringList('projects', projects);
    }

    void selectLayer(int idx) {
      activeLayerIndex.value = idx;
      allSketches.value = layers.value[idx].sketches;
      layers.value[activeLayerIndex.value].isVisible = true;
      layers.value = layers.value.toList(); // notify listeners of change
      updateBackgroundImage();
    }

    void saveThenSelectLayer(int idx) {
      saveActiveLayer();
      selectLayer(idx);
    }

    void moveLayer(int oldIndex, int newIndex) {
      saveActiveLayer();
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      if (oldIndex == activeLayerIndex.value) {
        activeLayerIndex.value = newIndex;
      } else if (oldIndex > activeLayerIndex.value &&
          newIndex <= activeLayerIndex.value) {
        activeLayerIndex.value += 1;
      } else if (oldIndex < activeLayerIndex.value &&
          newIndex >= activeLayerIndex.value) {
        activeLayerIndex.value -= 1;
      }
      var layer = layers.value.removeAt(oldIndex);
      layers.value.insert(newIndex, layer);
      layers.value = layers.value.toList(); // notify listeners of change
    }

    void addLayer(String? title) {
      var newLayerIndex = layers.value.length;
      layers.value = [
        ...layers.value,
        DrawingLayer(
          title: title ?? "Layer ${newLayerIndex + 1}",
        )
      ];
      saveThenSelectLayer(newLayerIndex);
    }

    void removeLayer(int idx) {
      if (layers.value.length == 1) {
        // Can't remove the last layer
        return;
      }
      layers.value.removeAt(idx);
      if (idx < activeLayerIndex.value) {
        activeLayerIndex.value -= 1;
      } else if (idx == activeLayerIndex.value) {
        selectLayer(0);
      }
      layers.value = layers.value.toList(); // notify listeners of change
    }

    void addImageAsLayer(Uint8List imageBytes, String? title) {
      addLayer(title);
      layers.value[activeLayerIndex.value].backgroundImage = imageBytes;
      updateBackgroundImage();
    }

    void cropThenAddImageAsLayer(Uint8List imageBytes, String? title) async {
      PngImageBytes? croppedImage = await ImageHelper.cropImageFromBytes(
          imageBytes, project.aspectWidth, project.aspectHeight, context);
      if (croppedImage != null) {
        addImageAsLayer(croppedImage, title);
      } else {
        Logger("DrawScreen::cropThenAddImageAsLayer")
            .warning("Error cropping image, using original");
        addImageAsLayer(imageBytes, title);
      }
    }

    void updateBackgroundColor(Color color) {
      backgroundColor.value = color;
      layers.value = layers.value.toList(); // notify listeners of change
    }

    void toggleLayerVisibility(int idx) {
      if (idx != activeLayerIndex.value) {
        layers.value[idx].isVisible = !layers.value[idx].isVisible;
        layers.value = layers.value.toList(); // notify listeners of change
      }
    }

    void renameLayer(int idx, String title) {
      layers.value[idx].title = title;
      layers.value = layers.value.toList(); // notify listeners of change
    }

    void onImageGenerationStarted(
        Future<Uint8List> imageBytesFuture, String prompt) {
      isGeneratingImage.value = true;
      project.prompt = prompt;
      imageBytesFuture.then((imageBytes) {
        MixPanelAnalyticsManager().trackEvent("Image generated", {});
        isGeneratingImage.value = false;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InferenceCompleteScreen(
              imageBytes: imageBytes,
              prompt: prompt,
              onAddImageAsLayer: cropThenAddImageAsLayer,
              onRetryInference: (val) {},
            ),
          ),
        );
      }).catchError((error) {
        MixPanelAnalyticsManager().trackEvent("Image generation failed", {});
        isGeneratingImage.value = false;
        Logger("DrawScreen").severe("Error creating image: $error");
        DialogHelper.showInfoDialog(
            context, "Error creating image", "$error", "Ok");
      });
    }

    void navigateToInferenceScreen() {
      saveActiveLayer();
      ImageHelper.getCanvasScreenshot(
          layers.value,
          ImageHelper.getDrawingSize(canvasGlobalKey)!,
          backgroundColor.value, (imageByte) {
        project.thumbnailImageBytes = imageByte;
        persistProject();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InferenceScreen(
              project: project,
              onImageGenerationStarted: onImageGenerationStarted,
            ),
          ),
        );
      });
    }

    Widget getInferenceButton() {
      if (isGeneratingImage.value) {
        // TODO: Add timer to indicator
        return const Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }
      return TextButton(
        onPressed: navigateToInferenceScreen,
        child: const Text(
          "AI",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    var trailingActions = [
      IconButton(
        icon: const Icon(
          FontAwesomeIcons.layerGroup,
          size: 18,
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => LayerPopover(
              layers: layers,
              activeLayerIndex: activeLayerIndex,
              onSelectLayer: saveThenSelectLayer,
              onMoveLayer: moveLayer,
              onAddLayer: addLayer,
              onRemoveLayer: removeLayer,
              onRenameLayer: renameLayer,
              onToggleLayerVisibility: toggleLayerVisibility,
              onUpdateBackgroundColor: updateBackgroundColor,
              backgroundColor: backgroundColor,
            ),
          );
        },
      ),
      getInferenceButton(),
    ];

    void addImageFromDevice() async {
      Uint8List imageBytes = await ImageHelper.getImageFromDevice(
        project.aspectWidth,
        project.aspectHeight,
        context,
      );
      addImageAsLayer(imageBytes, "Imported image");
    }

    void onAddImageButtonPressed() {
      Permission.photos.status.then((status) {
        if (status.isGranted) {
          addImageFromDevice();
        } else {
          Permission.photos.request().then((status) {
            if (status.isGranted) {
              addImageFromDevice();
            } else {
              DialogHelper.showInfoDialog(context, "Failed to import image",
                  "Please allow access to photos.", "OK");
            }
          });
        }
      });
    }

    void downloadImageToDevice() {
      MixPanelAnalyticsManager().trackEvent("Download image to device", {});
      SnackBarHelper.showSnackBar(context, 'Drawing saved');
      ImageHelper.downloadDrawingImage(
        layers.value,
        ImageHelper.getDrawingSize(canvasGlobalKey),
        backgroundColor.value,
        layers.value[activeLayerIndex.value].backgroundImage,
      );
    }

    void onDownloadImageButtonPressed() {
      Permission.photos.status.then((status) {
        if (status.isGranted) {
          downloadImageToDevice();
        } else {
          Permission.photos.request().then((status) {
            if (status.isGranted) {
              downloadImageToDevice();
            } else {
              DialogHelper.showInfoDialog(context, "Failed to download image",
                  "Please allow access to photos.", "OK");
            }
          });
        }
      });
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () {
            ImageHelper.getCanvasScreenshot(
                layers.value,
                ImageHelper.getDrawingSize(canvasGlobalKey)!,
                backgroundColor.value, (imageByte) {
              project.thumbnailImageBytes = imageByte;
              persistProject();
              Navigator.pop(context);
            });
          }),
          title: Row(
            children: [
              IconBox(
                iconData: FontAwesomeIcons.image,
                selected: true,
                onTap: onAddImageButtonPressed,
                tooltip: 'Add image',
              ),
              IconBox(
                iconData: FontAwesomeIcons.download,
                selected: true,
                onTap: onDownloadImageButtonPressed,
                tooltip: 'Download image',
              ),
            ],
          ),
          actions: trailingActions,
        ),
        bottomNavigationBar: DrawingToolBar(
          allSketches: allSketches,
          undoRedoStack: undoRedoStack,
          drawingMode: drawingTools.drawingMode,
          selectedColor: drawingTools.getSelectedColorNotifier(),
          colorHistory: drawingTools.colorHistory,
          drawingTools: drawingTools,
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GridPaper(
                color: const Color.fromARGB(10, 255, 255, 255),
                interval: 30,
                divisions: 1,
                subdivisions: 1,
                child: Container(),
              ),
              InteractiveViewer(
                  constrained: true,
                  boundaryMargin: const EdgeInsets.all(1000.0),
                  minScale: 0.01,
                  maxScale: 10,
                  panEnabled: drawingTools.drawingMode.value == DrawingMode.pan,
                  scaleEnabled:
                      drawingTools.drawingMode.value == DrawingMode.pan,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                        child: AspectRatio(
                            aspectRatio:
                                project.aspectWidth / project.aspectHeight,
                            child: Container(
                              color: backgroundColor.value,
                              child: Stack(children: [
                                SizedBox(
                                    child: IgnorePointer(
                                        child: Stack(
                                  children: layers.value
                                      .take(activeLayerIndex.value)
                                      .map((layer) {
                                    var imageBytes = layer.getImagePngBytes();
                                    if (layer ==
                                            layers.value[
                                                activeLayerIndex.value] ||
                                        !layer.isVisible ||
                                        imageBytes.isEmpty) {
                                      return Container();
                                    } else {
                                      return Image.memory(
                                        imageBytes,
                                      );
                                    }
                                  }).toList(),
                                ))),
                                DrawingCanvas(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  drawingTools: drawingTools,
                                  currentSketch: currentSketch,
                                  allSketches: allSketches,
                                  canvasGlobalKey: canvasGlobalKey,
                                  filled: filled,
                                  polygonSides: polygonSides,
                                  backgroundImage: backgroundImage,
                                  saveActiveLayer: saveActiveLayer,
                                ),
                                SizedBox(
                                    child: IgnorePointer(
                                        child: Stack(
                                  children: layers.value
                                      .skip(activeLayerIndex.value)
                                      .map((layer) {
                                    var imageBytes = layer.getImagePngBytes();
                                    if (layer ==
                                            layers.value[
                                                activeLayerIndex.value] ||
                                        !layer.isVisible ||
                                        imageBytes.isEmpty) {
                                      return Container();
                                    } else {
                                      return Image.memory(
                                        imageBytes,
                                      );
                                    }
                                  }).toList(),
                                )))
                              ]),
                            ))),
                  )),
              SliderPreviewModal(
                sliderModalVisible: sliderModalVisible,
                drawingTools: drawingTools,
                activeSlider: activeSlider,
              ),
              Positioned(
                bottom: -4,
                child: ToolsSliders(
                  sliderModalVisible: sliderModalVisible,
                  drawingTools: drawingTools,
                  activeSlider: activeSlider,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
