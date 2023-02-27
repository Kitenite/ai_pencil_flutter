import 'dart:typed_data';
import 'package:ai_pencil/model/drawing_layer.dart';
import 'package:ai_pencil/serialization/int8_list_converter.dart';
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

  @Int8ListConverter()
  Int8List? thumbnailImageBytes;
  double aspectWidth;
  double aspectHeight;

  // Optional
  // TODO: Optionals are dangerous if we're rebuilding the project on callbacks. Easy to miss reassigning.
  // Consider having a callback to return a clone of the project

  String prompt;
  int activeLayerIndex;

  //String selectedArtTypeKey;
  //List<String> selectedSubstyleKeys;

  DrawingProject({
    required this.title,
    required this.layers,
    required this.aspectWidth,
    required this.aspectHeight,
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
