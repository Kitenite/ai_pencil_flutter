// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_substyle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromptSubstyle _$PromptSubstyleFromJson(Map<String, dynamic> json) =>
    PromptSubstyle(
      key: json['key'] as String,
      values: (json['values'] as List<dynamic>)
          .map((e) => PromptArtStyle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PromptSubstyleToJson(PromptSubstyle instance) =>
    <String, dynamic>{
      'key': instance.key,
      'values': instance.values,
    };
