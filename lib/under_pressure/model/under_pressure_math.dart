import 'dart:math' as math;

/// PhET `dot/js/util` helpers used by Under Pressure / FPAF.
class UnderPressureMath {
  UnderPressureMath._();

  /// PhET `Utils.linear(x1, x2, y1, y2, x)`.
  static double linear(
    double x1,
    double x2,
    double y1,
    double y2,
    double x,
  ) {
    return y1 + (x - x1) * (y2 - y1) / (x2 - x1);
  }

  /// PhET `dot/js/util/roundSymmetric.ts` — half away from zero.
  static double roundSymmetric(double value) {
    if (value < 0) {
      return -(value.abs() + 0.5).floorToDouble();
    }
    return (value + 0.5).floorToDouble();
  }

  /// PhET `Utils.toFixedNumber`.
  static double toFixedNumber(double value, int decimalPlaces) {
    final factor = math.pow(10, decimalPlaces).toDouble();
    return roundSymmetric(value * factor) / factor;
  }

  /// PhET `Utils.toFixed` — fixed-decimal display string.
  static String toFixed(double value, int decimalPlaces) =>
      toFixedNumber(value, decimalPlaces).toStringAsFixed(decimalPlaces);
}

/// PhET `dot/js/LinearFunction` — maps x∈[x1,x2] → y∈[y1,y2].
class LinearFunction {
  LinearFunction(this.x1, this.x2, this.y1, this.y2);

  final double x1;
  final double x2;
  final double y1;
  final double y2;

  double evaluate(double x) =>
      UnderPressureMath.linear(x1, x2, y1, y2, x);
}
