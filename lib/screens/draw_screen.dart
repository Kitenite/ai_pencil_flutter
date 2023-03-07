import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ai_pencil/model/drawing_canvas/slider_type.dart';
import 'package:ai_pencil/model/drawing_canvas/undo_redo_stack.dart';
import 'package:ai_pencil/model/image/types.dart';
import 'package:ai_pencil/screens/inference_complete_screen.dart';
import 'package:ai_pencil/utils/image_helpers.dart';
import 'package:ai_pencil/utils/snackbar.dart';
import 'package:ai_pencil/widgets/drawing_canvas/drawing_canvas.dart';
import 'package:ai_pencil/widgets/drawing_canvas/icon_box.dart';
import 'package:ai_pencil/widgets/drawing_tool_bar.dart';
import 'package:ai_pencil/model/drawing/drawing_layer.dart';
import 'package:ai_pencil/model/drawing/drawing_project.dart';
import 'package:ai_pencil/model/drawing/drawing_tools.dart';
import 'package:ai_pencil/screens/inference_screen.dart';
import 'package:ai_pencil/screens/layer_popover.dart';
import 'package:flutter/material.dart';
import 'package:ai_pencil/model/drawing_canvas/drawing_mode.dart';
import 'package:ai_pencil/model/drawing_canvas/sketch.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';
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
    // TODO: Add lines and shapes tool
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

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );

    final isGeneratingImage = useState(false);

    void onImageGenerationStarted(Future<Uint8List> imageBytesFuture) {
      isGeneratingImage.value = true;
      imageBytesFuture.then((imageBytes) {
        isGeneratingImage.value = false;

        // TODO: Handle this later
        //   Navigator.push(
        // context,
        // MaterialPageRoute(
        //   builder: (context) => InferenceCompleteScreen(
        //     imageBytes: imageBytes,
        //   ),
        // );

        // showModalBottomSheet(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return SizedBox(
        //       height: 300,
        //       child: Center(
        //         child: Image.memory(imageBytes),
        //       ),
        //     );
        //   },
        // );
      }).catchError((error) {
        isGeneratingImage.value = false;
        Logger("DrawScreen").severe("Error generating image: $error");
      });
    }

    void saveActiveLayer() {
      if (activeLayerIndex.value >= layers.value.length) {
        return;
      }
      List<DrawingLayer> tempLayers = layers.value;
      tempLayers[activeLayerIndex.value].sketches = allSketches.value;
      tempLayers[activeLayerIndex.value]
          .updateImage(canvasGlobalKey.currentContext?.size);
      layers.value = layers.value.toList(); // notify listeners of change
    }

    Future<PngImageBytes?> getThumbnailImageBytes() {
      Size? drawingSize = ImageHelper.getDrawingSize(canvasGlobalKey);
      if (drawingSize == null) {
        Logger("DrawScreen::getThumbnailImage")
            .severe("Error getting drawing size");
        SnackBarHelper.showSnackBar(
            context, 'Something went wrong, please try again');
      }
      return ImageHelper.getDrawingAsPngBytes(
          layers.value, drawingSize, backgroundColor.value);
    }

    Future<void> persistProject() async {
      // TODO: this logic should be a callback passed by select project screen
      // saveActiveLayer(); // Already done on drawing changed. Shouldn't call in async anyway
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

    void addLayer() {
      var newLayerIndex = layers.value.length;
      layers.value = [
        ...layers.value,
        DrawingLayer(
          title: "Layer ${newLayerIndex + 1}",
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

    // TODO: add rename button to layer tile
    void renameLayer(int idx, String title) {
      layers.value[idx].title = title;
      layers.value = layers.value.toList(); // notify listeners of change
    }

    Widget getSliderPreviewModal() {
      String modalText = "Size ${drawingTools.getStrokeSize().round()}";
      double previewSize = drawingTools.getStrokeSize();
      Color previewColor = Colors.white;

      switch (activeSlider.value) {
        case SliderType.strokeSize:
          modalText = "Size ${drawingTools.getStrokeSize().round()}";
          previewSize = drawingTools.getStrokeSize();
          break;
        case SliderType.opacity:
          modalText = "Opacity ${(drawingTools.getOpacity() * 100).round()}%";
          previewSize = 50;
          previewColor = previewColor.withOpacity(drawingTools.getOpacity());
          break;
      }

      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(modalText),
            Expanded(
              child: Container(
                width: previewSize,
                height: previewSize,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(drawingTools.getOpacity()),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }

    void navigateToInferenceScreen() {
      getThumbnailImageBytes().then((imageByte) {
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

    var sliderPreviewModal = IgnorePointer(
      child: AnimatedOpacity(
        opacity: sliderModalVisible.value ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 150.0,
          height: 150.0,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.black87,
            border: Border.all(
              width: 3,
              color: Colors.black,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: getSliderPreviewModal(),
        ),
      ),
    );

    var slidersContainer = Positioned(
      bottom: -4,
      child: AnimatedOpacity(
        opacity: sliderModalVisible.value ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 300),
        child: Card(
          color: Colors.black54,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Slider(
                  value: drawingTools.getStrokeSize(),
                  min: drawingTools.getMinStrokeSize(),
                  max: drawingTools.getMaxStrokeSize(),
                  onChanged: (val) {
                    drawingTools.setStrokeSize(val);
                  },
                  onChangeStart: (value) {
                    activeSlider.value = SliderType.strokeSize;
                    sliderModalVisible.value = true;
                  },
                  onChangeEnd: (value) {
                    sliderModalVisible.value = false;
                  },
                ),
                Slider(
                  value: drawingTools.getOpacity(),
                  min: 0,
                  max: 1,
                  onChanged: (val) {
                    drawingTools.setOpacity(val);
                  },
                  onChangeStart: (value) {
                    activeSlider.value = SliderType.opacity;
                    sliderModalVisible.value = true;
                  },
                  onChangeEnd: (value) {
                    sliderModalVisible.value = false;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    var gridBackground = GridPaper(
      color: const Color.fromARGB(10, 255, 255, 255),
      interval: 30,
      divisions: 1,
      subdivisions: 1,
      child: Container(),
    );

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () {
            getThumbnailImageBytes().then((imageByte) {
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
                onTap: () async {
                  backgroundImage.value = await ImageHelper.getImageFromDevice(
                    project.aspectWidth,
                    project.aspectHeight,
                    context,
                  );
                },
                tooltip: 'Add image',
              ),
              IconBox(
                iconData: FontAwesomeIcons.download,
                selected: true,
                onTap: () {
                  SnackBarHelper.showSnackBar(context, 'Drawing saved');
                  ImageHelper.downloadDrawingImage(
                    layers.value,
                    ImageHelper.getDrawingSize(canvasGlobalKey),
                    backgroundColor.value,
                  );
                },
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
              gridBackground,
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
                                  sideBarController: animationController,
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
              sliderPreviewModal,
              slidersContainer,
            ],
          ),
        ),
      ),
    );
  }
}
