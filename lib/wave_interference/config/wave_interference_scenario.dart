import 'package:flutter/foundation.dart';

/// Wave-interference screen type.
enum WIScreen { waterDoubleSlit }

WIScreen _parseScreen(String s) {
  switch (s) {
    case 'waterDoubleSlit':
      return WIScreen.waterDoubleSlit;
    default:
      throw ArgumentError('Unknown WIScreen: $s');
  }
}

/// Parameter range descriptor.
@immutable
class WIParamRange {
  final double min, max, step;
  final String? unit;
  const WIParamRange({required this.min, required this.max, required this.step, this.unit});
  factory WIParamRange.fromJson(Map<String, dynamic> json) => WIParamRange(
    min: (json['min'] as num).toDouble(),
    max: (json['max'] as num).toDouble(),
    step: (json['step'] as num).toDouble(),
    unit: json['unit'] as String?,
  );
}

/// Success criterion for a wave-interference scenario.
class WICriterionConfig {
  final String id, type, description;
  final Map<String, dynamic> params;
  const WICriterionConfig({required this.id, required this.type, required this.description, this.params = const {}});
  factory WICriterionConfig.fromJson(Map<String, dynamic> json) => WICriterionConfig(
    id: json['id'] as String,
    type: json['type'] as String,
    description: json['description'] as String,
    params: (json['params'] as Map<String, dynamic>?) ?? {},
  );
}

/// Hint message with trigger condition.
class WIHintConfig {
  final String trigger, message;
  const WIHintConfig({required this.trigger, required this.message});
  factory WIHintConfig.fromJson(Map<String, dynamic> json) => WIHintConfig(
    trigger: json['trigger'] as String,
    message: json['message'] as String,
  );
}

/// Wave-interference scenario data model.
@immutable
class WaveInterferenceScenario {
  final String scenarioId, name, description, version;
  final WIScreen screen;
  final double frequency, amplitude;
  final bool barrierEnabled;
  final int slitSize, slitSeparation;
  final WIParamRange frequencyRange, amplitudeRange;
  final WIParamRange? slitSizeRange, slitSeparationRange;
  final List<WICriterionConfig> successCriteria;
  final List<WIHintConfig> hints;

  const WaveInterferenceScenario({
    required this.scenarioId,
    required this.name,
    this.description = '',
    this.version = '1.0',
    this.screen = WIScreen.waterDoubleSlit,
    this.frequency = 0.4,
    this.amplitude = 1.5,
    this.barrierEnabled = true,
    this.slitSize = 10,
    this.slitSeparation = 24,
    this.frequencyRange = const WIParamRange(min: 0.1, max: 1.0, step: 0.05),
    this.amplitudeRange = const WIParamRange(min: 0.2, max: 3.0, step: 0.1),
    this.slitSizeRange,
    this.slitSeparationRange,
    this.successCriteria = const [],
    this.hints = const [],
  });

  factory WaveInterferenceScenario.fromJson(Map<String, dynamic> json) {
    final ip = json['initialParams'] as Map<String, dynamic>?;
    final pr = json['paramRanges'] as Map<String, dynamic>?;
    return WaveInterferenceScenario(
      scenarioId: json['scenarioId'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      version: (json['version'] as String?) ?? '1.0',
      screen: json['screen'] != null ? _parseScreen(json['screen'] as String) : WIScreen.waterDoubleSlit,
      frequency: (ip?['frequency'] as num?)?.toDouble() ?? 0.4,
      amplitude: (ip?['amplitude'] as num?)?.toDouble() ?? 1.5,
      barrierEnabled: (ip?['barrierEnabled'] as bool?) ?? true,
      slitSize: (ip?['slitSize'] as num?)?.toInt() ?? 10,
      slitSeparation: (ip?['slitSeparation'] as num?)?.toInt() ?? 24,
      frequencyRange: _parseRange(pr, 'frequency', 0.1, 1.0, 0.05),
      amplitudeRange: _parseRange(pr, 'amplitude', 0.2, 3.0, 0.1),
      slitSizeRange: _parseRangeOrNull(pr, 'slitSize'),
      slitSeparationRange: _parseRangeOrNull(pr, 'slitSeparation'),
      successCriteria: (json['successCriteria'] as List<dynamic>?)?.map((e) => WICriterionConfig.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      hints: (json['hints'] as List<dynamic>?)?.map((e) => WIHintConfig.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
    );
  }
}

WIParamRange _parseRange(Map<String, dynamic>? pr, String key, double defMin, double defMax, double defStep) {
  if (pr == null) return WIParamRange(min: defMin, max: defMax, step: defStep);
  final v = pr[key];
  if (v == null) return WIParamRange(min: defMin, max: defMax, step: defStep);
  return WIParamRange.fromJson(v as Map<String, dynamic>);
}

WIParamRange? _parseRangeOrNull(Map<String, dynamic>? pr, String key) {
  if (pr == null) return null;
  final v = pr[key];
  if (v == null) return null;
  return WIParamRange.fromJson(v as Map<String, dynamic>);
}