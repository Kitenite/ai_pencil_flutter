import 'dart:ui';

class Constants {
  static const String PROJECTS_KEY = 'projects';
}

class CustomColors {
  static const canvasColor = Color.fromARGB(255, 255, 255, 255);
}

class Routes {
  static const LANDING_SCREEN_ROUTE = "landing";
  static const SELECT_SCREEN_ROUTE = "select";
  static const DRAW_SCREEN_ROUTE = "draw";
  static const INFERENCE_SCREEN_ROUTE = "inference";
  static const INFERENCE_COMPLETE_SCREEN_ROUTE = "inference_complete";
}

class Apis {
  static const BETA_BASE_API = "icgts00cl0.execute-api.us-east-1.amazonaws.com";
  static const BETA_GENERATE_IMAGE_ROUTE = "beta/generate-image";
  static const BETA_TEXT_TO_TEXT_ROUTE = "beta/text-to-text";
  static const BETA_UPLOAD_IMAGE_ROUTE = "beta/upload-image";
  static const BETA_CONTROLNET_ROUTE = "beta/controlnet";
  static const BETA_PROMPT_STYLES_ROUTE = "beta/prompt-styles";

  static const PROD_BASE_API = "8p4dffq0ke.execute-api.us-west-2.amazonaws.com";
  static const PROD_GENERATE_IMAGE_ROUTE = "prod/generate-image";
  static const PROD_TEXT_TO_TEXT_ROUTE = "prod/text-to-text";
  static const PROD_PROMPT_STYLES_ROUTE = "prod/prompt-styles";
}

class StableDiffusionStandards {
  static const MAX_DIMENSION = 512;
  static const MULTIPLE = 64;
}
