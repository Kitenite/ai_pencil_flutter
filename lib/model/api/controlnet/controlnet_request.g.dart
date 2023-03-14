// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'controlnet_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ControlNetRequest _$ControlNetRequestFromJson(Map<String, dynamic> json) =>
    ControlNetRequest(
      prompt: json['prompt'] as String,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$ControlNetRequestToJson(ControlNetRequest instance) =>
    <String, dynamic>{
      'image': instance.image,
      'prompt': instance.prompt,
    };
