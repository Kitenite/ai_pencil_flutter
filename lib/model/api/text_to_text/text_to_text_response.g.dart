// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_to_text_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextToTextResponse _$TextToTextResponseFromJson(Map<String, dynamic> json) =>
    TextToTextResponse()
      ..positive = json['positive'] as String
      ..negative = json['negative'] as String;

Map<String, dynamic> _$TextToTextResponseToJson(TextToTextResponse instance) =>
    <String, dynamic>{
      'positive': instance.positive,
      'negative': instance.negative,
    };
