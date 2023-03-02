// Helper class for making http call to an image to image api
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:ai_pencil/constants.dart';
import 'package:ai_pencil/model/api/generate_image_request.dart';
import 'package:ai_pencil/model/api/generate_image_response.dart';
import 'package:ai_pencil/model/drawing/advanced_options.dart';
import 'package:ai_pencil/utils/image_helpers.dart';
import 'package:http/http.dart' as http;

class GenerateImageHelper {
  static Future<ui.Image?> textToImage(
    String prompt,
  ) async {
    // String base64Image = await ImageHelper.imageToBase64String(image);
    var url = Uri.https(Apis.BASE_API, Apis.GENERATE_IMAGE_ROUTE);

    const headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(GenerateImageRequest(
        // image: base64Image,
        prompt: prompt,
        advancedOptions: AdvancedOptions(),
      ).toJson()),
    );

    try {
      GenerateImageResponse responseObject =
          GenerateImageResponse.fromJson(jsonDecode(response.body));
      ui.Image responseImage =
          await ImageHelper.base64StringToImage(responseObject.image);
      return responseImage;
    } catch (e) {
      return null;
    }
  }
}
