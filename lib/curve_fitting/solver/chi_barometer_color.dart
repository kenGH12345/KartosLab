import 'dart:math' as math;
import 'dart:ui';

import '../format_number.dart';

/// Exact port of `BarometerX2Node` chi→color / fill-ratio helpers
/// (including the Flash-era buggy `||` conditions).
class ChiBarometerColor {
  ChiBarometerColor._();

  static const double maxChiSquaredValue = 100;

  static const List<double> lowerLimitArray = [
    0.004,
    0.052,
    0.118,
    0.178,
    0.23,
    0.273,
    0.31,
    0.342,
    0.369,
    0.394,
    0.545,
    0.695,
    0.779,
    0.927,
  ];

  static const List<double> upperLimitArray = [
    3.8,
    3,
    2.6,
    2.37,
    2.21,
    2.1,
    2.01,
    1.94,
    1.88,
    1.83,
    1.57,
    1.35,
    1.24,
    1.07,
  ];

  /// Convert χ² to barometer fill color depending on number of points.
  static Color getFillColorFromChiSquaredValue(
    double chiSquaredValue,
    int numberOfPoints,
  ) {
    late final double lowerBound;
    late final double upperBound;

    // NOTE: PhET source uses `||` where `&&` was intended — ported exactly.
    if (numberOfPoints >= 1 && numberOfPoints < 11) {
      lowerBound = lowerLimitArray[numberOfPoints - 1];
      upperBound = upperLimitArray[numberOfPoints - 1];
    } else if (numberOfPoints >= 11 || numberOfPoints < 20) {
      lowerBound = (lowerLimitArray[9] + lowerLimitArray[10]) / 2;
      upperBound = (upperLimitArray[9] + upperLimitArray[10]) / 2;
    } else if (numberOfPoints >= 20 || numberOfPoints < 50) {
      lowerBound = (lowerLimitArray[10] + lowerLimitArray[11]) / 2;
      upperBound = (upperLimitArray[10] + upperLimitArray[11]) / 2;
    } else if (numberOfPoints >= 50) {
      lowerBound = lowerLimitArray[12];
      upperBound = upperLimitArray[12];
    } else {
      // Unreachable for normal n≥0 due to buggy ||; keep safe defaults.
      lowerBound = lowerLimitArray[0];
      upperBound = upperLimitArray[0];
    }

    final step1 = (1 + upperBound) / 2;
    final step2 = (lowerBound + 1) / 2;
    final step3 = (upperBound + step1) / 2;
    final step4 = (lowerBound + step2) / 2;

    late final double red;
    late final double green;
    late final double blue;

    if (chiSquaredValue < lowerBound) {
      red = 0;
      green = 0;
      blue = 1;
    } else if (chiSquaredValue >= lowerBound && chiSquaredValue < step4) {
      red = 0;
      green = (chiSquaredValue - lowerBound) / (step4 - lowerBound);
      blue = 1;
    } else if (chiSquaredValue >= step4 && chiSquaredValue < step2) {
      blue = (step2 - chiSquaredValue) / (step2 - step4);
      green = 1;
      red = 0;
    } else if (chiSquaredValue >= step2 && chiSquaredValue <= step1) {
      red = 0;
      green = 1;
      blue = 0;
    } else if (chiSquaredValue > step1 && chiSquaredValue < step3) {
      red = (chiSquaredValue - step1) / (step3 - step1);
      green = 1;
      blue = 0;
    } else if (chiSquaredValue >= step3 && chiSquaredValue < upperBound) {
      red = 1;
      green = (upperBound - chiSquaredValue) / (upperBound - step3);
      blue = 0;
    } else if (chiSquaredValue >= upperBound) {
      red = 1;
      green = 0;
      blue = 0;
    } else {
      red = 0;
      green = 0;
      blue = 0;
    }

    return Color.fromRGBO(
      roundSymmetric(red * 255).toInt(),
      roundSymmetric(green * 255).toInt(),
      roundSymmetric(blue * 255).toInt(),
      1,
    );
  }

  /// χ² → fill ratio ∈ [0, 1.023]. Linear for ≤1, log afterwards.
  static double chiSquaredValueToRatio(double value) {
    if (value <= 1) {
      return value / (1 + math.log(maxChiSquaredValue));
    }
    return math.min(
      1.023,
      (1 + math.log(value)) / (1 + math.log(maxChiSquaredValue)),
    );
  }
}
