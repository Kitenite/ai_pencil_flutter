// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_styles_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromptStylesResponse _$PromptStylesResponseFromJson(
        Map<String, dynamic> json) =>
    PromptStylesResponse(
      promptStyles: (json['promptStyles'] as List<dynamic>)
          .map((e) => PromptStyle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PromptStylesResponseToJson(
        PromptStylesResponse instance) =>
    <String, dynamic>{
      'promptStyles': instance.promptStyles,
    };
