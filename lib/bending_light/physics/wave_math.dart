import 'dart:math' as math;

import '../bending_light_constants.dart';

/// Wave phase helpers matching `LightRay.getCosArg` / `getWaveValue`.
class WaveMath {
  WaveMath._();

  /// cos(k·x − ω·t + φ) argument; φ = 2π·numWavelengthsPhaseOffset
  static double cosArg({
    required double wavelengthInMedium,
    required double indexOfRefraction,
    required double distanceAlongRay,
    required double time,
    required double numWavelengthsPhaseOffset,
  }) {
    final speed = BendingLightConstants.speedOfLight / indexOfRefraction;
    final frequency = speed / wavelengthInMedium;
    final omega = frequency * math.pi * 2;
    final k = 2 * math.pi / wavelengthInMedium;
    return k * distanceAlongRay - omega * time + 2 * math.pi * numWavelengthsPhaseOffset;
  }

  /// IntroModel.getWaveValue magnitude: √(power)·cos(phase+π)
  static double waveMagnitude({
    required double powerFraction,
    required double cosArgument,
  }) {
    final amplitude = math.sqrt(powerFraction);
    return amplitude * math.cos(cosArgument + math.pi);
  }

  static double dtForSpeed({required bool normal}) =>
      normal ? 1e-16 : 0.5e-16;
}
