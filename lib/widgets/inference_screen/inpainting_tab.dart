import 'dart:typed_data';

import 'package:ai_pencil/model/drawing/drawing_project.dart';
import 'package:ai_pencil/model/drawing/drawing_tools.dart';
import 'package:ai_pencil/model/drawing_canvas/drawing_mode.dart';
import 'package:ai_pencil/model/drawing_canvas/sketch.dart';
import 'package:ai_pencil/model/drawing_canvas/slider_type.dart';
import 'package:ai_pencil/model/drawing_canvas/undo_redo_stack.dart';
import 'package:ai_pencil/utils/dialog_helper.dart';
import 'package:ai_pencil/utils/image_helpers.dart';
import 'package:ai_pencil/widgets/draw_screen/icon_box.dart';
import 'package:ai_pencil/widgets/draw_screen/slider_preview_modal.dart';
import 'package:ai_pencil/widgets/draw_screen/tools_sliders.dart';
import 'package:ai_pencil/widgets/drawing_canvas/inpaint_canvas.dart';
import 'package:ai_pencil/widgets/inference_screen/prompt_style_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as IMG;
import 'package:logging/logging.dart';

class InpaintingTab extends HookWidget {
  final DrawingProject project;
  final TextField promptInputTextField;
  final ValueNotifier<String> selectedArtType;
  final ValueNotifier<Map<String, String>> selectedSubstyleKeys;
  final Function(bool, bool, {Uint8List maskBytes}) onGenerateImage;

  const InpaintingTab({
    super.key,
    required this.project,
    required this.promptInputTextField,
    required this.selectedArtType,
    required this.selectedSubstyleKeys,
    required this.onGenerateImage,
  });

  @override
  Widget build(BuildContext context) {
    final canvasGlobalKey = GlobalKey();
    final ValueNotifier<Sketch?> currentSketch = useState(null);
    final ValueNotifier<List<Sketch>> allSketches = useState([]);
    final undoRedoStack = useState(UndoRedoStack(
      sketchesNotifier: allSketches,
      currentSketchNotifier: currentSketch,
    ));
    final ValueNotifier<bool> editingMask = useState(false);

    // Drawing tools
    final drawingTools = DrawingTools();
    final sliderModalVisible = useState<bool>(false);
    final activeSlider = useState<SliderType>(SliderType.strokeSize);

    void generateInpaintImage() {
      Size? imageSize = ImageHelper.getDrawingSize(canvasGlobalKey);
      ImageHelper.getPngBytesFromSketches(
        allSketches.value,
        imageSize!,
        Colors.white,
        null,
      ).then((maskBytes) {
        onGenerateImage(
          true,
          false,
          maskBytes: maskBytes!,
        );
      }).onError((error, stackTrace) {
        Logger("InpaintingTab::generateInpaintImage")
            .severe("Error generating inpaint image: $error, $stackTrace");
      });
    }

    Widget getInpaintCanvas() {
      // Set up drawing tool
      drawingTools.drawingMode.value = DrawingMode.paint;
      drawingTools.setSelectedColor(Colors.black);

      IMG.Image decoded = IMG.decodeImage(project.thumbnailImageBytes!)!;

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: project.aspectWidth / project.aspectHeight,
          child: Center(
            child: Stack(children: [
              Image.memory(
                project.thumbnailImageBytes!,
              ),
              Positioned.fill(
                child: InpaintCanvas(
                  drawingTools: drawingTools,
                  canvasGlobalKey: canvasGlobalKey,
                  allSketches: allSketches,
                  currentSketch: currentSketch,
                  width: decoded.width.toDouble(),
                  height: decoded.height.toDouble(),
                  editingMask: editingMask,
                ),
              ),
              Center(
                child: SliderPreviewModal(
                  sliderModalVisible: sliderModalVisible,
                  drawingTools: drawingTools,
                  activeSlider: activeSlider,
                ),
              )
            ]),
          ),
        ),
      );
    }

    Widget inpaintingToolBar = Column(
      children: [
        ToolsSliders(
          sliderModalVisible: sliderModalVisible,
          drawingTools: drawingTools,
          activeSlider: activeSlider,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
              onTap: () {
                DialogHelper.showConfirmDialog(
                  context,
                  "Clear mask",
                  "This cannot be undone.",
                  "Clear",
                  "Cancel",
                  () => undoRedoStack.value.clear(),
                );
              },
              tooltip: 'Clear',
            ),
          ],
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        physics: editingMask.value
            ? const NeverScrollableScrollPhysics()
            : const ScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 10, top: 10),
              child: Text(
                "Inpaint your drawing",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                "Fill in the part of your drawing that you want to repaint",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            getInpaintCanvas(),
            inpaintingToolBar,
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                "Describe your mask",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            promptInputTextField,
            PromptStyleSection(
              selectedArtType: selectedArtType,
              selectedSubstyleKeys: selectedSubstyleKeys,
            ),
            OutlinedButton(
              onPressed: () {
                generateInpaintImage();
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                side: const BorderSide(
                  color: Colors.amber,
                  width: 1,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Generate Image",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
