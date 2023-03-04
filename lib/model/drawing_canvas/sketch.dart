import 'package:flutter/material.dart';
import 'package:ai_pencil/model/drawing_canvas/drawing_mode.dart';

class Sketch {
  final List<Offset> points;
  final Color color;
  final double opacity;
  final double size;
  final SketchType type;
  final bool filled;
  final int sides;

  Sketch({
    required this.points,
    this.color = Colors.black,
    this.opacity = 1,
    this.type = SketchType.scribble,
    this.filled = true,
    this.sides = 3,
    required this.size,
  });

  factory Sketch.fromDrawingMode(
      Sketch sketch, DrawingMode drawingMode, bool filled) {
    return Sketch(
      points: sketch.points,
      color: sketch.color,
      opacity: sketch.opacity,
      size: sketch.size,
      filled: drawingMode == DrawingMode.line ||
              drawingMode == DrawingMode.paint ||
              drawingMode == DrawingMode.pencil ||
              drawingMode == DrawingMode.eraser
          ? false
          : filled,
      sides: sketch.sides,
      type: () {
        switch (drawingMode) {
          case DrawingMode.paint:
            return SketchType.scribble;
          case DrawingMode.eraser:
            return SketchType.eraser;
          case DrawingMode.pencil:
            return SketchType.scribble;
          case DrawingMode.line:
            return SketchType.line;
          case DrawingMode.square:
            return SketchType.square;
          case DrawingMode.circle:
            return SketchType.circle;
          case DrawingMode.polygon:
            return SketchType.polygon;
          default:
            return SketchType.scribble;
        }
      }(),
    );
  }

  Map<String, dynamic> toJson() {
    List<Map> pointsMap = points.map((e) => {'dx': e.dx, 'dy': e.dy}).toList();
    return {
      'points': pointsMap,
      'color': color.toHex(),
      'opacity': opacity,
      'size': size,
      'filled': filled,
      'type': type.toRegularString(),
      'sides': sides,
    };
  }

  factory Sketch.fromJson(Map<String, dynamic> json) {
    List<Offset> points =
        (json['points'] as List).map((e) => Offset(e['dx'], e['dy'])).toList();
    return Sketch(
      points: points,
      color: (json['color'] as String).toColor(),
      opacity: json['opacity'],
      size: json['size'],
      filled: json['filled'],
      type: (json['type'] as String).toSketchTypeEnum(),
      sides: json['sides'],
    );
  }
}

enum SketchType {
  scribble,
  line,
  square,
  circle,
  polygon,
  eraser,
}

extension SketchTypeX on SketchType {
  toRegularString() => toString().split('.')[1];
}

extension SketchTypeExtension on String {
  toSketchTypeEnum() =>
      SketchType.values.firstWhere((e) => e.toString() == 'SketchType.$this');
}

extension ColorExtension on String {
  Color toColor() {
    var hexColor = replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    if (hexColor.length == 8) {
      return Color(int.parse('0x$hexColor'));
    } else {
      return Colors.black;
    }
  }
}

extension ColorExtensionX on Color {
  String toHex() => '#${value.toRadixString(16).substring(2, 8)}';
}
