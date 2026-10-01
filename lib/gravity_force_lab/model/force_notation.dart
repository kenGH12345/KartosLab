import 'force_values_display.dart';
import 'gravity_force_constants.dart';

/// Scientific notation tokens — scenery-phet `ScientificNotationNode.toScientificNotation`.
class ScientificNotation {
  const ScientificNotation({required this.mantissa, required this.exponent});

  final String mantissa;
  final String exponent;
}

/// Force value formatting for Full Version arrow labels (ISLCForceArrowNode).
///
/// Visual unit is always **N**. μN is a11y-only (not used here).
class ForceNotationFormatter {
  ForceNotationFormatter._();

  /// Pattern with numeric value: `Force on m1 by m2 = {value} N`
  static String labelWithValue({
    required String thisObject,
    required String otherObject,
    required String value,
  }) =>
      'Force on $thisObject by $otherObject = $value N';

  /// Hidden / no-value pattern: `Force on m1 by m2`
  static String labelWithoutValue({
    required String thisObject,
    required String otherObject,
  }) =>
      'Force on $thisObject by $otherObject';

  /// Full arrow label for the current display mode.
  static String formatForceLabel({
    required double forceAbs,
    required ForceValuesDisplay display,
    required String thisObject,
    required String otherObject,
  }) {
    switch (display) {
      case ForceValuesDisplay.hidden:
        return labelWithoutValue(
          thisObject: thisObject,
          otherObject: otherObject,
        );
      case ForceValuesDisplay.decimal:
        return labelWithValue(
          thisObject: thisObject,
          otherObject: otherObject,
          value: formatDecimal(forceAbs),
        );
      case ForceValuesDisplay.scientific:
        return labelWithValue(
          thisObject: thisObject,
          otherObject: otherObject,
          value: formatScientific(forceAbs),
        );
    }
  }

  /// Decimal: 12 places, first 3 decimals then groups of 3 with spaces.
  static String formatDecimal(
    double forceAbs, {
    int precision = GravityForceConstants.decimalNotationPrecision,
  }) {
    final forceStr = forceAbs.toStringAsFixed(precision);
    final pointPosition = forceStr.indexOf('.');
    if (pointPosition < 0) {
      throw StateError('ISLCForceArrowNode requires a decimal value');
    }

    var formatted = forceStr.substring(0, pointPosition + 4);
    for (var i = pointPosition + 4; i < forceStr.length; i += 3) {
      final end = (i + 3 < forceStr.length) ? i + 3 : forceStr.length;
      formatted += ' ${forceStr.substring(i, end)}';
    }
    return formatted;
  }

  /// Scientific: mantissa (2 dp) × 10^exp — unit N applied by [labelWithValue].
  static String formatScientific(
    double forceAbs, {
    int precision = GravityForceConstants.scientificNotationPrecision,
  }) {
    if (forceAbs == 0) {
      return formatDecimal(forceAbs, precision: precision);
    }
    final notation = toScientificNotation(forceAbs, mantissaDecimalPlaces: precision);
    if (notation.exponent == '0') {
      return notation.mantissa;
    }
    // RichText uses <sup>; plain Model string uses ^ for tests / a11y bridge.
    return '${notation.mantissa} × 10^${notation.exponent}';
  }

  /// scenery-phet `ScientificNotationNode.toScientificNotation`.
  static ScientificNotation toScientificNotation(
    double value, {
    int mantissaDecimalPlaces = 1,
  }) {
    assert(value.isFinite, 'value must be finite: $value');
    final exponentialString = value.toStringAsExponential(mantissaDecimalPlaces);
    final tokens = exponentialString.toLowerCase().split('e');
    var mantissa = tokens[0];
    var exponent = tokens[1];
    if (exponent.startsWith('+')) {
      exponent = exponent.substring(1);
    }
    return ScientificNotation(mantissa: mantissa, exponent: exponent);
  }

  static bool showForceValues(ForceValuesDisplay display) =>
      display == ForceValuesDisplay.decimal ||
      display == ForceValuesDisplay.scientific;
}
