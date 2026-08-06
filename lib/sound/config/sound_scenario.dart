import 'package:flutter/foundation.dart';

/// Sound screen type.
enum SoundScreenType { singleSource }

SoundScreenType _parseScreen(String s) {
  switch (s) {
    case 'singleSource':
      return SoundScreenType.singleSource;
    default:
      throw ArgumentError('Unknown SoundScreenType: $s');
  }
}

/// Parameter range descriptor.
@immutable
class ParamRange {
  final double min, max, step;
  final String? unit;
  const ParamRange({required this.min, required this.max, required this.step, this.unit});
  factory ParamRange.fromJson(Map<String, dynamic> json) => ParamRange(
    min: (json['min'] as num).toDouble(),
    max: (json['max'] as num).toDouble(),
    step: (json['step'] as num).toDouble(),
    unit: json['unit'] as String?,
  );
}

/// Success criterion for a sound scenario.
class SoundCriterionConfig {
  final String id, type, description;
  final Map<String, dynamic> params;
  const SoundCriterionConfig({
    required this.id,
    required this.type,
    required this.description,
    this.params = const {},
  });
  factory SoundCriterionConfig.fromJson(Map<String, dynamic> json) =>
      SoundCriterionConfig(
        id: json['id'] as String,
        type: json['type'] as String,
        description: json['description'] as String,
        params: (json['params'] as Map<String, dynamic>?) ?? {},
      );
}

/// Hint message with trigger condition.
class SoundHintConfig {
  final String trigger, message;
  const SoundHintConfig({required this.trigger, required this.message});
  factory SoundHintConfig.fromJson(Map<String, dynamic> json) =>
      SoundHintConfig(
        trigger: json['trigger'] as String,
        message: json['message'] as String,
      );
}

/// Sound wave scenario data model.
///
/// Parsed from JSON scenario files under assets/scenarios/sound/.
@immutable
class SoundScenario {
  final String scenarioId, name, description, version;
  final SoundScreenType screen;
  final double frequency;
  final double amplitude;
  final ParamRange frequencyRange;
  final ParamRange amplitudeRange;
  final List<SoundCriterionConfig> successCriteria;
  final List<SoundHintConfig> hints;

  const SoundScenario({
    required this.scenarioId,
    required this.name,
    this.description = '',
    this.version = '1.0',
    this.screen = SoundScreenType.singleSource,
    this.frequency = 500,
    this.amplitude = 0.5,
    this.frequencyRange = const ParamRange(min: 0, max: 1000, step: 10, unit: 'Hz'),
    this.amplitudeRange = const ParamRange(min: 0, max: 1, step: 0.05),
    this.successCriteria = const [],
    this.hints = const [],
  });

  factory SoundScenario.fromJson(Map<String, dynamic> json) {
    final ip = json['initialParams'] as Map<String, dynamic>?;
    final pr = json['paramRanges'] as Map<String, dynamic>?;

    return SoundScenario(
      scenarioId: json['scenarioId'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      version: (json['version'] as String?) ?? '1.0',
      screen: json['screen'] != null
          ? _parseScreen(json['screen'] as String)
          : SoundScreenType.singleSource,
      frequency: (ip?['frequency'] as num?)?.toDouble() ?? 500,
      amplitude: (ip?['amplitude'] as num?)?.toDouble() ?? 0.5,
      frequencyRange: _parseFRange(pr),
      amplitudeRange: _parseARange(pr),
      successCriteria: (json['successCriteria'] as List<dynamic>?)
              ?.map((e) => SoundCriterionConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hints: (json['hints'] as List<dynamic>?)
              ?.map((e) => SoundHintConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

ParamRange _parseFRange(Map<String, dynamic>? pr) {
  if (pr == null) return const ParamRange(min: 0, max: 1000, step: 10, unit: 'Hz');
  final f = pr['frequency'];
  if (f == null) return const ParamRange(min: 0, max: 1000, step: 10, unit: 'Hz');
  return ParamRange.fromJson(f as Map<String, dynamic>);
}

ParamRange _parseARange(Map<String, dynamic>? pr) {
  if (pr == null) return const ParamRange(min: 0, max: 1, step: 0.05);
  final a = pr['amplitude'];
  if (a == null) return const ParamRange(min: 0, max: 1, step: 0.05);
  return ParamRange.fromJson(a as Map<String, dynamic>);
}