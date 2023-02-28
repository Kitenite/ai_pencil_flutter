// Helper class for making http call to an image to image api
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:ai_pencil/constants.dart';
import 'package:ai_pencil/model/api/image_to_image_request.dart';
import 'package:ai_pencil/model/api/image_to_image_response.dart';
import 'package:ai_pencil/utils/image_helpers.dart';
import 'package:http/http.dart' as http;

class ImageToImageHelper {
  static Future<ui.Image> imageToImage(ui.Image image, String prompt) async {
    String base64Image = await ImageHelper.imageToBase64String(image);
    var url = Uri.https(Apis.BASE_API, Apis.IMAGE_TO_IMAGE_ROUTE);

    const headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(
          ImageToImageRequest(image: base64Image, prompt: prompt).toJson()),
    );

    try {
      ImageToImageResponse responseObject =
          ImageToImageResponse.fromJson(jsonDecode(response.body));
      ui.Image responseImage =
          await ImageHelper.base64StringToImage(responseObject.image);
      return responseImage;
    } catch (e) {
      return image;
    }
  }
}
