import 'package:json_annotation/json_annotation.dart';
part 'text_to_text_response.g.dart';

@JsonSerializable()
class TextToTextResponse {
  String positive = "";
  String negative = "";

  TextToTextResponse();

  factory TextToTextResponse.fromJson(Map<String, dynamic> json) =>
      _$TextToTextResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TextToTextResponseToJson(this);
}
