// Helper class for making http call to an image to image api
import 'dart:convert';

import 'package:ai_pencil/model/api/text_to_text_request.dart';
import 'package:ai_pencil/model/api/text_to_text_response.dart';
import 'package:ai_pencil/model/image/types.dart';
import 'package:ai_pencil/utils/constants.dart';
import 'package:ai_pencil/model/api/generate_image_request.dart';
import 'package:ai_pencil/model/api/generate_image_response.dart';
import 'package:ai_pencil/model/drawing/advanced_options.dart';
import 'package:ai_pencil/utils/image_helpers.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class ApiDataAccessor {
  static Future<PngImageBytes> generateImage(
    String prompt,
    PngImageBytes? image,
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
      PngImageBytes resized = ImageHelper.resizeImageToMax(image, 64);
      requestBody.image = await ImageHelper.bytesToBase64String(resized);
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody.toJson()),
    );

    if (response.statusCode == 200) {
      GenerateImageResponse responseObject =
          GenerateImageResponse.fromJson(jsonDecode(response.body));
      return ImageHelper.base64StringToBytes(responseObject.image);
    } else {
      Logger("ApiDataAccessor").severe(response.body);
      throw Exception(
        'ApiDataAccessor::generateImage Failed to get response. ${response.body}',
      );
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
      throw Exception(
        'ApiDataAccessor::textToText Failed to get response. ${response.body}',
      );
    }
  }
}
