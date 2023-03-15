import 'package:ai_pencil/model/prompt/prompt_art_style.dart';
import 'package:json_annotation/json_annotation.dart';
part 'prompt_substyle.g.dart';

@JsonSerializable()
class PromptSubstyle {
  String key;
  List<PromptArtStyle> values;
  PromptSubstyle({
    required this.key,
    required this.values,
  });
  factory PromptSubstyle.fromJson(Map<String, dynamic> json) =>
      _$PromptSubstyleFromJson(json);
  Map<String, dynamic> toJson() => _$PromptSubstyleToJson(this);
}