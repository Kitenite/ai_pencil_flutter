import 'dart:typed_data';

import 'package:ai_pencil/model/drawing/drawing_project.dart';
import 'package:ai_pencil/sao/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    final promptTextController = useTextEditingController(text: project.prompt);
    final turboMode = useState(false);

    void generateImage(bool useImage, bool turbo) {
      Future<Uint8List> imageBytes;

      if (turbo) {
        // Controlnet
        imageBytes = ApiDataAccessor.controlNet(
          promptTextController.value.text,
          project.thumbnailImageBytes,
        );
      } else {
        // Image2Image
        imageBytes = ApiDataAccessor.generateImage(
          promptTextController.value.text,
          project.thumbnailImageBytes,
          useImage,
        );
      }
      onImageGenerationStarted(imageBytes, promptTextController.value.text);
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

    Widget inpaintingTab = Padding(
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

    return SafeArea(
      child: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(),
          body: TabBarView(
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
    );
  }
}
