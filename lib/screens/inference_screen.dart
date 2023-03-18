import 'dart:typed_data';

import 'package:ai_pencil/model/drawing/drawing_project.dart';
import 'package:ai_pencil/model/drawing_canvas/sketch.dart';
import 'package:ai_pencil/sao/api.dart';
import 'package:ai_pencil/utils/prompt_styles_manager.dart';
import 'package:ai_pencil/widgets/inference_screen/image_to_image_tab.dart';
import 'package:ai_pencil/widgets/inference_screen/inpainting_tab.dart';
import 'package:ai_pencil/widgets/inference_screen/prompt_style_section.dart';
import 'package:ai_pencil/widgets/inference_screen/text_to_image_tab.dart';
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
    PromptStylesManager promptStylesManager = PromptStylesManager.getInstance();
    final promptTextController = useTextEditingController(text: project.prompt);
    final turboMode = useState(false);

    // Prompt Styles
    final selectedArtType = useState('');
    final selectedSubstyleKeys = useState<Map<String, String>>({});

    void generateImage(
      bool useImage,
      bool turbo, {
      Uint8List? maskBytes,
    }) {
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
          mask: maskBytes,
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

    Widget promptStyleSection = PromptStyleSection(
      selectedArtType: selectedArtType,
      selectedSubstyleKeys: selectedSubstyleKeys,
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
                ImageToImageTab(
                  project: project,
                  promptInputTextField: promptInputTextField,
                  turboMode: turboMode,
                  selectedArtType: selectedArtType,
                  selectedSubstyleKeys: selectedSubstyleKeys,
                  promptStyleSection: promptStyleSection,
                  onGenerateImage: generateImage,
                ),
                TextToImageTab(
                  promptInputTextField: promptInputTextField,
                  selectedArtType: selectedArtType,
                  selectedSubstyleKeys: selectedSubstyleKeys,
                  promptStyleSection: promptStyleSection,
                  onGenerateImage: generateImage,
                ),
                InpaintingTab(
                  project: project,
                  promptInputTextField: promptInputTextField,
                  promptStyleSection: promptStyleSection,
                  onGenerateImage: generateImage,
                ),
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
