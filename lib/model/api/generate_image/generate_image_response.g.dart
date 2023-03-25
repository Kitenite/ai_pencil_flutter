// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_image_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateImageResponse _$GenerateImageResponseFromJson(
        Map<String, dynamic> json) =>
    GenerateImageResponse(
      image: json['image'] as String?,
      error: json['error'] as String?,
      filtered: json['filtered'] as bool?,
    );

Map<String, dynamic> _$GenerateImageResponseToJson(
        GenerateImageResponse instance) =>
    <String, dynamic>{
      'image': instance.image,
      'error': instance.error,
      'filtered': instance.filtered,
    };
