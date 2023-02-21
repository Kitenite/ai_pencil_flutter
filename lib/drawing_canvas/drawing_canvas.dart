import 'dart:ui';

import 'package:ai_pencil/constants.dart';
import 'package:ai_pencil/drawing_canvas/widgets/sketch_painter.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:ai_pencil/drawing_canvas/models/drawing_mode.dart';
import 'package:ai_pencil/drawing_canvas/models/sketch.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DrawingCanvas extends HookWidget {
  final double height;
  final double width;
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<Image?> backgroundImage;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingMode> drawingMode;
  final AnimationController sideBarController;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<int> polygonSides;
  final ValueNotifier<bool> filled;

  const DrawingCanvas({
    Key? key,
    required this.height,
    required this.width,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingMode,
    required this.sideBarController,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.filled,
    required this.polygonSides,
    required this.backgroundImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      child: Stack(
        children: [
          buildAllSketches(context),
          buildCurrentPath(context),
        ],
      ),
    );
  }

  void onPointerDown(PointerDownEvent details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: [offset],
        size: drawingMode.value == DrawingMode.eraser
            ? eraserSize.value
            : strokeSize.value,
        color: selectedColor.value,
        sides: polygonSides.value,
      ),
      drawingMode.value,
      filled.value,
    );
  }

  void onPointerMove(PointerMoveEvent details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    var offset = box.globalToLocal(details.position);

    // Ensure drawings are not out of bounds
    double maxWidth = box.size.width;
    double maxHeight = box.size.height;
    if (offset.dx < 0) {
      offset = offset.translate(-offset.dx, 0.0);
    }
    if (offset.dy < 0) {
      offset = offset.translate(0.0, -offset.dy);
    }
    if (offset.dx > maxWidth) {
      offset = offset.translate(maxWidth - offset.dx, 0.0);
    }
    if (offset.dy > maxHeight) {
      offset = offset.translate(0.0, maxHeight - offset.dy);
    }

    final points = List<Offset>.from(currentSketch.value?.points ?? [])
      ..add(offset);
    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: points,
        size: drawingMode.value == DrawingMode.eraser
            ? eraserSize.value
            : strokeSize.value,
        color: selectedColor.value,
        sides: polygonSides.value,
      ),
      drawingMode.value,
      filled.value,
    );

    // TODO: This is an extremely hacky way to get real-time eraser working. Basically, we replace the last value of allSketches with currentSketch so that it triggers a repaint.
    if (drawingMode.value == DrawingMode.eraser) {
      if (currentSketch.value != null) {
        // For some reason, size is a good way to check if the last value of allSketches is the same as currentSketch.
        if (allSketches.value.last.size == currentSketch.value!.size) {
          allSketches.value.last = currentSketch.value!;
        } else {
          allSketches.value.add(currentSketch.value!);
        }
      }
    }
  }

  void onPointerUp(PointerUpEvent details) {
    allSketches.value = List<Sketch>.from(allSketches.value)
      ..add(currentSketch.value!);
  }

  Widget buildAllSketches(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ValueListenableBuilder<List<Sketch>>(
        valueListenable: allSketches,
        builder: (context, sketches, _) {
          return RepaintBoundary(
            key: canvasGlobalKey,
            child: Container(
              height: height,
              width: width,
              color: CustomColors.canvasColor,
              child: CustomPaint(
                painter: SketchPainter(
                  sketches: sketches,
                  backgroundImage: backgroundImage.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    if (drawingMode.value == DrawingMode.pan) {
      return const SizedBox.shrink();
    }

    return Listener(
      onPointerDown: (details) => onPointerDown(details, context),
      onPointerMove: (details) => onPointerMove(details, context),
      onPointerUp: onPointerUp,
      child: ValueListenableBuilder(
        valueListenable: currentSketch,
        builder: (context, sketch, child) {
          return RepaintBoundary(
            child: SizedBox(
              height: height,
              width: width,
              child: CustomPaint(
                painter: SketchPainter(
                  sketches: sketch == null ? [] : [sketch],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
