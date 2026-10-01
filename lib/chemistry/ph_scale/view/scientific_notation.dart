/// Scientific notation helpers — scenery-phet `ScientificNotationNode.toScientificNotation`.
class ScientificNotation {
  const ScientificNotation({required this.mantissa, required this.exponent});

  final String mantissa;
  final String exponent;

  /// Display like `1.00 × 10⁻⁷`.
  String get display => '$mantissa × 10$exponentSuperscript';

  String get exponentSuperscript {
    final buf = StringBuffer();
    for (final rune in exponent.runes) {
      final ch = String.fromCharCode(rune);
      buf.write(_super[ch] ?? ch);
    }
    return buf.toString();
  }

  static const _super = {
    '0': '⁰',
    '1': '¹',
    '2': '²',
    '3': '³',
    '4': '⁴',
    '5': '⁵',
    '6': '⁶',
    '7': '⁷',
    '8': '⁸',
    '9': '⁹',
    '+': '⁺',
    '-': '⁻',
  };

  /// [mantissaDecimalPlaces] default 1 in scenery-phet; Particle Counts uses 2.
  /// If [fixedExponent] is set (H₂O uses 25), mantissa = value / 10^E.
  static ScientificNotation from(
    double value, {
    int mantissaDecimalPlaces = 2,
    int? fixedExponent,
  }) {
    assert(value.isFinite);
    if (fixedExponent != null) {
      final m = value / _pow10(fixedExponent);
      return ScientificNotation(
        mantissa: m.toStringAsFixed(mantissaDecimalPlaces),
        exponent: fixedExponent.toString(),
      );
    }
    // Match JS Number.toExponential(places)
    final expStr = value.toStringAsExponential(mantissaDecimalPlaces);
    final parts = expStr.toLowerCase().split('e');
    var exp = parts[1];
    if (exp.startsWith('+')) exp = exp.substring(1);
    return ScientificNotation(mantissa: parts[0], exponent: exp);
  }

  static double _pow10(int e) {
    var r = 1.0;
    if (e >= 0) {
      for (var i = 0; i < e; i++) {
        r *= 10;
      }
    } else {
      for (var i = 0; i < -e; i++) {
        r /= 10;
      }
    }
    return r;
  }
}
