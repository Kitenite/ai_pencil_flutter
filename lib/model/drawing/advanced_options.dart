import 'package:ai_pencil/model/drawing/sampler.dart';
import 'package:json_annotation/json_annotation.dart';
part 'advanced_options.g.dart';

@JsonSerializable()
class AdvancedOptions {
  int seed = 0;
  String samplerIndex = Sampler.Euler_a.toString();
  double cfgScale = 7.0;
  bool restoreFaces = false;
  String negativePrompt = "";
  double denoisingStrength = 0.7;
  /* Params that will significantly increase computation cost */
  //int steps;
  //int width;
  //int height;

  AdvancedOptions({
    this.seed = 0,
    this.samplerIndex = "Euler a",
    this.cfgScale = 7.0,
    this.restoreFaces = false,
    this.negativePrompt = "",
    this.denoisingStrength = 0.7,
    //this.steps,
    //this.width,
    //this.height,
  });

  factory AdvancedOptions.fromJson(Map<String, dynamic> json) =>
      _$AdvancedOptionsFromJson(json);
  Map<String, dynamic> toJson() => _$AdvancedOptionsToJson(this);
}
