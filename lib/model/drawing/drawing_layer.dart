import 'package:ai_pencil/model/drawing_canvas/sketch.dart';
import 'package:ai_pencil/model/image/types.dart';
import 'package:ai_pencil/utils/png_image_bytes_converter.dart';
import 'package:ai_pencil/utils/image_helpers.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'drawing_layer.g.dart';

@JsonSerializable()
class DrawingLayer {
  @PngImageBytesConverter()
  PngImageBytes image = PngImageBytes.fromList([]);

  // Required
  String title;
  List<Sketch> sketches;

  // Optional
  List<Sketch> redoStack;
  bool isVisible;
  PngImageBytes? backgroundImage;

  DrawingLayer({
    this.title = "Layer 1",
    this.sketches = const [],
    this.redoStack = const [],
    this.isVisible = true,
    this.backgroundImage,
  });

  PngImageBytes getImagePngBytes() {
    return image;
  }

  void updateImage(Size? size) {
    if (size != null) {
      ImageHelper.getPngBytesFromSketches(sketches, size, null).then((value) {
        image = value!;
      });
    }
  }

  factory DrawingLayer.fromJson(Map<String, dynamic> json) =>
      _$DrawingLayerFromJson(json);
  Map<String, dynamic> toJson() => _$DrawingLayerToJson(this);
}
