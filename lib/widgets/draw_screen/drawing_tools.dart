import 'package:ai_pencil/model/drawing_canvas/drawing_mode.dart';
import 'package:ai_pencil/model/drawing_canvas/sketch.dart';
import 'package:ai_pencil/model/drawing_canvas/undo_redo_stack.dart';
import 'package:ai_pencil/widgets/draw_screen/icon_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// TODO: Add select, move, resize drawing tool

class DrawingToolBar extends StatelessWidget {
  const DrawingToolBar({
    super.key,
    required this.allSketches,
    required this.undoRedoStack,
    required this.drawingMode,
    required this.selectedColor,
  });

  final ValueNotifier<List<Sketch>> allSketches;
  final ValueNotifier<UndoRedoStack> undoRedoStack;
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Color> selectedColor;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          const SizedBox(width: 10),
          IconBox(
            iconData: FontAwesomeIcons.arrowRotateLeft,
            selected: allSketches.value.isNotEmpty,
            onTap: allSketches.value.isNotEmpty
                ? () => undoRedoStack.value.undo()
                : () {},
            tooltip: 'Undo',
          ),
          ValueListenableBuilder<bool>(
            valueListenable: undoRedoStack.value.canRedo,
            builder: (_, canRedo, __) {
              return IconBox(
                iconData: FontAwesomeIcons.arrowRotateRight,
                selected: canRedo,
                onTap: canRedo ? () => undoRedoStack.value.redo() : () {},
                tooltip: 'Redo',
              );
            },
          ),
          IconBox(
            iconData: FontAwesomeIcons.trash,
            selected: true,
            onTap: () => undoRedoStack.value.clear(),
            tooltip: 'Clear',
          ),
          const Spacer(),
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
          IconBox(
            iconData: FontAwesomeIcons.brush,
            selected: drawingMode.value == DrawingMode.paint,
            onTap: () => drawingMode.value = DrawingMode.paint,
            tooltip: 'Paint',
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  // TODO: Pull into own widget
                  // TODO: Add previous colors
                  return AlertDialog(
                    title: const Text(
                      'Color',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: selectedColor.value,
                        onColorChanged: (value) {
                          selectedColor.value = value;
                        },
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Done'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  );
                },
              );
            },
            style: OutlinedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: selectedColor.value,
              side: const BorderSide(
                width: 2.0,
                color: Color.fromARGB(127, 255, 255, 255),
              ),
            ),
            child: const SizedBox.shrink(),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
