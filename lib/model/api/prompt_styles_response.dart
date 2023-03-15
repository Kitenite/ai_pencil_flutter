import 'package:json_annotation/json_annotation.dart';
import 'package:ai_pencil/model/prompt/prompt_style.dart';
part 'prompt_styles_response.g.dart';

@JsonSerializable()
class PromptStylesResponse {
  List<PromptStyle> promptStyles;
  PromptStylesResponse({
    required this.promptStyles,
  });

  factory PromptStylesResponse.fromJson(Map<String, dynamic> json) =>
      _$PromptStylesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PromptStylesResponseToJson(this);
}
