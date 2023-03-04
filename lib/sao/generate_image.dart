// Helper class for making http call to an image to image api
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:ai_pencil/utils/constants.dart';
import 'package:ai_pencil/model/api/generate_image_request.dart';
import 'package:ai_pencil/model/api/generate_image_response.dart';
import 'package:ai_pencil/model/drawing/advanced_options.dart';
import 'package:ai_pencil/utils/image_helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class GenerateImageHelper {
  static Future<ui.Image?> generateImage(
    String prompt,
    Uint8List? image,
  ) async {
    // String base64Image = await ImageHelper.imageToBase64String(image);
    var url = Uri.https(Apis.BETA_BASE_API, Apis.BETA_GENERATE_IMAGE_ROUTE);

    const headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    GenerateImageRequest requestBody = GenerateImageRequest(
      prompt: prompt,
      advancedOptions: AdvancedOptions(),
    );
    if (image != null) {
      requestBody.image = await ImageHelper.bytesToBase64String(image);
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody.toJson()),
    );

    if (response.statusCode != 200) {
      Logger("GenerateImageHelper").severe(response.body);
      return null;
    }

    try {
      GenerateImageResponse responseObject =
          GenerateImageResponse.fromJson(jsonDecode(response.body));
      ui.Image responseImage =
          await ImageHelper.base64StringToImage(responseObject.image);
      return responseImage;
    } catch (e) {
      Logger("GenerateImageHelper").severe(e);
      return null;
    }
  }
}
