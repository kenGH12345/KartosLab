import '../waves_intro_constants.dart';

enum SceneKind { water, sound, light }

enum DisturbanceType { continuous, pulse }

enum SoundViewType { waves, particles, both }

/// Per-medium configuration from PhET `WavesModel.ts` scene options.
class SceneConfig {
  const SceneConfig({
    required this.kind,
    required this.frequencyMin,
    required this.frequencyMax,
    required this.waveSpeed,
    required this.timeScaleFactor,
    required this.waveAreaWidth,
    required this.frequencyUnitLabel,
    required this.positionUnitLabel,
    required this.timeUnitLabel,
    required this.graphVerticalAxisLabel,
  });

  final SceneKind kind;
  final double frequencyMin;
  final double frequencyMax;
  final double waveSpeed;
  final double timeScaleFactor;
  final double waveAreaWidth;
  final String frequencyUnitLabel;
  final String positionUnitLabel;
  final String timeUnitLabel;

  /// Wave meter / graph vertical axis — [已确认] WavesModel graphVerticalAxisLabel
  final String graphVerticalAxisLabel;

  double get defaultFrequency =>
      WavesIntroConstants.rangeMidpoint(frequencyMin, frequencyMax);

  static final SceneConfig water = SceneConfig(
    kind: SceneKind.water,
    frequencyMin: WavesIntroConstants.waterFreqMin,
    frequencyMax: WavesIntroConstants.waterFreqMax,
    waveSpeed: WavesIntroConstants.waterWaveSpeed,
    timeScaleFactor: WavesIntroConstants.waterTimeScale,
    waveAreaWidth: WavesIntroConstants.waterWaveAreaWidth,
    frequencyUnitLabel: 'Hz',
    positionUnitLabel: 'cm',
    timeUnitLabel: 's',
    graphVerticalAxisLabel: 'Water Level',
  );

  static final SceneConfig sound = SceneConfig(
    kind: SceneKind.sound,
    frequencyMin: WavesIntroConstants.soundFreqMin,
    frequencyMax: WavesIntroConstants.soundFreqMax,
    waveSpeed: WavesIntroConstants.soundWaveSpeed,
    timeScaleFactor: WavesIntroConstants.soundTimeScale,
    waveAreaWidth: WavesIntroConstants.soundWaveAreaWidth,
    frequencyUnitLabel: '/ms',
    positionUnitLabel: 'cm',
    timeUnitLabel: 'ms',
    graphVerticalAxisLabel: 'Pressure',
  );

  static final SceneConfig light = SceneConfig(
    kind: SceneKind.light,
    frequencyMin: WavesIntroConstants.lightFreqMin,
    frequencyMax: WavesIntroConstants.lightFreqMax,
    waveSpeed: WavesIntroConstants.lightWaveSpeed,
    timeScaleFactor: WavesIntroConstants.lightTimeScale,
    waveAreaWidth: WavesIntroConstants.lightWaveAreaWidth,
    frequencyUnitLabel: '/fs',
    positionUnitLabel: 'nm',
    timeUnitLabel: 'fs',
    graphVerticalAxisLabel: 'Electric Field',
  );

  static SceneConfig forKind(SceneKind kind) {
    switch (kind) {
      case SceneKind.water:
        return water;
      case SceneKind.sound:
        return sound;
      case SceneKind.light:
        return light;
    }
  }
}
