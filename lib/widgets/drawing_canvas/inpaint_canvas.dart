import 'package:ai_pencil/model/drawing/drawing_tools.dart';
import 'package:ai_pencil/widgets/drawing_canvas/sketch_painter.dart';
import 'package:flutter/material.dart';
import 'package:ai_pencil/model/drawing_canvas/sketch.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class InpaintCanvas extends HookWidget {
  final double height;
  final double width;
  final DrawingTools drawingTools;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<List<Sketch>> allSketches;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<bool> editingMask;

  const InpaintCanvas({
    Key? key,
    required this.drawingTools,
    required this.canvasGlobalKey,
    required this.allSketches,
    required this.currentSketch,
    required this.height,
    required this.width,
    required this.editingMask,
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
    editingMask.value = true;
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: [offset],
        size: drawingTools.getStrokeSize(),
        color: drawingTools.getSelectedColor(),
        sides: 0,
        opacity: drawingTools.getOpacity(),
      ),
      drawingTools.drawingMode.value,
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
        size: drawingTools.getStrokeSize(),
        color: drawingTools.getSelectedColor(),
        sides: 0,
        opacity: drawingTools.getOpacity(),
      ),
      drawingTools.drawingMode.value,
      false,
    );
  }

  void onPointerUp(PointerUpEvent details) {
    allSketches.value = List<Sketch>.from(allSketches.value)
      ..add(currentSketch.value!);
    currentSketch.value = null;
    editingMask.value = false;
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
