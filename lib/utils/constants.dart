import 'dart:ui';

class Constants {
  static const String PROJECTS_KEY = 'projects';
}

class CustomColors {
  static const canvasColor = Color.fromARGB(255, 255, 255, 255);
}

class Routes {
  static const SELECT_SCREEN_ROUTE = "select";
  static const DRAW_SCREEN_ROUTE = "draw";
  static const INFERENCE_SCREEN_ROUTE = "inference";
}

class Apis {
  static const BETA_BASE_API = "icgts00cl0.execute-api.us-east-1.amazonaws.com";
  static const BETA_GENERATE_IMAGE_ROUTE = "beta/generate-image";
  static const BETA_TEXT_TO_TEXT_ROUTE = "beta/text-to-text";

  static const PROD_BASE_API = "8p4dffq0ke.execute-api.us-west-2.amazonaws.com";
  static const PROD_GENERATE_IMAGE_ROUTE = "prod/generate-image";
  static const PROD_TEXT_TO_TEXT_ROUTE = "prod/text-to-text";
}