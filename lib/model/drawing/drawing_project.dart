import 'dart:typed_data';
import 'package:ai_pencil/model/drawing/advanced_options.dart';
import 'package:ai_pencil/model/drawing/drawing_layer.dart';
import 'package:ai_pencil/serialization/uint8_list_converter.dart';
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

  @Uint8ListConverter()
  Uint8List? thumbnailImageBytes;
  double aspectWidth;
  double aspectHeight;
  AdvancedOptions advancedOptions;

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
