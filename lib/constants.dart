import 'dart:ui';

class CustomColors {
  static const canvasColor = Color.fromARGB(255, 255, 255, 255);
}

class Routes {
  static const SELECT_SCREEN_ROUTE = "select";
  static const DRAW_SCREEN_ROUTE = "draw";
  static const INFERENCE_SCREEN_ROUTE = "inference";
}

class Apis {
  static const BASE_API = "waw35mmbsj.execute-api.us-east-1.amazonaws.com/dev";
  static const IMAGE_TO_IMAGE_ROUTE = "inference-v2";
}
