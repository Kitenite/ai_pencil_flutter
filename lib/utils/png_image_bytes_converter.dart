import 'package:ai_pencil/model/image/types.dart';
import 'package:json_annotation/json_annotation.dart';

class PngImageBytesConverter
    implements JsonConverter<PngImageBytes, List<dynamic>> {
  const PngImageBytesConverter();

  @override
  PngImageBytes fromJson(List<dynamic> json) {
    return PngImageBytes.fromList(List<int>.from(json));
  }

  @override
  List<int> toJson(PngImageBytes object) {
    return object.toList();
  }
}

class PngImageBytesConverterNullable
    implements JsonConverter<PngImageBytes?, List<dynamic>?> {
  const PngImageBytesConverterNullable();

  @override
  PngImageBytes? fromJson(List<dynamic>? json) {
    if (json == null) {
      return null;
    }
    return PngImageBytes.fromList(List<int>.from(json));
  }

  @override
  List<int>? toJson(PngImageBytes? object) {
    if (object == null) {
      return null;
    }
    return object.toList();
  }
}
