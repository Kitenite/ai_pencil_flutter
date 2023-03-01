// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_layer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrawingLayer _$DrawingLayerFromJson(Map<String, dynamic> json) => DrawingLayer(
      title: json['title'] as String? ?? "Layer 1",
      sketches: (json['sketches'] as List<dynamic>?)
              ?.map((e) => Sketch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      redoStack: (json['redoStack'] as List<dynamic>?)
              ?.map((e) => Sketch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isVisible: json['isVisible'] as bool? ?? true,
    )..image = const Uint8ListConverter().fromJson(json['image'] as List);

Map<String, dynamic> _$DrawingLayerToJson(DrawingLayer instance) =>
    <String, dynamic>{
      'image': const Uint8ListConverter().toJson(instance.image),
      'title': instance.title,
      'sketches': instance.sketches,
      'redoStack': instance.redoStack,
      'isVisible': instance.isVisible,
    };
