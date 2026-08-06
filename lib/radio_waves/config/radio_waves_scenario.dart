import 'package:flutter/foundation.dart';

/// Radio-waves screen type.
enum RWScreen { singleAntenna }

RWScreen _parseScreen(String s) {
  switch (s) {
    case 'singleAntenna':
      return RWScreen.singleAntenna;
    default:
      throw ArgumentError('Unknown RWScreen: $s');
  }
}

/// Parameter range descriptor.
@immutable
class RWParamRange {
  final double min, max, step;
  final String? unit;
  const RWParamRange({required this.min, required this.max, required this.step, this.unit});
  factory RWParamRange.fromJson(Map<String, dynamic> json) => RWParamRange(
    min: (json['min'] as num).toDouble(),
    max: (json['max'] as num).toDouble(),
    step: (json['step'] as num).toDouble(),
    unit: json['unit'] as String?,
  );
}

/// Success criterion for a radio-waves scenario.
class RWCriterionConfig {
  final String id, type, description;
  final Map<String, dynamic> params;
  const RWCriterionConfig({required this.id, required this.type, required this.description, this.params = const {}});
  factory RWCriterionConfig.fromJson(Map<String, dynamic> json) => RWCriterionConfig(
    id: json['id'] as String,
    type: json['type'] as String,
    description: json['description'] as String,
    params: (json['params'] as Map<String, dynamic>?) ?? {},
  );
}

/// Hint message with trigger condition.
class RWHintConfig {
  final String trigger, message;
  const RWHintConfig({required this.trigger, required this.message});
  factory RWHintConfig.fromJson(Map<String, dynamic> json) => RWHintConfig(
    trigger: json['trigger'] as String,
    message: json['message'] as String,
  );
}

/// Radio-waves scenario data model.
@immutable
class RadioWavesScenario {
  final String scenarioId, name, description, version;
  final RWScreen screen;
  final double frequency;
  final double amplitude;
  final bool showCurve;
  final bool showArrows;
  final bool dynamicFieldEnabled;
  final RWParamRange frequencyRange;
  final RWParamRange amplitudeRange;
  final List<RWCriterionConfig> successCriteria;
  final List<RWHintConfig> hints;

  const RadioWavesScenario({
    required this.scenarioId,
    required this.name,
    this.description = '',
    this.version = '1.0',
    this.screen = RWScreen.singleAntenna,
    this.frequency = 0.5,
    this.amplitude = 0.5,
    this.showCurve = true,
    this.showArrows = true,
    this.dynamicFieldEnabled = true,
    this.frequencyRange = const RWParamRange(min: 0.05, max: 2.0, step: 0.05),
    this.amplitudeRange = const RWParamRange(min: 0, max: 1, step: 0.05),
    this.successCriteria = const [],
    this.hints = const [],
  });

  factory RadioWavesScenario.fromJson(Map<String, dynamic> json) {
    final ip = json['initialParams'] as Map<String, dynamic>?;
    final pr = json['paramRanges'] as Map<String, dynamic>?;
    return RadioWavesScenario(
      scenarioId: json['scenarioId'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      version: (json['version'] as String?) ?? '1.0',
      screen: json['screen'] != null ? _parseScreen(json['screen'] as String) : RWScreen.singleAntenna,
      frequency: (ip?['frequency'] as num?)?.toDouble() ?? 0.5,
      amplitude: (ip?['amplitude'] as num?)?.toDouble() ?? 0.5,
      showCurve: (ip?['showCurve'] as bool?) ?? true,
      showArrows: (ip?['showArrows'] as bool?) ?? true,
      dynamicFieldEnabled: (ip?['dynamicFieldEnabled'] as bool?) ?? true,
      frequencyRange: _parseFRange(pr),
      amplitudeRange: _parseARange(pr),
      successCriteria: (json['successCriteria'] as List<dynamic>?)?.map((e) => RWCriterionConfig.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      hints: (json['hints'] as List<dynamic>?)?.map((e) => RWHintConfig.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
    );
  }
}

RWParamRange _parseFRange(Map<String, dynamic>? pr) {
  if (pr == null) return const RWParamRange(min: 0.05, max: 2.0, step: 0.05);
  final f = pr['frequency'];
  if (f == null) return const RWParamRange(min: 0.05, max: 2.0, step: 0.05);
  return RWParamRange.fromJson(f as Map<String, dynamic>);
}

RWParamRange _parseARange(Map<String, dynamic>? pr) {
  if (pr == null) return const RWParamRange(min: 0, max: 1, step: 0.05);
  final a = pr['amplitude'];
  if (a == null) return const RWParamRange(min: 0, max: 1, step: 0.05);
  return RWParamRange.fromJson(a as Map<String, dynamic>);
}