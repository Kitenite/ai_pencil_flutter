import 'package:ai_pencil/model/drawing/advanced_options.dart';
import 'package:json_annotation/json_annotation.dart';
part 'generate_image_request.g.dart';

@JsonSerializable()
class GenerateImageRequest {
  String? image;
  String prompt;
  AdvancedOptions advancedOptions;

  GenerateImageRequest({
    required this.prompt,
    required this.advancedOptions,
    this.image,
  });

  factory GenerateImageRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateImageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$GenerateImageRequestToJson(this);
}
