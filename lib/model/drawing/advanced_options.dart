enum Sampler {
  Euler_a,
  LMS,
  DPM_fast,
  DDIM,
}

extension SamplerExtension on Sampler {
  String get value {
    switch (this) {
      case Sampler.Euler_a:
        return 'Euler a';
      case Sampler.LMS:
        return 'LMS';
      case Sampler.DPM_fast:
        return 'DPM fast';
      case Sampler.DDIM:
        return 'DDIM';
    }
  }

  static Sampler fromValue(String value) {
    switch (value) {
      case 'Euler a':
        return Sampler.Euler_a;
      case 'LMS':
        return Sampler.LMS;
      case 'DPM fast':
        return Sampler.DPM_fast;
      case 'DDIM':
        return Sampler.DDIM;
      default:
        return Sampler.Euler_a;
    }
  }
}

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
}
