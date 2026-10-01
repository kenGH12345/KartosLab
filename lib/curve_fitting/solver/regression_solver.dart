import 'dart:math' as math;

import '../curve_fitting_constants.dart';
import '../model/data_point.dart';
import 'matrix_solver.dart';

/// Weighted least-squares polynomial regression — exact port of
/// `Curve.getBestFitCoefficients` / `getYValueAt`.
class RegressionSolver {
  RegressionSolver._();

  /// y = Σ a_i · x^i  (coefficients ascending).
  static double getYValueAt(List<double> coefficients, double x) {
    var y = 0.0;
    for (var i = 0; i < coefficients.length; i++) {
      y += coefficients[i] * math.pow(x, i);
    }
    return y;
  }

  /// Best-fit coefficients of length [order]+1.
  ///
  /// Weight w = 1/δ².
  /// square[i][j] = Σ x^(i+j) / δ²
  /// column[i]    = Σ x^i · y / δ²
  /// rank = min(order+1, unique X count)
  /// If |det| ≤ 1e-30 → all zeros; else solve via Gaussian elimination.
  static List<double> getBestFitCoefficients(
    List<DataPoint> points,
    int order, {
    int? uniqueXCount,
  }) {
    final solutionArrayLength = order + 1;
    final unique = uniqueXCount ?? _uniqueXCount(points);
    final matrixRank = math.min(solutionArrayLength, unique);

    final squareMatrix = List.generate(
      matrixRank,
      (_) => List<double>.filled(matrixRank, 0),
    );
    final columnMatrix = List<double>.filled(matrixRank, 0);

    for (var i = 0; i < matrixRank; i++) {
      var col = 0.0;
      for (final point in points) {
        final deltaSquared = point.delta * point.delta;
        col += math.pow(point.x, i) * point.y / deltaSquared;
      }
      columnMatrix[i] = col;
    }

    for (var i = 0; i < matrixRank; i++) {
      for (var j = 0; j < matrixRank; j++) {
        var sum = 0.0;
        for (final point in points) {
          final deltaSquared = point.delta * point.delta;
          sum += math.pow(point.x, i + j) / deltaSquared;
        }
        squareMatrix[i][j] = sum;
      }
    }

    final bestFitCoefficients = List<double>.filled(solutionArrayLength, 0);

    if (matrixRank > 0 &&
        MatrixSolver.det(squareMatrix).abs() >
            CurveFittingConstants.determinantEpsilon) {
      final solution = MatrixSolver.solve(squareMatrix, columnMatrix);
      for (var i = 0; i < matrixRank; i++) {
        bestFitCoefficients[i] = solution[i];
      }
    }

    return bestFitCoefficients;
  }

  static int _uniqueXCount(List<DataPoint> points) {
    final xs = <double>{};
    for (final p in points) {
      xs.add(p.x);
    }
    return xs.length;
  }
}
