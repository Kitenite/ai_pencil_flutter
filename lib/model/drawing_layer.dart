import 'package:ai_pencil/drawing_canvas/models/sketch.dart';
import 'package:json_annotation/json_annotation.dart';
part 'drawing_layer.g.dart';

@JsonSerializable()
class DrawingLayer {
  //@Int8ListConverter()
  //Int8List image = Int8List(0);

  // Required
  String title;
  List<Sketch> sketches;

  // Optional
  List<Sketch> redoStack;
  bool isVisible;
  
  DrawingLayer({
    this.title = "Layer 1",
    this.sketches = const [],
    this.redoStack = const [],
    this.isVisible = true,
  });

  factory DrawingLayer.fromJson(Map<String, dynamic> json) =>
      _$DrawingLayerFromJson(json);
  Map<String, dynamic> toJson() => _$DrawingLayerToJson(this);
}
