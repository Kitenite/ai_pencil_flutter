import 'package:json_annotation/json_annotation.dart';
part 'image_to_image_request.g.dart';

@JsonSerializable()
class ImageToImageRequest {
  String image;
  String prompt;
  ImageToImageRequest({
    required this.image,
    required this.prompt,
  });

  factory ImageToImageRequest.fromJson(Map<String, dynamic> json) =>
      _$ImageToImageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ImageToImageRequestToJson(this);
}
