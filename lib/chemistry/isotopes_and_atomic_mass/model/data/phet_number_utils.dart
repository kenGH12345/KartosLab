/// PhET `dot` toFixedNumber / roundSymmetric — needed for abundance rounding.
library;

/// Symmetric rounding matching PhET `dot/js/util/roundSymmetric.js`.
double roundSymmetric(num value) {
  return value < 0
      ? -(value.abs() + 0.5).floorToDouble()
      : (value + 0.5).floorToDouble();
}

/// Matches PhET `dot/js/util/toFixedNumber.js`.
double toFixedNumber(num value, int decimalPlaces) {
  final factor = _pow10(decimalPlaces);
  return roundSymmetric(value * factor) / factor;
}

/// Matches PhET `toFixed` string with fixed decimal places.
String toFixed(num value, int decimalPlaces) {
  final n = toFixedNumber(value, decimalPlaces);
  return n.toStringAsFixed(decimalPlaces);
}

double _pow10(int n) {
  var r = 1.0;
  for (var i = 0; i < n; i++) {
    r *= 10;
  }
  return r;
}
