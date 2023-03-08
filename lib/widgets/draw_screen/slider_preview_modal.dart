import 'package:ai_pencil/model/drawing/drawing_tools.dart';
import 'package:ai_pencil/model/drawing_canvas/slider_type.dart';
import 'package:flutter/material.dart';

class SliderPreviewModal extends StatelessWidget {
  final ValueNotifier<bool> sliderModalVisible;
  final DrawingTools drawingTools;
  final ValueNotifier<SliderType> activeSlider;

  const SliderPreviewModal({
    super.key,
    required this.sliderModalVisible,
    required this.drawingTools,
    required this.activeSlider,
  });

  @override
  Widget build(BuildContext context) {
    Widget getSliderPreviewModal() {
      String modalText = "Size ${drawingTools.getStrokeSize().round()}";
      double previewSize = drawingTools.getStrokeSize();
      Color previewColor = Colors.white;

      switch (activeSlider.value) {
        case SliderType.strokeSize:
          modalText = "Size ${drawingTools.getStrokeSize().round()}";
          previewSize = drawingTools.getStrokeSize();
          break;
        case SliderType.opacity:
          modalText = "Opacity ${(drawingTools.getOpacity() * 100).round()}%";
          previewSize = 50;
          previewColor = previewColor.withOpacity(drawingTools.getOpacity());
          break;
      }

      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(modalText),
            Expanded(
              child: Container(
                width: previewSize,
                height: previewSize,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(drawingTools.getOpacity()),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: sliderModalVisible.value ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 150.0,
          height: 150.0,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.black87,
            border: Border.all(
              width: 3,
              color: Colors.black,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: getSliderPreviewModal(),
        ),
      ),
    );
  }
}
