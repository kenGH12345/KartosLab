/// shred `ChargeNotation` — BAA default is [signLast].
library;

enum ChargeNotation {
  /// `+1` / `−1`
  signFirst,

  /// `1+` / `1−` (PhET BAAQueryParameters default)
  signLast,
}

/// Format charge for SymbolNode charge display.
String formatChargeDisplay(
  int charge, {
  ChargeNotation notation = ChargeNotation.signLast,
}) {
  if (charge == 0) return '0';
  const minus = '\u2212'; // MathSymbols.MINUS
  final sign = charge > 0 ? '+' : minus;
  final abs = charge.abs().toString();
  return notation == ChargeNotation.signFirst ? '$sign$abs' : '$abs$sign';
}

/// shred `ShredConstants.CHARGE_TEXT_COLOR`.
int chargeTextColorValue(int charge) {
  if (charge > 0) return 0xFFD14600; // proton
  if (charge < 0) return 0xFF0000FF; // blue
  return 0xFF000000;
}
