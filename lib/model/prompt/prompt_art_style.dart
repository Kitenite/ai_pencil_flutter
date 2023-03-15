import 'package:json_annotation/json_annotation.dart';
part 'prompt_art_style.g.dart';

@JsonSerializable()
class PromptArtStyle {
  String key;
  String? prefix;
  String? suffix;
  String? imageUrl;
  PromptArtStyle({
    required this.key,
    this.prefix,
    this.suffix,
    this.imageUrl,
  });
  factory PromptArtStyle.fromJson(Map<String, dynamic> json) =>
      _$PromptArtStyleFromJson(json);
  Map<String, dynamic> toJson() => _$PromptArtStyleToJson(this);
}
