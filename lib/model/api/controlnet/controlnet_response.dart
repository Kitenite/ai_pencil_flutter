import 'package:json_annotation/json_annotation.dart';
part 'controlnet_response.g.dart';

@JsonSerializable()
class ControlNetResponse {
  String image;

  ControlNetResponse({
    required this.image,
  });

  factory ControlNetResponse.fromJson(Map<String, dynamic> json) =>
      _$ControlNetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ControlNetResponseToJson(this);
}
