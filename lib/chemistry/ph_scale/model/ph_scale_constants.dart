import 'dart:math' as math;
import 'dart:ui';

/// Constants from PhET `PHScaleConstants.ts`.
class PhScaleConstants {
  PhScaleConstants._();

  /// ScreenView layoutBounds: 1100 × 700.
  static const Size layoutBounds = Size(1100, 700);

  static const double beakerVolume = 1.2; // L
  static const Offset beakerPosition = Offset(750, 580);
  static const Size beakerSize = Size(450, 300);

  static const double phMin = -1;
  static const double phMax = 15;
  static const double phDefault = 7;
  static const int phMeterDecimalPlaces = 2;

  static const int volumeDecimalPlaces = 2;

  /// Minimum non-zero volume for visible/measurable solution (L).
  static const double minSolutionVolume = 0.015;

  /// `Math.pow(10, -VOLUME_DECIMAL_PLACES)` — drain/add floor (L).
  static final double minVolume = math.pow(10, -volumeDecimalPlaces).toDouble();

  static const double logarithmicExponentMin = -16;
  static const double logarithmicExponentMax = 2;
  static const double linearExponentMin = -14;
  static const double linearExponentMax = 1;
  static const double linearMantissaMin = 0;
  static const double linearMantissaMax = 8;

  static const double tapToDispenseAmount = 0.05; // L
  static const int tapToDispenseIntervalMs = 333;

  /// Checkbox box width — `PHScaleConstants.CHECKBOX_WIDTH`.
  static const int checkboxWidth = 21;

  /// Plain-text formulas for Flutter (HTML sub/sup not used).
  static const String h3oFormulaPlain = 'H₃O⁺';
  static const String ohFormulaPlain = 'OH⁻';
  static const String h2oFormulaPlain = 'H₂O';

  /// PhET `toFixedNumber(value, decimalPlaces)`.
  static double toFixedNumber(double value, int decimalPlaces) {
    final factor = math.pow(10, decimalPlaces).toDouble();
    return (value * factor).round() / factor;
  }

  /// PhET `Utils.roundSymmetric`.
  static int roundSymmetric(double value) => value.round();
}
