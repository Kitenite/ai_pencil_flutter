import 'package:json_annotation/json_annotation.dart';
part 'upload_image_request.g.dart';

@JsonSerializable()
class UploadImageRequest {
  String? image;

  UploadImageRequest({
    this.image,
  });

  factory UploadImageRequest.fromJson(Map<String, dynamic> json) =>
      _$UploadImageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UploadImageRequestToJson(this);
}
