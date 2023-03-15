import 'package:ai_pencil/widgets/drawing_canvas/sketch_painter.dart';
import 'package:flutter/material.dart';
import 'package:ai_pencil/model/drawing_canvas/drawing_mode.dart';
import 'package:ai_pencil/model/drawing_canvas/sketch.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class InpaintCanvas extends HookWidget {
  final double height;
  final double width;

  final canvasGlobalKey;
  final ValueNotifier<List<Sketch>> allSketches;
  final ValueNotifier<Sketch?> currentSketch;

  InpaintCanvas({
    Key? key,
    required this.canvasGlobalKey,
    required this.allSketches,
    required this.currentSketch,
    required this.height,
    required this.width,
  }) : super(key: key);

  final double strokeSize = 80;
  final Color color = Colors.black;
  final int sides = 0;
  final double opacity = 0.7;
  final DrawingMode drawingMode = DrawingMode.paint;

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
        size: strokeSize,
        color: color,
        sides: sides,
        opacity: opacity,
      ),
      drawingMode,
      false,
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
        size: strokeSize,
        color: color,
        sides: sides,
        opacity: opacity,
      ),
      drawingMode,
      false,
    );
  }

  void onPointerUp(PointerUpEvent details) {
    allSketches.value = List<Sketch>.from(allSketches.value)
      ..add(currentSketch.value!);
    currentSketch.value = null;
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
              color: Colors.transparent,
              child: CustomPaint(
                painter: SketchPainter(
                  sketches: sketches,
                  backgroundImage: null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return Listener(
      onPointerDown: (details) => onPointerDown(details, context),
      onPointerMove: (details) => onPointerMove(details, context),
      onPointerUp: (details) => onPointerUp(details),
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
