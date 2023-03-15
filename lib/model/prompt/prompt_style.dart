import 'package:ai_pencil/model/prompt/prompt_substyle.dart';
import 'package:json_annotation/json_annotation.dart';
part 'prompt_style.g.dart';

@JsonSerializable()
class PromptStyle {
  String key;
  String? prefix;
  String? suffix;
  String? imageUrl;
  List<PromptSubstyle>? substyles;
  PromptStyle({
    required this.key,
    this.prefix,
    this.suffix,
    this.imageUrl,
    this.substyles,
  });
  factory PromptStyle.fromJson(Map<String, dynamic> json) =>
      _$PromptStyleFromJson(json);
  Map<String, dynamic> toJson() => _$PromptStyleToJson(this);
}