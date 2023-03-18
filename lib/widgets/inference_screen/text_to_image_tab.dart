import 'package:ai_pencil/widgets/inference_screen/prompt_style_section.dart';
import 'package:flutter/material.dart';

class TextToImageTab extends StatelessWidget {
  const TextToImageTab({
    super.key,
    required this.promptInputTextField,
    required this.selectedArtType,
    required this.selectedSubstyleKeys,
    required this.onGenerateImage,
  });

  final TextField promptInputTextField;
  final ValueNotifier<String> selectedArtType;
  final ValueNotifier<Map<String, String>> selectedSubstyleKeys;
  final Function(bool, bool) onGenerateImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                onGenerateImage(false, false);
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
  }
}
