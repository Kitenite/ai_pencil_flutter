import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ai_pencil/drawing_canvas/models/slider_type.dart';
import 'package:ai_pencil/drawing_canvas/models/undo_redo_stack.dart';
import 'package:ai_pencil/drawing_canvas/widgets/drawing_tools.dart';
import 'package:ai_pencil/drawing_canvas/widgets/icon_box.dart';
import 'package:ai_pencil/model/drawing_layer.dart';
import 'package:ai_pencil/model/drawing_project.dart';
import 'package:ai_pencil/screens/inference_screen.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:ai_pencil/drawing_canvas/drawing_canvas.dart';
import 'package:ai_pencil/drawing_canvas/models/drawing_mode.dart';
import 'package:ai_pencil/drawing_canvas/models/sketch.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class DrawScreen extends HookWidget {
  final DrawingProject project;
  final int projectIndex;
  final double aspectRatio;
  const DrawScreen({
    Key? key,
    required this.project,
    required this.projectIndex,
    this.aspectRatio = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Add paint tool
    // TODO: Add lines and shapes tool
    // TODO: Eraser undo takes 2 clicks

    // Drawing tools state
    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(10);
    final eraserSize = useState<double>(30);
    final strokeOpacity = useState<double>(1);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);
    final backgroundImage = useState<ui.Image?>(null);
    final canvasGlobalKey = GlobalKey();

    ValueNotifier<Sketch?> currentSketch = useState(null);
    ValueNotifier<List<Sketch>> allSketches =
        useState(project.layers[project.activeLayerIndex].sketches);
    ValueNotifier<bool> sliderModalVisible = useState<bool>(false);
    ValueNotifier<SliderType> activeSlider =
        useState<SliderType>(SliderType.pencilSize);

    final undoRedoStack = useState(UndoRedoStack(
      sketchesNotifier: allSketches,
      currentSketchNotifier: currentSketch,
    ));

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );

    void saveProject() async {
      // TODO: this logic should be a callback passed by select project screen
      var prefs = await SharedPreferences.getInstance();
      var updatedProject = DrawingProject(
        title: project.title,
        layers: [
          DrawingLayer(
            sketches: allSketches.value,
          ),
        ],
        activeLayerIndex: 0,
      );
      var projects = prefs.getStringList('projects') ?? [];
      projects[projectIndex] = jsonEncode(updatedProject.toJson());
      prefs.setStringList('projects', projects);
    }

    Widget getSizeSlider() {
      double value = strokeSize.value;
      double minValue = 0;
      double maxValue = 80;
      SliderType type = SliderType.pencilSize;
      var onChanged = (val) => {strokeSize.value = val};

      switch (drawingMode.value) {
        case DrawingMode.pencil:
          onChanged = (val) => {strokeSize.value = val};
          type = SliderType.pencilSize;
          break;

        case DrawingMode.eraser:
          value = eraserSize.value;
          onChanged = (val) => {eraserSize.value = val};
          type = SliderType.eraser;
          break;
        default:
          break;
      }
      return Slider(
        value: value,
        min: minValue,
        max: maxValue,
        onChanged: onChanged,
        onChangeStart: (value) {
          activeSlider.value = type;
          sliderModalVisible.value = true;
        },
        onChangeEnd: (value) {
          sliderModalVisible.value = false;
        },
      );
    }

    Widget getSliderPreviewModal() {
      String modalText = "Size ${strokeSize.value.round()}";
      double previewSize = strokeSize.value;
      Color previewColor = Colors.white;

      switch (activeSlider.value) {
        case SliderType.eraser:
          modalText = "Size ${eraserSize.value.round()}";
          previewSize = eraserSize.value;
          break;
        case SliderType.opacity:
          modalText = "Opacity ${(strokeOpacity.value * 100).round()}%";
          previewSize = 50;
          previewColor = previewColor.withOpacity(strokeOpacity.value);
          break;
        default:
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
                  color: Colors.white.withOpacity(strokeOpacity.value),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Future<ui.Image> getImage() async {
      final completer = Completer<ui.Image>();
      if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
        final file = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (file != null) {
          final filePath = file.files.single.path;
          final bytes = filePath == null
              ? file.files.first.bytes
              : File(filePath).readAsBytesSync();
          if (bytes != null) {
            completer.complete(decodeImageFromList(bytes));
          } else {
            completer.completeError('No image selected');
          }
        }
      } else {
        final image =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image != null) {
          final bytes = await image.readAsBytes();
          completer.complete(
            decodeImageFromList(bytes),
          );
        } else {
          completer.completeError('No image selected');
        }
      }

      return completer.future;
    }

    Future<Uint8List?> getBytes() async {
      RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? pngBytes = byteData?.buffer.asUint8List();
      return pngBytes;
    }

    void saveFile(Uint8List bytes, String extension) async {
      if (kIsWeb) {
        html.AnchorElement()
          ..href = '${Uri.dataFromBytes(bytes, mimeType: 'image/$extension')}'
          ..download =
              'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension'
          ..style.display = 'none'
          ..click();
      } else {
        await FileSaver.instance.saveFile(
          'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension',
          bytes,
          extension,
          mimeType: extension == 'png' ? MimeType.PNG : MimeType.JPEG,
        );
      }
    }

    var trailingActions = [
      TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InferenceScreen()),
          );
        },
        child: const Text(
          "AI",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];

    var sliderModal = IgnorePointer(
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
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          saveProject();
          Navigator.pop(context);
        }),
        title: Row(
          children: [
            IconBox(
              iconData: FontAwesomeIcons.image,
              selected: true,
              onTap: () async {
                if (backgroundImage.value != null) {
                  backgroundImage.value = null;
                } else {
                  backgroundImage.value = await getImage();
                }
              },
              tooltip: 'Add image',
            ),
            IconBox(
              iconData: FontAwesomeIcons.download,
              selected: true,
              onTap: () async {
                const snackBar = SnackBar(
                  content: Text('Drawing saved'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Uint8List? pngBytes = await getBytes();
                if (pngBytes != null) saveFile(pngBytes, 'png');
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
        drawingMode: drawingMode,
        selectedColor: selectedColor,
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
              panEnabled: drawingMode.value == DrawingMode.pan,
              scaleEnabled: drawingMode.value == DrawingMode.pan,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: DrawingCanvas(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        drawingMode: drawingMode,
                        selectedColor: selectedColor,
                        strokeSize: strokeSize,
                        eraserSize: eraserSize,
                        strokeOpacity: strokeOpacity,
                        sideBarController: animationController,
                        currentSketch: currentSketch,
                        allSketches: allSketches,
                        canvasGlobalKey: canvasGlobalKey,
                        filled: filled,
                        polygonSides: polygonSides,
                        backgroundImage: backgroundImage,
                      ),
                    ),
                  )),
            ),
            sliderModal,
            Positioned(
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
                        getSizeSlider(),
                        Slider(
                          value: strokeOpacity.value,
                          min: 0,
                          max: 1,
                          onChanged: (val) {
                            strokeOpacity.value = val;
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
            ),
          ],
        ),
      ),
    );
  }
}
