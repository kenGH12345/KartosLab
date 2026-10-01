import 'dart:math' as math;

/// PhET `Utils.roundSymmetric` — round half away from zero via floor(n+0.5).
double roundSymmetric(double v) {
  return v < 0
      ? -(v.abs() + 0.5).floorToDouble()
      : (v + 0.5).floorToDouble();
}

/// PhET `Utils.toFixed` via roundSymmetric then fixed decimal string.
String toFixed(double number, int decimalPlaces) {
  final factor = math.pow(10, decimalPlaces).toDouble();
  final rounded = roundSymmetric(number * factor) / factor;
  return rounded.toStringAsFixed(decimalPlaces);
}

/// DeviationsAccordionBox `formatNumber` — exact port.
///
/// For numbers smaller than ten, returns [digits] decimal places.
/// For numbers larger than ten, returns a fixed number with (digits + 1)
/// significant figures (see PhET comments).
String formatNumber(double number, int digits) {
  // number = mantissa × 10^(exponent) where mantissa ∈ [1,10) (or negative).
  final exponent = math.log(number.abs()) / math.ln10;
  final expFloor = exponent.isFinite ? exponent.floor() : -0x3fffffff;

  late final int decimalPlaces;
  if (expFloor >= digits) {
    decimalPlaces = 0;
  } else if (expFloor > 0) {
    decimalPlaces = digits - expFloor;
  } else {
    decimalPlaces = digits;
  }

  return toFixed(number, decimalPlaces);
}
