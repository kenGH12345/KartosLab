/// PhET `dot/js/util` helpers used by Molarity model.
///
/// Source of truth: `phetsims/molarity` HTML5 (Solution.js uses `Utils.toFixedNumber`).
/// Do **not** import Beer's Law Lab / Concentration math here.
class MolarityMath {
  MolarityMath._();

  /// PhET `Utils.linear(x1, x2, y1, y2, x)`.
  static double linear(
    double x1,
    double x2,
    double y1,
    double y2,
    double x,
  ) {
    return y1 + (x - x1) * (y2 - y1) / (x2 - x1);
  }

  /// PhET `Utils.toFixedNumber` ≡ `Number(value.toFixed(decimalPlaces))`.
  static double toFixedNumber(double value, int decimalPlaces) {
    return double.parse(value.toStringAsFixed(decimalPlaces));
  }

  /// PhET `Utils.toFixed` — fixed-decimal display string.
  static String toFixed(double value, int decimalPlaces) =>
      toFixedNumber(value, decimalPlaces).toStringAsFixed(decimalPlaces);
}
