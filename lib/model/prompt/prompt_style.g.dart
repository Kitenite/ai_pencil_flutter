// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromptStyle _$PromptStyleFromJson(Map<String, dynamic> json) => PromptStyle(
      key: json['key'] as String,
      prefix: json['prefix'] as String?,
      suffix: json['suffix'] as String?,
      imageUrl: json['imageUrl'] as String?,
      substyles: (json['substyles'] as List<dynamic>?)
          ?.map((e) => PromptSubstyle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PromptStyleToJson(PromptStyle instance) =>
    <String, dynamic>{
      'key': instance.key,
      'prefix': instance.prefix,
      'suffix': instance.suffix,
      'imageUrl': instance.imageUrl,
      'substyles': instance.substyles,
    };
