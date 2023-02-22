import 'dart:ui';

import 'package:ai_pencil/drawing_canvas/models/undo_redo_stack.dart';
import 'package:ai_pencil/drawing_canvas/widgets/drawing_tools.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:ai_pencil/drawing_canvas/drawing_canvas.dart';
import 'package:ai_pencil/drawing_canvas/models/drawing_mode.dart';
import 'package:ai_pencil/drawing_canvas/models/sketch.dart';
import 'package:ai_pencil/drawing_canvas/widgets/canvas_side_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawScreen extends HookWidget {
  const DrawScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: Inputs to pass into widget
    const aspectRatio = 16 / 9;

    // Drawing tools state
    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(10);
    final eraserSize = useState<double>(30);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);
    final backgroundImage = useState<Image?>(null);

    final canvasGlobalKey = GlobalKey();

    ValueNotifier<Sketch?> currentSketch = useState(null);
    ValueNotifier<List<Sketch>> allSketches = useState([]);

    ValueNotifier<bool> sliderModalVisible = useState<bool>(false);

    final undoRedoStack = useState(UndoRedoStack(
      sketchesNotifier: allSketches,
      currentSketchNotifier: currentSketch,
    ));

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );

    Widget getSizeSlider() {
      if (drawingMode.value == DrawingMode.pencil ||
          drawingMode.value == DrawingMode.line) {
        return Slider(
          value: strokeSize.value,
          min: 0,
          max: 50,
          onChanged: (val) {
            strokeSize.value = val;
          },
          onChangeStart: (value) {
            sliderModalVisible.value = true;
          },
          onChangeEnd: (value) {
            sliderModalVisible.value = false;
          },
        );
      } else if (drawingMode.value == DrawingMode.eraser) {
        return Slider(
          value: eraserSize.value,
          min: 0,
          max: 80,
          onChanged: (val) {
            eraserSize.value = val;
          },
        );
      }
      return Slider(
        value: strokeSize.value,
        min: 0,
        max: 50,
        onChanged: (val) {
          strokeSize.value = val;
        },
      );
    }

    var trailingActions = [
      TextButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return CanvasSideBar(
                drawingMode: drawingMode,
                selectedColor: selectedColor,
                strokeSize: strokeSize,
                eraserSize: eraserSize,
                currentSketch: currentSketch,
                allSketches: allSketches,
                canvasGlobalKey: canvasGlobalKey,
                filled: filled,
                polygonSides: polygonSides,
                backgroundImage: backgroundImage,
              );
            },
          );
        },
        child: const Text(
          "Tools",
        ),
      ),
      TextButton(
        onPressed: () {},
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
          width: 100.0,
          height: 100.0,
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
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Size ${strokeSize.value.round()}"),
                Expanded(
                  child: Container(
                    width: strokeSize.value,
                    height: strokeSize.value,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(FontAwesomeIcons.image),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(FontAwesomeIcons.arrowUpFromBracket),
            ),
          ],
        ),
        actions: trailingActions,
      ),
      bottomNavigationBar: DrawingToolBar(
          allSketches: allSketches,
          undoRedoStack: undoRedoStack,
          drawingMode: drawingMode,
          selectedColor: selectedColor),
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
              bottom: 0,
              child: Row(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Size',
                        style: TextStyle(fontSize: 12),
                      ),
                      getSizeSlider(),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        'Opacity',
                        style: TextStyle(fontSize: 12),
                      ),
                      Slider(
                        value: eraserSize.value,
                        min: 0,
                        max: 80,
                        onChanged: (val) {
                          eraserSize.value = val;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
