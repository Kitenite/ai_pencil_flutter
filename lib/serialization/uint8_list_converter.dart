import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

class Uint8ListConverter implements JsonConverter<Uint8List, List<dynamic>> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(List<dynamic> json) {
    return Uint8List.fromList(List<int>.from(json));
  }

  @override
  List<int> toJson(Uint8List object) {
    return object.toList();
  }
}