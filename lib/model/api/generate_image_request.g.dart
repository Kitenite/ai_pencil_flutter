// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_image_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateImageRequest _$GenerateImageRequestFromJson(
        Map<String, dynamic> json) =>
    GenerateImageRequest(
      prompt: json['prompt'] as String,
      advancedOptions: AdvancedOptions.fromJson(
          json['advancedOptions'] as Map<String, dynamic>),
      image: json['image'] as String?,
    );

Map<String, dynamic> _$GenerateImageRequestToJson(
        GenerateImageRequest instance) =>
    <String, dynamic>{
      'image': instance.image,
      'prompt': instance.prompt,
      'advancedOptions': instance.advancedOptions,
    };
