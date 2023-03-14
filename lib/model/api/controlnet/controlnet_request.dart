import 'package:json_annotation/json_annotation.dart';
part 'controlnet_request.g.dart';

@JsonSerializable()
class ControlNetRequest {
  String? image;
  String prompt;

  ControlNetRequest({
    required this.prompt,
    this.image,
  });

  factory ControlNetRequest.fromJson(Map<String, dynamic> json) =>
      _$ControlNetRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ControlNetRequestToJson(this);
}
