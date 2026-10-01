import 'dart:math' as math;

import '../waves_intro_constants.dart';

/// Pure audio intent/state for Waves Intro — owned by [WavesIntroModel].
///
/// Painters never write here. Renderer ([WavesIntroAudio]) only reads.
/// Evidence: WI lock `31ebfd7` WavesScreenSoundView / WaveMeterNode / Scene.
class WavesIntroAudioState {
  /// Master mute — local to this sim (no global joist soundManager).
  bool muted = false;

  /// Master volume 0..1 — maps to PhET soundManager output scale [行为一致].
  double masterVolume = 0.7;

  /// Sound scene "Play Tone" — [已确认] isTonePlayingProperty default false.
  bool isTonePlaying = false;

  /// Light scene "Sound Effect" — [已确认] soundEffectEnabledProperty default false.
  bool soundEffectEnabled = false;

  /// Wave-meter series playing → ducking of water/speaker/light.
  bool series1Playing = false;
  bool series2Playing = false;

  /// Latest meter probe samples (null if inactive / out of bounds).
  double? meterSample1;
  double? meterSample2;

  /// Computed output levels for meter sonification.
  double series1OutputLevel = 0;
  double series2OutputLevel = 0;

  /// Speaker / ambient activity level for visual audio meter (0..1).
  double ambientOutputLevel = 0;

  /// Last oscillator value for speaker zero-crossing (Sound scene).
  double previousOscillatorValue = 0;

  bool get enabled => !muted;

  double get effectiveVolume => muted ? 0.0 : masterVolume.clamp(0.0, 1.0);

  /// [已确认] duckingProperty: 0.3 when either meter series playing, else 1.
  double get duckingFactor =>
      (series1Playing || series2Playing) ? 0.3 : 1.0;

  /// Visual meter: max of meter series + ambient.
  double get visualMeterLevel {
    final m = series1OutputLevel > series2OutputLevel
        ? series1OutputLevel
        : series2OutputLevel;
    final peak = m > ambientOutputLevel ? m : ambientOutputLevel;
    return (peak * effectiveVolume).clamp(0.0, 1.0);
  }

  void reset() {
    muted = false;
    masterVolume = 0.7;
    isTonePlaying = false;
    soundEffectEnabled = false;
    series1Playing = false;
    series2Playing = false;
    meterSample1 = null;
    meterSample2 = null;
    series1OutputLevel = 0;
    series2OutputLevel = 0;
    ambientOutputLevel = 0;
    previousOscillatorValue = 0;
  }
}

/// [已确认] getWaveMeterNodeOutputLevel.js @ lock `31ebfd7`
double waveMeterNodeOutputLevel(double value) {
  final clampedValue = value.clamp(-1.6, 1.6);
  final normalized =
      WavesIntroConstants.linear(-1.6, 1.6, -1.0, 1.0, clampedValue.toDouble());

  final arcsin1 = math.asin(normalized);
  final arcsin1Mapped = WavesIntroConstants.linear(
    -math.pi / 2,
    math.pi / 2,
    -1.0,
    1.0,
    arcsin1,
  );
  final arcsin2 = math.asin(arcsin1Mapped.clamp(-1.0, 1.0));
  final arcsin2Mapped = WavesIntroConstants.linear(
    -math.pi / 2,
    math.pi / 2,
    -1.0,
    1.0,
    arcsin2,
  );

  var outputLevel = arcsin2Mapped.abs();
  if (outputLevel < 0.05) outputLevel = 0.05;
  if (outputLevel > 0.4) outputLevel = 0.4;

  outputLevel = _piecewiseLinear(
    const [0.05, 0.1, 0.2, 0.3, 0.4],
    const [0.0, 0.05, 0.2, 0.5, 1.0],
    outputLevel,
  );

  return outputLevel / 0.15;
}

double _piecewiseLinear(List<double> xs, List<double> ys, double x) {
  if (x <= xs.first) return ys.first;
  if (x >= xs.last) return ys.last;
  for (var i = 0; i < xs.length - 1; i++) {
    if (x >= xs[i] && x <= xs[i + 1]) {
      return WavesIntroConstants.linear(xs[i], xs[i + 1], ys[i], ys[i + 1], x);
    }
  }
  return ys.last;
}
