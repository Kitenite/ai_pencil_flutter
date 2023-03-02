// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdvancedOptions _$AdvancedOptionsFromJson(Map<String, dynamic> json) =>
    AdvancedOptions(
      seed: json['seed'] as int? ?? 0,
      samplerIndex: json['samplerIndex'] as String? ?? "Euler a",
      cfgScale: (json['cfgScale'] as num?)?.toDouble() ?? 7.0,
      restoreFaces: json['restoreFaces'] as bool? ?? false,
      negativePrompt: json['negativePrompt'] as String? ?? "",
      denoisingStrength: (json['denoisingStrength'] as num?)?.toDouble() ?? 0.7,
    );

Map<String, dynamic> _$AdvancedOptionsToJson(AdvancedOptions instance) =>
    <String, dynamic>{
      'seed': instance.seed,
      'samplerIndex': instance.samplerIndex,
      'cfgScale': instance.cfgScale,
      'restoreFaces': instance.restoreFaces,
      'negativePrompt': instance.negativePrompt,
      'denoisingStrength': instance.denoisingStrength,
    };
