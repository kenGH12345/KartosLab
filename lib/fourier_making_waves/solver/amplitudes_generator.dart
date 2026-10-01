import 'dart:math' as math;

import '../fmw_constants.dart';

/// Random amplitude challenges for Wave Game. PhET `AmplitudesGenerator.ts`
class AmplitudesGenerator {
  AmplitudesGenerator({
    this.numberOfHarmonics = FmwConstants.maxHarmonics,
    this.maxAmplitude = FmwConstants.maxAmplitude,
    int Function()? getNumberOfNonZeroHarmonics,
    math.Random? random,
  })  : getNumberOfNonZeroHarmonics =
            getNumberOfNonZeroHarmonics ?? (() => 1),
        _random = random ?? math.Random();

  final int numberOfHarmonics;
  final double maxAmplitude;
  final int Function() getNumberOfNonZeroHarmonics;
  final math.Random _random;

  /// Creates amplitudes; avoids similarity with [previousAmplitudes] when given.
  List<double> createAmplitudes([List<double>? previousAmplitudes]) {
    assert(
      previousAmplitudes == null ||
          previousAmplitudes.length == numberOfHarmonics,
    );

    List<double> amplitudes;
    final numberOfNonZeroHarmonics = getNumberOfNonZeroHarmonics();
    var attempts = 0;
    const maxAttempts = 10;

    do {
      amplitudes = _generateRandomAmplitudes(
        numberOfHarmonics,
        numberOfNonZeroHarmonics,
        maxAmplitude,
      );
      attempts++;
    } while (previousAmplitudes != null &&
        attempts < maxAttempts &&
        _isSimilar(amplitudes, previousAmplitudes));

    assert(amplitudes.length == numberOfHarmonics);
    return amplitudes;
  }

  static bool _isSimilar(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<double> _generateRandomAmplitudes(
    int numberOfAmplitudes,
    int numberOfNonZeroHarmonics,
    double maxAmplitude,
  ) {
    assert(numberOfAmplitudes > 0);
    assert(numberOfNonZeroHarmonics > 0);
    assert(numberOfAmplitudes >= numberOfNonZeroHarmonics);
    assert(maxAmplitude > 0);

    final amplitudesIndices = List<int>.generate(numberOfAmplitudes, (i) => i);
    final amplitudes = List<double>.filled(numberOfAmplitudes, 0);

    for (var i = 0; i < numberOfNonZeroHarmonics; i++) {
      final index = _random.nextInt(amplitudesIndices.length);
      final amplitudesIndex = amplitudesIndices.removeAt(index);

      var amplitude = _nextDoubleBetween(-maxAmplitude, 0);
      if (amplitude != -maxAmplitude) {
        amplitude = _roundToInterval(
          amplitude,
          FmwConstants.waveGameAmplitudeStep,
        );
      }
      if (amplitude == 0) {
        amplitude = -FmwConstants.waveGameAmplitudeStep;
      }
      amplitude *= _random.nextBool() ? 1 : -1;
      assert(amplitude >= -maxAmplitude &&
          amplitude <= maxAmplitude &&
          amplitude != 0);
      amplitudes[amplitudesIndex] = amplitude;
    }

    return amplitudes;
  }

  /// Inclusive [min], exclusive [max) — matches PhET `nextDoubleBetween`.
  double _nextDoubleBetween(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }

  static double _roundToInterval(double value, double interval) {
    return (value / interval).round() * interval;
  }
}
