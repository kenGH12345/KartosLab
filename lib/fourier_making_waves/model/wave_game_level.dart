import 'dart:math' as math;

import '../fmw_constants.dart';
import '../solver/amplitudes_generator.dart';
import 'fourier_series.dart';

/// Amplitude match threshold. PhET `WaveGameLevel.ts` AMPLITUDE_THRESHOLD
const double kWaveGameAmplitudeThreshold = 0;

/// One Wave Game level. PhET `WaveGameLevel.ts`
class WaveGameLevel {
  WaveGameLevel({
    required this.levelNumber,
    required this.defaultNumberOfAmplitudeControls,
    int Function()? getNumberOfNonZeroHarmonics,
    AmplitudesGenerator? amplitudesGenerator,
  })  : assert(levelNumber >= 1),
        _getNumberOfNonZeroHarmonics =
            getNumberOfNonZeroHarmonics ?? (() => levelNumber),
        amplitudesGenerator = amplitudesGenerator ??
            AmplitudesGenerator(
              getNumberOfNonZeroHarmonics:
                  getNumberOfNonZeroHarmonics ?? (() => levelNumber),
            ) {
    final firstAnswer = this.amplitudesGenerator.createAmplitudes();
    answerSeries = FourierSeries(amplitudes: firstAnswer);
    guessSeries = FourierSeries();
    numberOfAmplitudeControls = defaultNumberOfAmplitudeControls;
    _syncAmplitudeControlsRange();
  }

  final int levelNumber;
  final int defaultNumberOfAmplitudeControls;
  final int Function() _getNumberOfNonZeroHarmonics;
  final AmplitudesGenerator amplitudesGenerator;

  int Function() get getNumberOfNonZeroHarmonics =>
      _getNumberOfNonZeroHarmonics;

  late final FourierSeries answerSeries;
  late final FourierSeries guessSeries;

  int score = 0;
  bool isSolved = false;
  int numberOfAmplitudeControls = 1;

  /// Min/max for amplitude-controls spinner.
  int amplitudeControlsMin = 1;
  int amplitudeControlsMax = FmwConstants.maxHarmonics;

  bool get isMatched {
    final guess = guessSeries.amplitudes;
    final answer = answerSeries.amplitudes;
    for (var i = 0; i < guess.length; i++) {
      if ((guess[i] - answer[i]).abs() > kWaveGameAmplitudeThreshold) {
        return false;
      }
    }
    return true;
  }

  void reset({bool startNewWaveform = true}) {
    score = 0;
    isSolved = false;
    numberOfAmplitudeControls = defaultNumberOfAmplitudeControls;
    if (startNewWaveform) {
      newWaveform();
    }
  }

  void eraseAmplitudes() {
    guessSeries.setAllAmplitudes(0);
  }

  /// Check Answer. Returns points awarded (0 if incorrect).
  int checkAnswer() {
    assert(!isSolved);
    if (isMatched) {
      const pointsAwarded = FmwConstants.pointsPerChallenge;
      score += pointsAwarded;
      isSolved = true;
      return pointsAwarded;
    }
    return 0;
  }

  void showAnswer() {
    isSolved = true;
    guessSeries.setAmplitudes(answerSeries.amplitudesCopy);
  }

  void newWaveform() {
    guessSeries.setAllAmplitudes(0);

    final previous = answerSeries.amplitudesCopy;
    final newAmplitudes = amplitudesGenerator.createAmplitudes(previous);
    answerSeries.setAmplitudes(newAmplitudes);

    isSolved = false;

    // PhET: Math.max(current, defaultNumberOfAmplitudeControls)
    final min = answerSeries.getNumberOfNonZeroHarmonics();
    final max = amplitudeControlsMax;
    final value = math.max(
      numberOfAmplitudeControls,
      defaultNumberOfAmplitudeControls,
    );
    amplitudeControlsMin = min;
    amplitudeControlsMax = max;
    numberOfAmplitudeControls = value.clamp(min, max);
  }

  void _syncAmplitudeControlsRange() {
    amplitudeControlsMin = answerSeries.getNumberOfNonZeroHarmonics();
    amplitudeControlsMax = FmwConstants.maxHarmonics;
    numberOfAmplitudeControls =
        numberOfAmplitudeControls.clamp(amplitudeControlsMin, amplitudeControlsMax);
  }
}
