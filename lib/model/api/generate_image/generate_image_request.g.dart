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
      width: json['width'] as int? ?? 512,
      height: json['height'] as int? ?? 512,
      image: json['image'] as String?,
      mask: json['mask'] as String?,
    );

Map<String, dynamic> _$GenerateImageRequestToJson(
        GenerateImageRequest instance) =>
    <String, dynamic>{
      'image': instance.image,
      'mask': instance.mask,
      'prompt': instance.prompt,
      'width': instance.width,
      'height': instance.height,
      'advancedOptions': instance.advancedOptions,
    };
