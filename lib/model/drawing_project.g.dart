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
      thumbnailImageBytes: _$JsonConverterFromJson<List<int>, Int8List>(
          json['thumbnailImageBytes'], const Int8ListConverter().fromJson),
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
      'thumbnailImageBytes': _$JsonConverterToJson<List<int>, Int8List>(
          instance.thumbnailImageBytes, const Int8ListConverter().toJson),
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
