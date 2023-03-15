import 'dart:convert';

import 'package:ai_pencil/model/api/controlnet/controlnet_request.dart';
import 'package:ai_pencil/model/api/controlnet/controlnet_response.dart';
import 'package:ai_pencil/model/api/generate_image/generate_image_error_response.dart';
import 'package:ai_pencil/model/api/prompt_styles_response.dart';
import 'package:ai_pencil/model/api/text_to_text/text_to_text_request.dart';
import 'package:ai_pencil/model/api/text_to_text/text_to_text_response.dart';
import 'package:ai_pencil/model/api/upload_image/upload_image_request.dart';
import 'package:ai_pencil/model/api/generate_image/generate_image_request.dart';
import 'package:ai_pencil/model/api/generate_image/generate_image_response.dart';
import 'package:ai_pencil/model/api/upload_image/upload_image_response.dart';
import 'package:ai_pencil/model/image/types.dart';
import 'package:ai_pencil/model/prompt/prompt_style.dart';
import 'package:ai_pencil/model/drawing/advanced_options.dart';
import 'package:ai_pencil/utils/constants.dart';
import 'package:ai_pencil/utils/image_helpers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:image/image.dart' as IMG;

class ApiDataAccessor {
  static Future<String> uploadImage(PngImageBytes? image) async {
    if (image == null) {
      throw Exception("Image is null");
    }

    var url = Uri.https(Apis.BETA_BASE_API, Apis.BETA_UPLOAD_IMAGE_ROUTE);
    const headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    int multiple = 64;
    Size correctSize = ImageHelper.getNewImageSizeWithMultiple(image, multiple);
    PngImageBytes resized =
        ImageHelper.resizeImageToDimensions(image, correctSize);
    String base64Image = await ImageHelper.bytesToBase64String(resized);
    UploadImageRequest requestBody = UploadImageRequest(image: base64Image);

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody.toJson()),
    );

    if (response.statusCode == 200) {
      UploadImageResponse responseObject =
          UploadImageResponse.fromJson(jsonDecode(response.body));
      return responseObject.url;
    } else {
      GenerateImageErrorResponse responseObject =
          GenerateImageErrorResponse.fromJson(jsonDecode(response.body));
      Logger("ApiDataAccessor").severe(responseObject.error);
      throw Exception(
        responseObject.error,
      );
    }
  }

  static Future<PngImageBytes> controlNet(
    String prompt,
    PngImageBytes? image,
  ) async {
    var url = Uri.https(Apis.BETA_BASE_API, Apis.BETA_CONTROLNET_ROUTE);
    const headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    ControlNetRequest requestBody = ControlNetRequest(
        prompt: prompt, image: await ImageHelper.bytesToBase64String(image!));

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody.toJson()),
    );

    if (response.statusCode == 200) {
      ControlNetResponse responseObject =
          ControlNetResponse.fromJson(jsonDecode(response.body));
      print(responseObject);
      // Get png bytes from image url
      http.Response image_res = await http.get(
        Uri.parse(responseObject.image),
      );
      return image_res.bodyBytes;
    } else {
      Logger("ApiDataAccessor::controlNet").severe("Error: ${response.body}");
      throw Exception(response.body);
    }
  }

  static Future<PngImageBytes> generateImage(
    String prompt,
    PngImageBytes? image,
    bool useImage, {
    PngImageBytes? mask,
  }) async {
    var url = Uri.https(Apis.BETA_BASE_API, Apis.BETA_GENERATE_IMAGE_ROUTE);
    const headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    Size desiredImageSize = Size(512, 512);
    int multiple = 64;

    if (image != null) {
      desiredImageSize =
          ImageHelper.getNewImageSizeWithMultiple(image, multiple);
    }

    GenerateImageRequest requestBody = GenerateImageRequest(
      prompt: prompt,
      advancedOptions: AdvancedOptions(),
      width: desiredImageSize.width.toInt(),
      height: desiredImageSize.height.toInt(),
    );

    if (useImage && image != null) {
      PngImageBytes resized =
          ImageHelper.resizeImageToDimensions(image, desiredImageSize);
      requestBody.image = await ImageHelper.bytesToBase64String(resized);
    }

    // Inpainting
    if (useImage && mask != null) {
      PngImageBytes resized =
          ImageHelper.resizeImageToDimensions(mask, desiredImageSize);
      requestBody.mask = await ImageHelper.bytesToBase64String(resized);
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
      GenerateImageErrorResponse responseObject =
          GenerateImageErrorResponse.fromJson(jsonDecode(response.body));
      Logger("ApiDataAccessor").severe(responseObject.error);
      throw Exception(
        responseObject.error,
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

  static Future<List<PromptStyle>> getPromptStyles() async {
    var url = Uri.https(Apis.BETA_BASE_API, Apis.BETA_PROMPT_STYLES_ROUTE);
    const headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      PromptStylesResponse responseObject =
          PromptStylesResponse.fromJson(jsonDecode(response.body));
      return responseObject.promptStyles;
    } else {
      Logger("ApiDataAccessor").severe(response.body);
      throw Exception(
        'ApiDataAccessor::promptStyles Failed to get response. ${response.body}',
      );
    }
  }
}
