import 'package:ai_pencil/model/drawing/advanced_options.dart';
import 'package:json_annotation/json_annotation.dart';
part 'image_to_image_request.g.dart';

@JsonSerializable()
class ImageToImageRequest {
  String image;
  String prompt;
  AdvancedOptions advancedOptions;

  ImageToImageRequest({
    required this.image,
    required this.prompt,
    required this.advancedOptions,
  });

  factory ImageToImageRequest.fromJson(Map<String, dynamic> json) =>
      _$ImageToImageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ImageToImageRequestToJson(this);
}
