import 'package:ai_pencil/utils/prompt_styles_manager.dart';
import 'package:ai_pencil/widgets/inference_screen/prompt_style_card.dart';
import 'package:ai_pencil/widgets/inference_screen/prompt_style_selector.dart';
import 'package:flutter/material.dart';

class PromptStyleSection extends StatelessWidget {
  PromptStyleSection({
    super.key,
    required this.selectedArtType,
    required this.selectedSubstyleKeys,
  });

  final ValueNotifier<String> selectedArtType;
  final ValueNotifier<Map<String, String>> selectedSubstyleKeys;
  final PromptStylesManager _promptStylesManager =
      PromptStylesManager.getInstance();

  Widget _buildArtStyleSection() {
    return PromptStyleSelector(
      title: "Art Style (Optional)",
      children: [
        for (var artType in _promptStylesManager.getArtTypeKeys())
          PromptStyleCard(
            isSelected: selectedArtType.value == artType,
            styleKey: artType,
            imageUrl: _promptStylesManager.getImageUrlForArtType(artType),
            onTap: () {
              selectedArtType.value = artType;
              selectedSubstyleKeys.value = {};
            },
          ),
      ]
    );
  }

  Widget _buildSubstyleSection() {
    var substyleKeys =
        _promptStylesManager.getSubstylesByArtType(selectedArtType.value);
    return Column(
      children: [
        for (var index = 0; index < substyleKeys.length; index++)
          PromptStyleSelector(title: substyleKeys[index].key, children: [
            for (var substyleValueKey in _promptStylesManager
                .getSubstyleValueKeys(selectedArtType.value, index))
              PromptStyleCard(
                isSelected: selectedSubstyleKeys.value[substyleKeys[index].key] ==
                    substyleValueKey,
                styleKey: substyleValueKey,
                imageUrl: _promptStylesManager.getImageUrlForSubstyle(
                    selectedArtType.value, index, substyleValueKey),
                onTap: () {
                  selectedSubstyleKeys.value[substyleKeys[index].key] = substyleValueKey;
                  selectedSubstyleKeys.notifyListeners();
                },
              )
          ])
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildArtStyleSection(),
        _buildSubstyleSection(),
      ],
    );
  }
}
