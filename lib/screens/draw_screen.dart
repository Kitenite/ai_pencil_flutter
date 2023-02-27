import 'dart:convert';
import 'dart:ui' as ui;

import 'package:ai_pencil/drawing_canvas/models/slider_type.dart';
import 'package:ai_pencil/drawing_canvas/models/undo_redo_stack.dart';
import 'package:ai_pencil/drawing_canvas/utils/image_helpers.dart';
import 'package:ai_pencil/drawing_canvas/widgets/drawing_tools.dart';
import 'package:ai_pencil/drawing_canvas/widgets/icon_box.dart';
import 'package:ai_pencil/model/drawing_layer.dart';
import 'package:ai_pencil/model/drawing_project.dart';
import 'package:ai_pencil/model/drawing_tools.dart';
import 'package:ai_pencil/screens/inference_screen.dart';
import 'package:flutter/material.dart';
import 'package:ai_pencil/drawing_canvas/drawing_canvas.dart';
import 'package:ai_pencil/drawing_canvas/models/drawing_mode.dart';
import 'package:ai_pencil/drawing_canvas/models/sketch.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    final canvasGlobalKey = GlobalKey();

    // Canvas sketches
    ValueNotifier<Sketch?> currentSketch = useState(null);
    ValueNotifier<List<Sketch>> allSketches =
        useState(project.layers[project.activeLayerIndex].sketches);

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

    var trailingActions = [
      TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InferenceScreen(
                project: project,
                canvasGlobalKey: canvasGlobalKey,
              ),
            ),
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
              onTap: () async {
                const snackBar = SnackBar(
                  content: Text('Drawing saved'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                ImageHelper.downloadCanvasImage(canvasGlobalKey);
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
              scaleEnabled: drawingTools.drawingMode.value == DrawingMode.pan,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: project.aspectWidth / project.aspectHeight,
                      child: DrawingCanvas(
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
                      ),
                    ),
                  )),
            ),
            sliderPreviewModal,
            slidersContainer,
          ],
        ),
      ),
    );
  }
}
