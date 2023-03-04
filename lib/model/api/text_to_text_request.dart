import 'package:json_annotation/json_annotation.dart';
part 'text_to_text_request.g.dart';

@JsonSerializable()
class TextToTextRequest {
  String prompt;
  TextToTextRequest({
    required this.prompt,
  });

  factory TextToTextRequest.fromJson(Map<String, dynamic> json) =>
      _$TextToTextRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TextToTextRequestToJson(this);
}
