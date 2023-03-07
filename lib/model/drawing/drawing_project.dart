import 'dart:typed_data';
import 'package:ai_pencil/model/drawing/advanced_options.dart';
import 'package:ai_pencil/model/drawing/drawing_layer.dart';
import 'package:ai_pencil/model/image/types.dart';
import 'package:ai_pencil/utils/png_image_bytes_converter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
part 'drawing_project.g.dart';

@JsonSerializable()
class DrawingProject {
  String id = const Uuid().v4();
  DateTime createdDate = DateTime.now();

  // Required
  String title;
  List<DrawingLayer> layers;

  @PngImageBytesConverter()
  PngImageBytes? thumbnailImageBytes;

  double aspectWidth;
  double aspectHeight;
  AdvancedOptions advancedOptions;
  int backgroundColor;

  // Optional
  String prompt;
  int activeLayerIndex;

  //String selectedArtTypeKey;
  //List<String> selectedSubstyleKeys;

  DrawingProject({
    required this.title,
    required this.layers,
    required this.aspectWidth,
    required this.aspectHeight,
    required this.advancedOptions,
    required this.backgroundColor,
    this.thumbnailImageBytes,
    this.prompt = "",
    this.activeLayerIndex = 0,
    //this.selectedArtTypeKey = "None",
    //this.selectedSubstyleKeys = const ["None", "None", "None", "None"],
  });

  factory DrawingProject.fromJson(Map<String, dynamic> json) =>
      _$DrawingProjectFromJson(json);
  Map<String, dynamic> toJson() => _$DrawingProjectToJson(this);
}
