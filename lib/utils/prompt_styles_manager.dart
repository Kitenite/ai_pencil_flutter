import 'package:ai_pencil/model/prompt/prompt_art_style.dart';
import 'package:ai_pencil/model/prompt/prompt_style.dart';
import 'package:ai_pencil/model/prompt/prompt_substyle.dart';
import 'package:ai_pencil/sao/api.dart';

class PromptStylesManager {
  static final PromptStylesManager _instance = PromptStylesManager._internal();
  List<PromptStyle> _promptStyles = [];

  Future<void> init() async {
    _promptStyles = await ApiDataAccessor.getPromptStyles();
  }

  PromptStylesManager._internal() {
    init();
  }
  
  static PromptStylesManager getInstance() {
    return _instance;
  }

  List<String> getArtTypeKeys() {
    return _promptStyles.map((e) => e.key).toList();
  }

  List<PromptSubstyle> getSubstylesByArtType(String artType) {
    return _promptStyles
            .firstWhere((e) => e.key == artType,
                orElse: () => PromptStyle(key: ""))
            .substyles ??
        [];
  }

  String getSubstyleKey(String artType, int index) {
    return getSubstylesByArtType(artType)[index].key;
  }

  List<String> getSubstyleValueKeys(String artType, int index) {
    return getSubstylesByArtType(artType)[index]
        .values
        .map((e) => e.key)
        .toList();
  }

  PromptArtStyle getPromptArtStyle(
      String artType, String substyleValueKey, int substyleIndex) {
    if (getSubstylesByArtType(artType).length <= substyleIndex) {
      return PromptArtStyle(key: "");
    }
    return getSubstylesByArtType(artType)[substyleIndex].values.firstWhere(
        (e) => e.key == substyleValueKey,
        orElse: () => PromptArtStyle(key: ""));
  }

  String? getArtTypePrefix(String artType) {
    return _promptStyles
        .firstWhere((e) => e.key == artType, orElse: () => PromptStyle(key: ""))
        .prefix;
  }

  String? getArtTypeSuffix(String artType) {
    return _promptStyles
        .firstWhere((e) => e.key == artType, orElse: () => PromptStyle(key: ""))
        .suffix;
  }

  String? getPromptArtStylePrefix(
      String artType, int substyleIndex, String substyleValue) {
    return getPromptArtStyle(artType, substyleValue, substyleIndex).prefix;
  }

  String? getPromptArtStyleSuffix(
      String artType, int substyleIndex, String substyleValue) {
    return getPromptArtStyle(artType, substyleValue, substyleIndex).suffix;
  }

  String buildPrompt(String selectedArtTypeKey,
      List<String> selectedSubstyleKeys, String prompt) {
    var enhancedPrompt = selectedArtTypeKey == "None" ? prompt : "of $prompt";
    enhancedPrompt =
        addPrefix(getArtTypePrefix(selectedArtTypeKey), enhancedPrompt);
    print("enhancedPrompt: ${getArtTypePrefix(selectedArtTypeKey)}");
    enhancedPrompt =
        addSuffix(getArtTypeSuffix(selectedArtTypeKey), enhancedPrompt);
    print("enhancedPrompt: $enhancedPrompt");
    for (var index = 0; index < selectedSubstyleKeys.length; index++) {
      enhancedPrompt = addPrefix(
          getPromptArtStylePrefix(
              selectedArtTypeKey, index, selectedSubstyleKeys[index]),
          enhancedPrompt);
      enhancedPrompt = addSuffix(
          getPromptArtStyleSuffix(
              selectedArtTypeKey, index, selectedSubstyleKeys[index]),
          enhancedPrompt);
    }
    print("enhancedPrompt: $enhancedPrompt");
    return enhancedPrompt;
  }

  String addPrefix(String? prefix, String prompt) {
    if (prefix != null && prefix != "") {
      return "$prefix $prompt";
    }
    return prompt;
  }

  String addSuffix(String? suffix, String prompt) {
    if (suffix != null && suffix != "") {
      return "$prompt, $suffix";
    }
    return prompt;
  }
}
