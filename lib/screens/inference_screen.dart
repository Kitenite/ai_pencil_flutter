import 'dart:typed_data';

import 'package:ai_pencil/model/drawing/drawing_project.dart';
import 'package:ai_pencil/model/drawing_canvas/sketch.dart';
import 'package:ai_pencil/sao/api.dart';
import 'package:ai_pencil/utils/image_helpers.dart';
import 'package:ai_pencil/widgets/drawing_canvas/inpaint_canvas.dart';
import 'package:ai_pencil/utils/prompt_styles_manager.dart';
import 'package:ai_pencil/widgets/inference_screen/prompt_style_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as IMG;

class InferenceScreen extends HookWidget {
  final DrawingProject project;
  final Function(Future<Uint8List>, String) onImageGenerationStarted;

  const InferenceScreen({
    super.key,
    required this.project,
    required this.onImageGenerationStarted,
  });

  @override
  Widget build(BuildContext context) {
    PromptStylesManager promptStylesManager = PromptStylesManager.getInstance();
    final promptTextController = useTextEditingController(text: project.prompt);
    final turboMode = useState(false);

    // Prompt Styles
    final selectedArtType = useState('');
    final selectedSubstyleKeys = useState<Map<String, String>>({});

    // Inpaint Tab
    final canvasGlobalKey = GlobalKey();
    final ValueNotifier<List<Sketch>> allSketches = useState([]);
    final ValueNotifier<Sketch?> currentSketch = useState(null);
    final ValueNotifier<bool> disableScroll = useState(false);
    

    void generateImage(bool useImage, bool turbo) {
      Future<Uint8List> imageBytesFuture;
      String prompt = promptStylesManager.buildPrompt(selectedArtType.value,
          selectedSubstyleKeys.value, promptTextController.value.text);

      if (turbo) {
        // Controlnet
        imageBytesFuture = ApiDataAccessor.controlNet(
          prompt,
          project.thumbnailImageBytes,
        );
      } else {
        // Image2Image
        imageBytesFuture = ApiDataAccessor.generateImage(
          prompt,
          project.thumbnailImageBytes,
          useImage,
        );
      }
      onImageGenerationStarted(
          imageBytesFuture, promptTextController.value.text);
      Navigator.pop(context);
    }

    var promptInputTextField = TextField(
      controller: promptTextController,
      textInputAction: TextInputAction.done,
      autocorrect: true,
      maxLines: null,
      maxLength: 350,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Be as descriptive as you can',
      ),
    );

    Widget imageToImageTab = Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 10, top: 10),
              child: Text(
                "Enhance your drawing",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.memory(project.thumbnailImageBytes!),
            ),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                "Describe your image",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            promptInputTextField,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                    activeColor: Colors.amber,
                    value: turboMode.value,
                    onChanged: (val) => turboMode.value = val!),
                const Text("Turbo Mode (ControlNet)"),
              ],
            ),
            PromptStyleSection(
              selectedArtType: selectedArtType,
              selectedSubstyleKeys: selectedSubstyleKeys,
            ),
            OutlinedButton(
              onPressed: () {
                generateImage(true, turboMode.value);
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

    Widget textToImageTab = Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 15, top: 10),
              child: Text(
                "Create art from text",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
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
                generateImage(false, false);
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
            )
          ],
        ),
      ),
    );

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

    void generateInpaintImage() {
      Size? imageSize = ImageHelper.getDrawingSize(canvasGlobalKey);
      ImageHelper.getPngBytesFromSketches(
              allSketches.value, imageSize!, Colors.white, null)
          .then((imageBytes) {
        Future<Uint8List> imageBytesFuture;
        imageBytesFuture = ApiDataAccessor.generateImage(
          promptTextController.value.text,
          project.thumbnailImageBytes,
          true,
          mask: imageBytes,
        );
        onImageGenerationStarted(
            imageBytesFuture, promptTextController.value.text);
        Navigator.pop(context);
      });
    }

    Widget inpaintingTab = Padding(
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: getInpaintCanvas(),
            ),
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

    Widget extrasTab = Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Padding(
              padding: EdgeInsets.only(bottom: 10, top: 10),
              child: Text(
                "Edit your image",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            Text(
                "Inpainting, outpainting, resizing and upscaling. (Coming soon)."),
          ],
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: DefaultTabController(
          length: 3,
          initialIndex: 0,
          child: Scaffold(
            appBar: AppBar(leading: BackButton(onPressed: () {
              Navigator.pop(context);
            })),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                imageToImageTab,
                textToImageTab,
                inpaintingTab,
              ],
            ),
            bottomNavigationBar: const TabBar(
              indicatorColor: Colors.amber,
              tabs: [
                Tab(icon: Icon(FontAwesomeIcons.image)),
                Tab(icon: Icon(FontAwesomeIcons.comment)),
                Tab(icon: Icon(FontAwesomeIcons.wandMagicSparkles)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
