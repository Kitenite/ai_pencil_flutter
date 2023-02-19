import 'dart:math';
import 'dart:ui';

import 'package:ai_pencil/drawing_canvas/widgets/icon_box.dart';
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

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );

    var trailingActions = [
      IconBox(
        iconData: FontAwesomeIcons.upDownLeftRight,
        selected: drawingMode.value == DrawingMode.pan,
        onTap: () => drawingMode.value = DrawingMode.pan,
        tooltip: 'Pan',
      ),
      IconBox(
        iconData: FontAwesomeIcons.eraser,
        selected: drawingMode.value == DrawingMode.eraser,
        onTap: () => drawingMode.value = DrawingMode.eraser,
        tooltip: 'Eraser',
      ),
      IconBox(
        iconData: FontAwesomeIcons.pencil,
        selected: drawingMode.value == DrawingMode.pencil,
        onTap: () => drawingMode.value = DrawingMode.pencil,
        tooltip: 'Pencil',
      ),
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
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: [
          GridPaper(
            color: const Color.fromARGB(10, 255, 255, 255),
            interval: 30,
            divisions: 1,
            subdivisions: 1,
            child: Container(),
          ),
          InteractiveViewer(
            // TODO: Enable interaction option only during pan mode
            constrained: true,
            boundaryMargin: const EdgeInsets.all(1000.0),
            minScale: 0.01,
            maxScale: 10,
            panEnabled: drawingMode.value == DrawingMode.pan,
            scaleEnabled: drawingMode.value == DrawingMode.pan,
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: DrawingCanvas(
                  width: min(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  ),
                  height: min(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  ),
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
                )),
          ),
        ]),
      ),
    );
  }
}
