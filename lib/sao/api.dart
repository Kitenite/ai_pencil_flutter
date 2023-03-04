// Helper class for making http call to an image to image api
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:ai_pencil/model/api/text_to_text_request.dart';
import 'package:ai_pencil/model/api/text_to_text_response.dart';
import 'package:ai_pencil/utils/constants.dart';
import 'package:ai_pencil/model/api/generate_image_request.dart';
import 'package:ai_pencil/model/api/generate_image_response.dart';
import 'package:ai_pencil/model/drawing/advanced_options.dart';
import 'package:ai_pencil/utils/image_helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class ApiDataAccessor {
  static Future<ui.Image> generateImage(
    String prompt,
    Uint8List? image,
  ) async {
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

    if (response.statusCode == 200) {
      GenerateImageResponse responseObject =
          GenerateImageResponse.fromJson(jsonDecode(response.body));
      ui.Image responseImage =
          await ImageHelper.base64StringToImage(responseObject.image);
      return responseImage;
    } else {
      Logger("ApiDataAccessor").severe(response.body);
      throw Exception('ApiDataAccessor::generateImage Failed to get response.');
    }
  }

  static Future<String> textToText(String input) async {
    var url = Uri.https(Apis.BETA_BASE_API, Apis.BETA_TEXT_TO_TEXT_ROUTE);
    const headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(TextToTextRequest(prompt: input).toJson()),
    );

    if (response.statusCode == 200) {
      TextToTextResponse responseObject =
          TextToTextResponse.fromJson(jsonDecode(response.body));
      return responseObject.response;
    } else {
      Logger("ApiDataAccessor").severe(response.body);
      throw Exception('ApiDataAccessor::textToText Failed to get response.');
    }
  }
}
