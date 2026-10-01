import 'dart:math' as math;

import '../curve_fitting_constants.dart';
import '../model/data_point.dart';
import 'regression_solver.dart';

/// Result of [StatisticsSolver.computeRAndChiSquared].
class RAndChiSquared {
  const RAndChiSquared({required this.chiSquared, required this.rSquared});

  /// Reduced χ² = |RSS / max(dof, 1)|, dof = n − order − 1.
  final double chiSquared;

  /// Weighted r² in [0, 1], or NaN when variance ≈ 0.
  final double rSquared;
}

/// Exact port of `Curve.updateRAndChiSquared`.
class StatisticsSolver {
  StatisticsSolver._();

  static RAndChiSquared computeRAndChiSquared({
    required List<DataPoint> points,
    required List<double> coefficients,
    required int order,
  }) {
    final numberOfPoints = points.length;

    if (numberOfPoints < 2) {
      return const RAndChiSquared(chiSquared: 0, rSquared: 0);
    }

    var weightSum = 0.0;
    var ySum = 0.0;
    var yySum = 0.0;
    // ignore: unused_local_variable — PhET accumulates yAtSum (unused later).
    var yAtSum = 0.0;
    var yAtySum = 0.0;
    var yAtyAtSum = 0.0;

    for (final point in points) {
      final x = point.x;
      final y = point.y;
      final yAt = RegressionSolver.getYValueAt(coefficients, x);
      final weight = 1 / (point.delta * point.delta);

      weightSum += weight;
      ySum += weight * y;
      yAtSum += weight * yAt;
      yySum += weight * y * y;
      yAtySum += weight * yAt * y;
      yAtyAtSum += weight * yAt * yAt;
    }

    final weightAverage = weightSum / numberOfPoints;
    final denominator = weightAverage * numberOfPoints;
    final yAverage = ySum / denominator;
    final yyAverage = yySum / denominator;

    final residualSumOfSquares = yySum - 2 * yAtySum + yAtyAtSum;
    final averageOfResidualSquares = residualSumOfSquares / denominator;
    final averageOfSquares = yyAverage - yAverage * yAverage;

    final degreesOfFreedom = numberOfPoints - order - 1;
    final chiSquared =
        (residualSumOfSquares / math.max(degreesOfFreedom, 1)).abs();

    late final double rSquared;
    if (averageOfSquares.abs() < CurveFittingConstants.epsilon) {
      rSquared = double.nan;
    } else if (averageOfResidualSquares.abs() < CurveFittingConstants.epsilon) {
      rSquared = 1;
    } else if (averageOfResidualSquares / averageOfSquares > 1) {
      rSquared = 0;
    } else {
      rSquared = 1 - averageOfResidualSquares / averageOfSquares;
    }

    return RAndChiSquared(chiSquared: chiSquared, rSquared: rSquared);
  }
}
