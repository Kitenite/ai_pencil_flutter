import 'package:ai_pencil/model/drawing/drawing_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
    return ValueListenableBuilder(
      valueListenable: layers,
      builder: (context, value, child) {
        return Column(
          children: <Widget>[
            Row(
              children: [
                const Text('Layers'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onAddLayer,
                ),
              ],
            ),
            ReorderableListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              children: <Widget>[
                for (int index = 0; index < layers.value.length; index += 1)
                  ListTile(
                    key: Key('$index'),
                    title: Text(layers.value[index].title),
                    selectedColor: Colors.blue,
                    selected: activeLayerIndex.value == index,
                    onTap: () {
                      onSelectLayer(index);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            layers.value[index].isVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            onToggleLayerVisibility(index);
                          },
                        ),
                        ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle),
                        ),
                      ]
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        onRemoveLayer(index);
                      },
                    )
                  ),
              ],
              onReorder: (int oldIndex, int newIndex) {
                onMoveLayer(oldIndex, newIndex);
              },
            )
          ]
        );
      }
    );
  }
}