import 'package:ai_pencil/model/drawing_canvas/drawing_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DrawingTools {
  final drawingMode = useState(DrawingMode.pencil);
  final usedColors = useState<List<Color>>([]);

  final pencilSize = useState<double>(3);
  final pencilOpacity = useState<double>(1);
  final pencilColor = useState<Color>(Colors.black);
  final double pencilMinSize = 1;
  final double pencilMaxSize = 20;

  final paintSize = useState<double>(50);
  final paintOpacity = useState<double>(0.5);
  final paintColor = useState<Color>(Colors.blue);
  final double paintMinSize = 20;
  final double paintMaxSize = 100;

  final eraserSize = useState<double>(30);
  final double eraserMinSize = 1;
  final double eraserMaxSize = 100;

  ValueNotifier<Color> getSelectedColorNotifier() {
    switch (drawingMode.value) {
      case DrawingMode.pencil:
        return pencilColor;
      case DrawingMode.paint:
        return paintColor;
      default:
        return pencilColor;
    }
  }

  Color getSelectedColor() {
    switch (drawingMode.value) {
      case DrawingMode.pencil:
        return pencilColor.value;
      case DrawingMode.paint:
        return paintColor.value;
      default:
        return pencilColor.value;
    }
  }

  double getMinStrokeSize() {
    switch (drawingMode.value) {
      case DrawingMode.pencil:
        return pencilMinSize;
      case DrawingMode.paint:
        return paintMinSize;
      case DrawingMode.eraser:
        return eraserMinSize;
      default:
        return pencilMinSize;
    }
  }

  double getMaxStrokeSize() {
    switch (drawingMode.value) {
      case DrawingMode.pencil:
        return pencilMaxSize;
      case DrawingMode.paint:
        return paintMaxSize;
      case DrawingMode.eraser:
        return eraserMaxSize;
      default:
        return pencilMaxSize;
    }
  }

  double getStrokeSize() {
    switch (drawingMode.value) {
      case DrawingMode.pencil:
        return pencilSize.value;
      case DrawingMode.paint:
        return paintSize.value;
      case DrawingMode.eraser:
        return eraserSize.value;
      default:
        return pencilSize.value;
    }
  }

  double getOpacity() {
    switch (drawingMode.value) {
      case DrawingMode.pencil:
        return pencilOpacity.value;
      case DrawingMode.paint:
        return paintOpacity.value;
      case DrawingMode.eraser:
        return 1;
      default:
        return pencilOpacity.value;
    }
  }

  void setSelectedColor(Color color) {
    switch (drawingMode.value) {
      case DrawingMode.pencil:
        pencilColor.value = color;
        break;
      case DrawingMode.paint:
        pencilColor.value = color;
        break;
      default:
        pencilColor.value = color;
        break;
    }
  }

  void setOpacity(double opacity) {
    switch (drawingMode.value) {
      case DrawingMode.pencil:
        pencilOpacity.value = opacity;
        break;
      case DrawingMode.paint:
        paintOpacity.value = opacity;
        break;
      case DrawingMode.eraser:
        break;
      default:
        pencilOpacity.value = opacity;
    }
  }

  void setStrokeSize(double size) {
    switch (drawingMode.value) {
      case DrawingMode.pencil:
        pencilSize.value = size;
        break;
      case DrawingMode.paint:
        paintSize.value = size;
        break;
      case DrawingMode.eraser:
        eraserSize.value = size;
        break;
      default:
        pencilSize.value = size;
    }
  }
}
