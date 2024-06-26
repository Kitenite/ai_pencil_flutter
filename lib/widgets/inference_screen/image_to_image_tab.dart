import 'package:ai_pencil/model/drawing/drawing_project.dart';
import 'package:ai_pencil/utils/themes.dart';
import 'package:ai_pencil/widgets/inference_screen/prompt_style_section.dart';
import 'package:flutter/material.dart';

class ImageToImageTab extends StatelessWidget {
  final DrawingProject project;
  final Widget promptInputTextField;
  final ValueNotifier<bool> turboMode;
  final ValueNotifier<String> selectedArtType;
  final ValueNotifier<Map<String, String>> selectedSubstyleKeys;
  final Function(bool, bool) onGenerateImage;

  const ImageToImageTab({
    super.key,
    required this.project,
    required this.promptInputTextField,
    required this.turboMode,
    required this.selectedArtType,
    required this.selectedSubstyleKeys,
    required this.onGenerateImage,
  });

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
                    activeColor: CustomTheme.primaryColor,
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
                onGenerateImage(true, turboMode.value);
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                side: BorderSide(
                  color: CustomTheme.primaryColor,
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
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
