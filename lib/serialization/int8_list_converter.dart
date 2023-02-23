import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

class Int8ListConverter implements JsonConverter<Int8List, List<int>> {
  const Int8ListConverter();

  @override
  Int8List fromJson(List<int> json) {
    return Int8List.fromList(json);
  }

  @override
  List<int> toJson(Int8List object) {
    return object.toList();
  }
}