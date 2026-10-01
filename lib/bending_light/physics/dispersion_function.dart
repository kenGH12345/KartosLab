import 'dart:math' as math;

import '../bending_light_constants.dart';

/// `DispersionFunction.ts` — Sellmeier glass + air formula + linear mix.
class DispersionFunction {
  DispersionFunction(this.referenceIndexOfRefraction, this.referenceWavelength);

  final double referenceIndexOfRefraction;
  final double referenceWavelength;

  /// Sellmeier equation; [wavelength] in meters.
  double getSellmeierValue(double wavelength) {
    final l2 = wavelength * wavelength;
    const b1 = 1.03961212;
    const b2 = 0.231792344;
    const b3 = 1.01046945;
    const c1 = 6.00069867e-3 * 1e-12;
    const c2 = 2.00179144e-2 * 1e-12;
    const c3 = 1.03560653e2 * 1e-12;
    return math.sqrt(
      1 +
          b1 * l2 / (l2 - c1) +
          b2 * l2 / (l2 - c2) +
          b3 * l2 / (l2 - c3),
    );
  }

  /// Air index — refractiveindex.info formula; [wavelength] in meters.
  double getAirIndex(double wavelength) {
    final invSq = math.pow(wavelength * 1e6, -2).toDouble();
    return 1 +
        5792105e-8 / (238.0185 - invSq) +
        167917e-8 / (57.362 - invSq);
  }

  double getIndexOfRefractionForRed() =>
      getIndexOfRefraction(BendingLightConstants.wavelengthRed);

  /// Interpolate air↔glass so that at [referenceWavelength], n = [referenceIndexOfRefraction].
  double getIndexOfRefraction(double wavelength) {
    final nAirReference = getAirIndex(referenceWavelength);
    final nGlassReference = getSellmeierValue(referenceWavelength);
    final delta = nGlassReference - nAirReference;
    var x = (referenceIndexOfRefraction - nAirReference) / delta;
    if (x < 0) x = 0;
    // clamp to [0, +∞) as in PhET Utils.clamp(x, 0, POSITIVE_INFINITY)
    return x * getSellmeierValue(wavelength) + (1 - x) * getAirIndex(wavelength);
  }
}
