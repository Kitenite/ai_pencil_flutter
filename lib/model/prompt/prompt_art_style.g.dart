// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_art_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromptArtStyle _$PromptArtStyleFromJson(Map<String, dynamic> json) =>
    PromptArtStyle(
      key: json['key'] as String,
      prefix: json['prefix'] as String?,
      suffix: json['suffix'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$PromptArtStyleToJson(PromptArtStyle instance) =>
    <String, dynamic>{
      'key': instance.key,
      'prefix': instance.prefix,
      'suffix': instance.suffix,
      'imageUrl': instance.imageUrl,
    };
