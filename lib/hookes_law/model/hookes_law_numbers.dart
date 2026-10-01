import 'dart:math' as math;

/// PhET `dot` helpers used by Hooke's Law. Not a general math library.
class HookesLawNumbers {
  const HookesLawNumbers._();

  /// `dot/js/util/toFixedNumber.ts`: `Number(value.toFixed(decimalPlaces))`.
  static double toFixedNumber(double value, int decimalPlaces) {
    return double.parse(value.toStringAsFixed(decimalPlaces));
  }

  /// `dot/js/util/roundSymmetric.ts`.
  /// Half away from zero. JS `Math.round` is not the same for negatives.
  static double roundSymmetric(double value) {
    if (value < 0) {
      return (value - 0.5).ceilToDouble();
    }
    return (value + 0.5).floorToDouble();
  }

  /// `dot/js/util/roundToInterval.ts`.
  static double roundToInterval(double value, double interval) {
    return roundSymmetric(value / interval) * interval;
  }
}

/// Inclusive numeric range. `dot/js/Range.ts` `constrainValue`.
class HookesLawRange {
  const HookesLawRange(this.min, this.max);

  final double min;
  final double max;

  double constrain(double value) => math.min(math.max(value, min), max);

  double get length => max - min;
}

/// Inclusive range plus the value used by `reset`. `dot/js/RangeWithValue.ts`.
class RangeWithValue extends HookesLawRange {
  const RangeWithValue(super.min, super.max, this.defaultValue);

  final double defaultValue;
}
