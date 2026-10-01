/// Model-only constants from PhET `OhmsLawConstants.js` (1.5.0-dev.6).
///
/// View geometry / fonts / colors are intentionally omitted.
library;

/// Inclusive numeric range with default (PhET `RangeWithValue`).
class OhmsLawRange {
  const OhmsLawRange(this.min, this.max, this.defaultValue)
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

/// Source: `OhmsLawConstants.js`.
abstract final class OhmsLawConstants {
  /// Volts — `RangeWithValue( 0.1, 9, 4.5 )`.
  static const OhmsLawRange voltageRange = OhmsLawRange(0.1, 9.0, 4.5);

  /// Ohms — `RangeWithValue( 10, 1000, 500 )`.
  static const OhmsLawRange resistanceRange = OhmsLawRange(10.0, 1000.0, 500.0);

  /// Convert amperes → milliamps in `computeCurrent`.
  static const double amperesToMilliamps = 1000.0;

  /// Display decimal places (View formatting / `getFixedCurrent`).
  static const int voltageSigFigs = 1;
  static const int resistanceSigFigs = 0;
  static const int currentMilliampsSigFigs = 1;
  static const int currentAmpsSigFigs = 3;

  ///
  /// PhET `CURRENT_RANGE` (amperes) = `V/R` bounds — used by sound normalization
  /// in View; kept here because it is defined on OhmsLawConstants in source.
  ///
  /// min = 0.1/1000 = 1e-4 A, max = 9/10 = 0.9 A
  static const double currentRangeAmpsMin =
      0.1 / 1000.0; // voltageMin / resistanceMax
  static const double currentRangeAmpsMax = 9.0 / 10.0; // voltageMax / resistanceMin

  /// AA cell voltage (batteries View) — not used by Model physics, but referenced
  /// by source constants next to ranges; excluded from Model API surface.
}
