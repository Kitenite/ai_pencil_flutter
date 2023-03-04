import 'package:ai_pencil/model/drawing/drawing_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LayerPopover extends HookWidget {
  final ValueNotifier<List<DrawingLayer>> layers;
  final ValueNotifier<int> activeLayerIndex;
  //final List<DrawingLayer> layers;
  final Function(int, int) onMoveLayer;
  final Function(int) onSelectLayer;
  final Function() onAddLayer;
  final Function(int) onRemoveLayer;
  final Function(int, String) onRenameLayer;
  final Function(int) onToggleLayerVisibility;

  const LayerPopover({
    Key? key,
    required this.layers,
    required this.activeLayerIndex,
    required this.onMoveLayer,
    required this.onSelectLayer,
    required this.onAddLayer,
    required this.onRemoveLayer,
    required this.onRenameLayer,
    required this.onToggleLayerVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget getDeleteButton(index) {
      if (index != activeLayerIndex.value) {
        return IconButton(
          icon: const Icon(
            FontAwesomeIcons.trash,
            size: 15,
          ),
          onPressed: () {
            onRemoveLayer(index);
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    Widget getPreviewImage(index) {
      if (layers.value[index].image.isEmpty) {
        return const SizedBox.shrink();
      }
      return Image.memory(layers.value[index].image);
    }

    Widget getVisibilityButton(index) {
      if (index != activeLayerIndex.value) {
        return IconButton(
          icon: Icon(
            layers.value[index].isVisible
                ? FontAwesomeIcons.eye
                : FontAwesomeIcons.eyeSlash,
            size: 15,
          ),
          onPressed: () {
            onToggleLayerVisibility(index);
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    return ValueListenableBuilder(
        valueListenable: layers,
        builder: (context, value, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      "Layers",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.plus,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: onAddLayer,
                    ),
                  ],
                ),
              ),
              ReorderableListView(
                reverse: true,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                buildDefaultDragHandles: false,
                onReorder: (int oldIndex, int newIndex) {
                  onMoveLayer(oldIndex, newIndex);
                },
                header: Card(
                  color: Colors.grey[800],
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                    ),
                    title: const Text(
                      "Background color",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // TODO: Add previous colors
                          return AlertDialog(
                            title: const Text(
                              'Choose background color',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: Colors.white,
                                onColorChanged: (value) {
                                  // TODO: Set background color
                                  print(value);
                                },
                                pickerAreaBorderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
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
                  ),
                ),
                children: <Widget>[
                  for (int index = 0; index < layers.value.length; index += 1)
                    Card(
                      key: Key('$index'),
                      color: index == activeLayerIndex.value
                          ? Colors.blue
                          : Colors.grey[800],
                      child: ListTile(
                        title: Text(layers.value[index].title),
                        selectedColor: Colors.white,
                        textColor: Colors.white,
                        iconColor: Colors.white,
                        selected: activeLayerIndex.value == index,
                        onTap: () {
                          onSelectLayer(index);
                        },
                        leading: Container(
                          width: 40,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: getPreviewImage(index),
                        ),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          getDeleteButton(index),
                          getVisibilityButton(index),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(
                              FontAwesomeIcons.gripLines,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ]),
                      ),
                    ),
                ],
              )
            ]),
          );
        });
  }
}
