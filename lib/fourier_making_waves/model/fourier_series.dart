import '../fmw_constants.dart';

/// Fourier series amplitudes for Discrete / Wave Game. PhET `FourierSeries.ts`
/// + `DiscreteFourierSeries.ts` numberOfHarmonics behavior.
class FourierSeries {
  FourierSeries({
    List<double>? amplitudes,
    int numberOfHarmonics = FmwConstants.maxHarmonics,
  })  : L = FmwConstants.L,
        T = FmwConstants.T,
        fundamentalFrequency = FmwConstants.fundamentalFrequency,
        amplitudes = List<double>.from(
          amplitudes ??
              List<double>.filled(FmwConstants.maxHarmonics, 0),
        ) {
    assert(this.amplitudes.length == FmwConstants.maxHarmonics);
    _numberOfHarmonics = numberOfHarmonics.clamp(1, FmwConstants.maxHarmonics);
    _zeroIrrelevantAmplitudes();
  }

  final double fundamentalFrequency;
  final double L;
  final double T;

  /// Mutable amplitudes for harmonics 1..11 (index 0 = order 1).
  final List<double> amplitudes;

  int _numberOfHarmonics = FmwConstants.maxHarmonics;

  /// Number of relevant harmonics (1..11). Higher orders are forced to 0.
  int get numberOfHarmonics => _numberOfHarmonics;

  set numberOfHarmonics(int value) {
    _numberOfHarmonics = value.clamp(1, FmwConstants.maxHarmonics);
    _zeroIrrelevantAmplitudes();
  }

  double get fundamentalPeriod => T;
  double get fundamentalWavelength => L;

  double get minAmplitude => -FmwConstants.maxAmplitude;
  double get maxAmplitude => FmwConstants.maxAmplitude;

  void setAmplitude(int order, double amplitude) {
    assert(order >= 1 && order <= FmwConstants.maxHarmonics);
    assert(amplitude >= minAmplitude && amplitude <= maxAmplitude);
    if (order > _numberOfHarmonics) return;
    amplitudes[order - 1] = amplitude;
  }

  void setAmplitudes(List<double> values) {
    assert(values.length == amplitudes.length);
    for (var i = 0; i < amplitudes.length; i++) {
      amplitudes[i] = values[i];
    }
    _zeroIrrelevantAmplitudes();
  }

  void setAllAmplitudes(double amplitude) {
    for (var i = 0; i < amplitudes.length; i++) {
      amplitudes[i] = amplitude;
    }
    _zeroIrrelevantAmplitudes();
  }

  void reset() {
    _numberOfHarmonics = FmwConstants.maxHarmonics;
    for (var i = 0; i < amplitudes.length; i++) {
      amplitudes[i] = 0;
    }
  }

  int getNumberOfNonZeroHarmonics() {
    var count = 0;
    for (final a in amplitudes) {
      if (a != 0) count++;
    }
    return count;
  }

  List<double> get amplitudesCopy => List<double>.from(amplitudes);

  void _zeroIrrelevantAmplitudes() {
    for (var i = _numberOfHarmonics; i < amplitudes.length; i++) {
      amplitudes[i] = 0;
    }
  }
}
