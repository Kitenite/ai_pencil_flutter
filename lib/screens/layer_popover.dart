import 'package:ai_pencil/model/drawing/drawing_layer.dart';
import 'package:flutter/material.dart';
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
          icon: const Icon(Icons.delete),
          onPressed: () {
            onRemoveLayer(index);
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    Widget getVisibilityButton(index) {
      if (index != activeLayerIndex.value) {
        return IconButton(
          icon: Icon(
            layers.value[index].isVisible
                ? Icons.visibility
                : Icons.visibility_off,
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
                      ),
                      onPressed: onAddLayer,
                    ),
                  ],
                ),
              ),
              ReorderableListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 40),
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
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          getVisibilityButton(index),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(
                              Icons.drag_handle,
                              color: Colors.white,
                            ),
                          ),
                        ]),
                        leading: getDeleteButton(index),
                      ),
                    ),
                ],
                onReorder: (int oldIndex, int newIndex) {
                  onMoveLayer(oldIndex, newIndex);
                },
              )
            ]),
          );
        });
  }
}
