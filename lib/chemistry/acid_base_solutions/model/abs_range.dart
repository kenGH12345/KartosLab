import 'dart:math' as math;

/// Inclusive numeric range — PhET `dot/js/Range.ts`.
class AbsRange {
  const AbsRange(this.min, this.max);

  final double min;
  final double max;

  bool contains(double value) => value >= min && value <= max;

  double constrain(double value) => math.min(math.max(value, min), max);

  double get length => max - min;
}

/// Inclusive range with reset default — PhET `dot/js/RangeWithValue.ts`.
class AbsRangeWithValue extends AbsRange {
  const AbsRangeWithValue(super.min, super.max, this.defaultValue);

  final double defaultValue;
}
