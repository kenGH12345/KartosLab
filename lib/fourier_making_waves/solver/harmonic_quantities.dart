import 'dart:math' as math;

import '../fmw_constants.dart';

/// Harmonic quantities from PhET `FourierSeries` / `Harmonic` construction.
///
/// λₙ = L / n (meters)
/// fₙ = f₀ · n (Hz)
/// Tₙ = 1000 / fₙ = T₀ / n (milliseconds)
class HarmonicQuantities {
  HarmonicQuantities._();

  static double wavelength(int order, {double L = FmwConstants.L}) {
    assert(order >= 1);
    return L / order;
  }

  static double frequency(int order, {double f0 = FmwConstants.fundamentalFrequency}) {
    assert(order >= 1);
    return f0 * order;
  }

  static double period(int order, {double fundamentalPeriod = FmwConstants.T}) {
    assert(order >= 1);
    return fundamentalPeriod / order;
  }

  /// Spatial wave number kₙ = 2π / λₙ = 2π n / L
  static double spatialWaveNumber(int order, {double L = FmwConstants.L}) {
    return 2 * math.pi * order / L;
  }

  /// Angular wave number ωₙ = 2π / Tₙ
  static double angularWaveNumber(
    int order, {
    double fundamentalPeriod = FmwConstants.T,
  }) {
    return 2 * math.pi / period(order, fundamentalPeriod: fundamentalPeriod);
  }
}
