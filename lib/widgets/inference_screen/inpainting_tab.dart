import 'dart:typed_data';

import 'package:ai_pencil/model/drawing/drawing_project.dart';
import 'package:ai_pencil/model/drawing_canvas/sketch.dart';
import 'package:ai_pencil/model/image/types.dart';
import 'package:ai_pencil/utils/image_helpers.dart';
import 'package:ai_pencil/widgets/drawing_canvas/inpaint_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image/image.dart' as IMG;
import 'package:logging/logging.dart';

class InpaintingTab extends HookWidget {
  InpaintingTab({
    super.key,
    required this.project,
    required this.promptInputTextField,
    required this.onGenerateImage,
    required this.promptStyleSection,
  });

  final canvasGlobalKey = GlobalKey();
  final ValueNotifier<List<Sketch>> allSketches = useState([]);
  final ValueNotifier<Sketch?> currentSketch = useState(null);
  final ValueNotifier<bool> disableScroll = useState(false);

  final Widget promptStyleSection;
  final DrawingProject project;
  final TextField promptInputTextField;
  final Function(bool, bool, {Uint8List maskBytes}) onGenerateImage;

  @override
  Widget build(BuildContext context) {
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
      IMG.Image decoded = IMG.decodeImage(project.thumbnailImageBytes!)!;
      return AspectRatio(
        aspectRatio: project.aspectWidth / project.aspectHeight,
        child: Center(
          child: Stack(children: [
            Image.memory(
              project.thumbnailImageBytes!,
            ),
            Positioned.fill(
              child: InpaintCanvas(
                canvasGlobalKey: canvasGlobalKey,
                allSketches: allSketches,
                currentSketch: currentSketch,
                width: decoded.width.toDouble(),
                height: decoded.height.toDouble(),
              ),
            ),
          ]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        physics: disableScroll.value
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
            promptStyleSection,
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
