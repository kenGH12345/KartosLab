import 'dart:math' as math;

/// PhET `dot/js/util` helpers used by Acid-Base Solutions.
///
/// Source: `Utils.roundSymmetric` / `Utils.log10` as used in
/// `AqueousSolution.ts` and `ParticlesCanvasNode.ts`.
class AbsMath {
  AbsMath._();

  /// `Math.log10(x)` / PhET `Utils.log10`.
  static double log10(double x) => math.log(x) / math.ln10;

  /// PhET `dot/js/util/roundSymmetric.ts` — half away from zero.
  static double roundSymmetric(double value) {
    if (value < 0) {
      return -(value.abs() + 0.5).floorToDouble();
    }
    return (value + 0.5).floorToDouble();
  }

  /// PhET `Utils.toFixedNumber` — used by `LogSlider.linearToLog`.
  static double toFixedNumber(double value, int decimalPlaces) {
    final factor = math.pow(10, decimalPlaces).toDouble();
    return roundSymmetric(value * factor) / factor;
  }

  /// pH display chain from `AqueousSolution.ts`:
  /// `pH = -roundSymmetric(100 * log10([H3O+])) / 100`
  static double pHFromH3O(double h3oConcentration) {
    return -roundSymmetric(100 * log10(h3oConcentration)) / 100;
  }

  /// `LogSlider.logToLinear` — `Utils.log10(value)`.
  static double logToLinear(double value) => log10(value);

  /// `LogSlider.linearToLog` — `toFixedNumber(Math.pow(10, value), 10)`.
  static double linearToLog(double linearValue) =>
      toFixedNumber(math.pow(10, linearValue).toDouble(), 10);

  /// PhET `Utils.toFixed` — fixed-decimal display string.
  static String toFixed(double value, int decimalPlaces) =>
      toFixedNumber(value, decimalPlaces).toStringAsFixed(decimalPlaces);

  /// Linear interpolate — PhET `dot/js/util/linear`.
  static double linear(
    double x1,
    double x2,
    double y1,
    double y2,
    double x,
  ) {
    if (x2 == x1) return y1;
    return y1 + ((x - x1) * (y2 - y1) / (x2 - x1));
  }
}
