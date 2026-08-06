import 'package:flutter/material.dart';

/// Color vision screen type.
enum CVScreen { rgb, singleBulb }

CVScreen _parseScreen(String s) {
  switch (s) {
    case 'rgb': return CVScreen.rgb;
    case 'singleBulb': return CVScreen.singleBulb;
    default: throw ArgumentError('Unknown CVScreen: $s');
  }
}

/// Color vision rendering mode.
enum CVBeamMode { photons, wave }

CVBeamMode _parseBeamMode(String s) {
  switch (s) {
    case 'photons': return CVBeamMode.photons;
    case 'wave': return CVBeamMode.wave;
    default: return CVBeamMode.photons;
  }
}

/// Success criterion for a color-vision scenario.
class CVCriterionConfig {
  final String id, type, description;
  final Map<String, dynamic> params;
  const CVCriterionConfig({required this.id, required this.type, required this.description, this.params = const {}});
  factory CVCriterionConfig.fromJson(Map<String, dynamic> json) => CVCriterionConfig(
    id: json['id'] as String, type: json['type'] as String,
    description: json['description'] as String, params: (json['params'] as Map<String, dynamic>?) ?? {});
}

/// Hint message with trigger condition.
class CVHintConfig {
  final String trigger, message;
  const CVHintConfig({required this.trigger, required this.message});
  factory CVHintConfig.fromJson(Map<String, dynamic> json) => CVHintConfig(
    trigger: json['trigger'] as String, message: json['message'] as String);
}

/// Color-vision scenario data model.
///
/// Parsed from JSON scenario files. Carries initialParameters for
/// both screens; the screen type determines which subset is active.
@immutable
class ColorVisionScenario {
  final String scenarioId, name, description, version;
  final CVScreen screen;
  final CVBeamMode beamMode;
  final double redIntensity, greenIntensity, blueIntensity;
  final String filterType; // none, red, green, blue, custom
  final double customFilterR, customFilterG, customFilterB;
  final bool showPhotonView, showBeamView;
  final double personPosition;
  final List<CVCriterionConfig> successCriteria;
  final List<CVHintConfig> hints;

  const ColorVisionScenario({
    required this.scenarioId,
    required this.name,
    required this.screen,
    this.description = '',
    this.version = '1.0',
    this.beamMode = CVBeamMode.photons,
    this.redIntensity = 100,
    this.greenIntensity = 100,
    this.blueIntensity = 100,
    this.filterType = 'none',
    this.customFilterR = 1.0,
    this.customFilterG = 1.0,
    this.customFilterB = 1.0,
    this.showPhotonView = true,
    this.showBeamView = false,
    this.personPosition = 300,
    this.successCriteria = const [],
    this.hints = const [],
  });

  factory ColorVisionScenario.fromJson(Map<String, dynamic> json) {
    final ip = json['initialParams'] as Map<String, dynamic>?;
    final cf = ip?['customFilter'] as Map<String, dynamic>?;
    return ColorVisionScenario(
      scenarioId: json['scenarioId'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      version: (json['version'] as String?) ?? '1.0',
      screen: _parseScreen(json['screen'] as String),
      beamMode: json['beamMode'] != null ? _parseBeamMode(json['beamMode'] as String) : CVBeamMode.photons,
      redIntensity: (ip?['redIntensity'] as num?)?.toDouble() ?? 100,
      greenIntensity: (ip?['greenIntensity'] as num?)?.toDouble() ?? 100,
      blueIntensity: (ip?['blueIntensity'] as num?)?.toDouble() ?? 100,
      filterType: (ip?['filterType'] as String?) ?? 'none',
      customFilterR: (cf?['redPass'] as num?)?.toDouble() ?? 1.0,
      customFilterG: (cf?['greenPass'] as num?)?.toDouble() ?? 1.0,
      customFilterB: (cf?['bluePass'] as num?)?.toDouble() ?? 1.0,
      showPhotonView: (ip?['showPhotonView'] as bool?) ?? true,
      showBeamView: (ip?['showBeamView'] as bool?) ?? false,
      personPosition: (ip?['personPosition'] as num?)?.toDouble() ?? 300,
      successCriteria: (json['successCriteria'] as List<dynamic>?)?.map((e) => CVCriterionConfig.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      hints: (json['hints'] as List<dynamic>?)?.map((e) => CVHintConfig.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
    );
  }
}
