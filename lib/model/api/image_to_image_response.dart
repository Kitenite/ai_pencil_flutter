import 'package:json_annotation/json_annotation.dart';
part 'image_to_image_response.g.dart';

@JsonSerializable()
class ImageToImageResponse {
  String image;
  ImageToImageResponse({
    required this.image,
  });

  factory ImageToImageResponse.fromJson(Map<String, dynamic> json) =>
      _$ImageToImageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ImageToImageResponseToJson(this);
}
