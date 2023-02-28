// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_to_image_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageToImageRequest _$ImageToImageRequestFromJson(Map<String, dynamic> json) =>
    ImageToImageRequest(
      image: json['image'] as String,
      prompt: json['prompt'] as String,
    );

Map<String, dynamic> _$ImageToImageRequestToJson(
        ImageToImageRequest instance) =>
    <String, dynamic>{
      'image': instance.image,
      'prompt': instance.prompt,
    };
