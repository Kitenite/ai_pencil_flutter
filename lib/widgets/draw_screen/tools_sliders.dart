import 'package:ai_pencil/model/drawing/drawing_tools.dart';
import 'package:ai_pencil/model/drawing_canvas/slider_type.dart';
import 'package:flutter/material.dart';

class ToolsSliders extends StatelessWidget {
  const ToolsSliders({
    super.key,
    required this.sliderModalVisible,
    required this.drawingTools,
    required this.activeSlider,
  });

  final ValueNotifier<bool> sliderModalVisible;
  final DrawingTools drawingTools;
  final ValueNotifier<SliderType> activeSlider;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -4,
      child: AnimatedOpacity(
        opacity: sliderModalVisible.value ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 300),
        child: Card(
          color: Colors.black54,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Slider(
                  value: drawingTools.getStrokeSize(),
                  min: drawingTools.getMinStrokeSize(),
                  max: drawingTools.getMaxStrokeSize(),
                  onChanged: (val) {
                    drawingTools.setStrokeSize(val);
                  },
                  onChangeStart: (value) {
                    activeSlider.value = SliderType.strokeSize;
                    sliderModalVisible.value = true;
                  },
                  onChangeEnd: (value) {
                    sliderModalVisible.value = false;
                  },
                ),
                Slider(
                  value: drawingTools.getOpacity(),
                  min: 0,
                  max: 1,
                  onChanged: (val) {
                    drawingTools.setOpacity(val);
                  },
                  onChangeStart: (value) {
                    activeSlider.value = SliderType.opacity;
                    sliderModalVisible.value = true;
                  },
                  onChangeEnd: (value) {
                    sliderModalVisible.value = false;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
