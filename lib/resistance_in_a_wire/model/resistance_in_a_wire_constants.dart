/// Model-only constants from PhET `ResistanceInAWireConstants.ts` (1.8.0-dev.0).
///
/// View geometry / fonts / colors / slider chrome are intentionally omitted.
library;

/// Inclusive numeric range with default (PhET `RangeWithValue`).
class ResistanceInAWireRange {
  const ResistanceInAWireRange(this.min, this.max, this.defaultValue)
      : assert(min <= max),
        assert(defaultValue >= min && defaultValue <= max);

  final double min;
  final double max;
  final double defaultValue;

  double get length => max - min;

  /// PhET `Range.constrainValue`.
  double constrain(double value) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  bool contains(double value) => value >= min && value <= max;
}

/// Source: `ResistanceInAWireConstants.ts`.
abstract final class ResistanceInAWireConstants {
  /// Ohm·cm — `RangeWithValue( 0.01, 1.00, 0.5 )`.
  static const ResistanceInAWireRange resistivityRange =
      ResistanceInAWireRange(0.01, 1.00, 0.5);

  /// cm — `RangeWithValue( 0.1, 20, 10 )`.
  static const ResistanceInAWireRange lengthRange =
      ResistanceInAWireRange(0.1, 20.0, 10.0);

  /// cm² — `RangeWithValue( 0.01, 15, 7.5 )`.
  static const ResistanceInAWireRange areaRange =
      ResistanceInAWireRange(0.01, 15.0, 7.5);

  /// Slider readout decimal places (`SLIDER_READOUT_DECIMALS = 2`).
  static const int sliderReadoutDecimals = 2;

  /// Empirical letter-scale constant from `FormulaNode` (`7 / defaultValue`).
  ///
  /// View uses this; exposed here so oracle can lock default scaleMagnitude=8.
  /// VD-02: source declares `cappedSize` for R but does **not** apply a cap.
  static const double formulaLetterScaleNumerator = 7.0;

  /// Resistance range from source:
  /// `ρ_min * L_min / A_max … ρ_max * L_max / A_min`.
  static ResistanceInAWireRange get resistanceRange {
    final min = resistivityRange.min * lengthRange.min / areaRange.max;
    final max = resistivityRange.max * lengthRange.max / areaRange.min;
    return ResistanceInAWireRange(min, max, min);
  }

  /// PhET `getResistanceDecimals(resistance)`.
  static int getResistanceDecimals(double resistance) {
    if (resistance >= 100) return 0;
    if (resistance >= 10) return 1;
    if (resistance < 0.001) return 4;
    if (resistance < 1) return 3;
    return 2; // 1 ≤ R < 10
  }
}
