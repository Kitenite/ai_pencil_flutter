import 'dart:typed_data';

import 'package:ai_pencil/model/drawing/drawing_project.dart';
import 'package:ai_pencil/sao/api.dart';
import 'package:ai_pencil/utils/dialog_helper.dart';
import 'package:ai_pencil/utils/event_analytics.dart';
import 'package:ai_pencil/utils/prompt_styles_manager.dart';
import 'package:ai_pencil/widgets/inference_screen/image_to_image_tab.dart';
import 'package:ai_pencil/widgets/inference_screen/inpainting_tab.dart';
import 'package:ai_pencil/widgets/inference_screen/text_to_image_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';

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
    final callingTextToText = useState(false);

    // Prompt Styles
    final selectedArtType = useState('');
    final selectedSubstyleKeys = useState<Map<String, String>>({});

    void generateImage(
      bool useImage,
      bool turbo, {
      Uint8List? maskBytes,
    }) {
      MixPanelAnalyticsManager().trackEvent("Generate image", {
        'use_image': useImage,
        'turbo_mode': turbo,
        'mask': maskBytes != null,
      });

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

    var promptInputTextField = Column(
      children: [
        TextField(
          controller: promptTextController,
          textInputAction: TextInputAction.done,
          autocorrect: true,
          maxLines: null,
          maxLength: 350,
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Be as descriptive as you can',
              suffixIcon: callingTextToText.value
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: const Icon(FontAwesomeIcons.rocket),
                      onPressed: () {
                        MixPanelAnalyticsManager()
                            .trackEvent("Generate prompt", {
                          'prompt': promptTextController.text,
                        });
                        DialogHelper.showConfirmDialog(
                            context,
                            "Improve prompt with AI",
                            "We will rewrite your prompt using AI. This will replace your current prompt.\n\nNote: This is still experimental and may not always work.",
                            "Confirm",
                            "Cancel", () {
                          callingTextToText.value = true;

                          ApiDataAccessor.textToText(promptTextController.text)
                              .then((improvedText) {
                            promptTextController.text = improvedText;
                            callingTextToText.value = false;
                          }).onError((error, stackTrace) {
                            callingTextToText.value = false;
                            Logger("InferenceScreen::callTextToText").severe(
                              "Error while calling text to text API",
                              error,
                              stackTrace,
                            );
                            DialogHelper.showInfoDialog(
                                context,
                                "Error improving prompt",
                                "An error occurred while calling the AI. Please try again later. Error: $error",
                                "OK");
                          });
                        });
                      },
                    )),
        ),
      ],
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
                  onGenerateImage: generateImage,
                ),
                TextToImageTab(
                  promptInputTextField: promptInputTextField,
                  selectedArtType: selectedArtType,
                  selectedSubstyleKeys: selectedSubstyleKeys,
                  onGenerateImage: generateImage,
                ),
                InpaintingTab(
                  project: project,
                  promptInputTextField: promptInputTextField,
                  selectedArtType: selectedArtType,
                  selectedSubstyleKeys: selectedSubstyleKeys,
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
