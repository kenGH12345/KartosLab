import 'dart:math' as math;

import '../model/resistance_in_a_wire_constants.dart';

/// Source-aligned audio *event* hooks for Resistance in a Wire.
///
/// Mirrors `ResistanceSoundGenerator` / `ParameterMonitor`:
/// - play on **bin transition** (9 bins), or **min/max**, or **keyboard** change
/// - pitch from log-normalized resistance (`brightMarimbaShort`)
///
/// Records events for Phase 3. Actual sample playback = PARTIAL until heard.
class ResistanceInAWireAudioHooks {
  ResistanceInAWireAudioHooks() {
    _rho = _BinMonitor(
      ResistanceInAWireConstants.resistivityRange.min,
      ResistanceInAWireConstants.resistivityRange.max,
    );
    _length = _BinMonitor(
      ResistanceInAWireConstants.lengthRange.min,
      ResistanceInAWireConstants.lengthRange.max,
    );
    _area = _BinMonitor(
      ResistanceInAWireConstants.areaRange.min,
      ResistanceInAWireConstants.areaRange.max,
    );
  }

  static const int binsPerSlider = 9;

  late final _BinMonitor _rho;
  late final _BinMonitor _length;
  late final _BinMonitor _area;

  int resistivitySoundEvents = 0;
  int lengthSoundEvents = 0;
  int areaSoundEvents = 0;
  int resetEvents = 0;
  double lastPlaybackRate = 1.0;
  bool disposed = false;

  /// Set by SliderUnit before a keyboard-driven property write.
  bool expectKeyboard = false;

  bool consumeExpectKeyboard() {
    final v = expectKeyboard;
    expectKeyboard = false;
    return v;
  }

  /// Source: `playbackRate = 2^((1 - n) * 3) / 3` with log-normalized R.
  static double playbackRateForResistance(double resistance) {
    final minR = ResistanceInAWireConstants.resistanceRange.min;
    final maxR = ResistanceInAWireConstants.resistanceRange.max;
    final n = math.log(resistance / minR) / math.log(maxR / minR);
    return math.pow(2, (1 - n) * 3) / 3;
  }

  void onResistivityChanged(
    double value,
    double resistance, {
    bool fromKeyboard = false,
  }) {
    if (disposed) return;
    if (_rho.shouldPlay(value, fromKeyboard: fromKeyboard)) {
      resistivitySoundEvents++;
      lastPlaybackRate = playbackRateForResistance(resistance);
    }
  }

  void onLengthChanged(
    double value,
    double resistance, {
    bool fromKeyboard = false,
  }) {
    if (disposed) return;
    if (_length.shouldPlay(value, fromKeyboard: fromKeyboard)) {
      lengthSoundEvents++;
      lastPlaybackRate = playbackRateForResistance(resistance);
    }
  }

  void onAreaChanged(
    double value,
    double resistance, {
    bool fromKeyboard = false,
  }) {
    if (disposed) return;
    if (_area.shouldPlay(value, fromKeyboard: fromKeyboard)) {
      areaSoundEvents++;
      lastPlaybackRate = playbackRateForResistance(resistance);
    }
  }

  void onReset() {
    if (disposed) return;
    resetEvents++;
  }

  void dispose() {
    disposed = true;
  }
}

class _BinMonitor {
  _BinMonitor(this.minValue, this.maxValue)
      : span = maxValue - minValue,
        _bin = _selectBin(minValue, maxValue, maxValue - minValue, minValue);

  final double minValue;
  final double maxValue;
  final double span;
  int _bin;

  static int _selectBin(double min, double max, double span, double value) {
    final proportion = ((value - min) / span).clamp(0.0, 1.0);
    return math.min(
      (proportion * ResistanceInAWireAudioHooks.binsPerSlider).floor(),
      ResistanceInAWireAudioHooks.binsPerSlider - 1,
    );
  }

  bool shouldPlay(double value, {required bool fromKeyboard}) {
    final bin = _selectBin(minValue, maxValue, span, value);
    final atBound = value == minValue || value == maxValue;
    final play = fromKeyboard || bin != _bin || atBound;
    _bin = bin;
    return play;
  }
}
