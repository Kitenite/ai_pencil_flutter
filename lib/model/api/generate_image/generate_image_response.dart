import 'package:json_annotation/json_annotation.dart';
part 'generate_image_response.g.dart';

@JsonSerializable()
class GenerateImageResponse {
  String? image;
  String? error;
  bool? filtered = false;

  GenerateImageResponse({
    required this.image,
    this.error,
    this.filtered,
  });

  factory GenerateImageResponse.fromJson(Map<String, dynamic> json) =>
      _$GenerateImageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GenerateImageResponseToJson(this);
}
