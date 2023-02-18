import 'dart:ui';

import 'package:ai_pencil/constants.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:ai_pencil/drawing_canvas/drawing_canvas.dart';
import 'package:ai_pencil/drawing_canvas/models/drawing_mode.dart';
import 'package:ai_pencil/drawing_canvas/models/sketch.dart';
import 'package:ai_pencil/drawing_canvas/widgets/canvas_side_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DrawScreen extends HookWidget {
  const DrawScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
              icon: Icon(Icons.photo_outlined),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.ios_share),
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
          AspectRatio(
            aspectRatio: 1,
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
        ]),
      ),
    );
  }
}
