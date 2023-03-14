import 'package:json_annotation/json_annotation.dart';
part 'generate_image_error_response.g.dart';

@JsonSerializable()
class GenerateImageErrorResponse {
  String error;
  GenerateImageErrorResponse({
    required this.error,
  });

  factory GenerateImageErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$GenerateImageErrorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GenerateImageErrorResponseToJson(this);
}
