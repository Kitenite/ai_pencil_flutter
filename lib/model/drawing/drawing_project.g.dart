// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrawingProject _$DrawingProjectFromJson(Map<String, dynamic> json) =>
    DrawingProject(
      title: json['title'] as String,
      layers: (json['layers'] as List<dynamic>)
          .map((e) => DrawingLayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      aspectWidth: (json['aspectWidth'] as num).toDouble(),
      aspectHeight: (json['aspectHeight'] as num).toDouble(),
      advancedOptions: AdvancedOptions.fromJson(
          json['advancedOptions'] as Map<String, dynamic>),
      thumbnailImageBytes: _$JsonConverterFromJson<List<dynamic>, Uint8List>(
          json['thumbnailImageBytes'], const Uint8ListConverter().fromJson),
      prompt: json['prompt'] as String? ?? "",
      activeLayerIndex: json['activeLayerIndex'] as int? ?? 0,
    )
      ..id = json['id'] as String
      ..createdDate = DateTime.parse(json['createdDate'] as String);

Map<String, dynamic> _$DrawingProjectToJson(DrawingProject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdDate': instance.createdDate.toIso8601String(),
      'title': instance.title,
      'layers': instance.layers,
      'thumbnailImageBytes': _$JsonConverterToJson<List<dynamic>, Uint8List>(
          instance.thumbnailImageBytes, const Uint8ListConverter().toJson),
      'aspectWidth': instance.aspectWidth,
      'aspectHeight': instance.aspectHeight,
      'advancedOptions': instance.advancedOptions,
      'prompt': instance.prompt,
      'activeLayerIndex': instance.activeLayerIndex,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
