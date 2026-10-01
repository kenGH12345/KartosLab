import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/curve_fitting/model/data_point.dart';
import 'package:kratos/curve_fitting/solver/regression_solver.dart';

void main() {
  group('RegressionSolver.getBestFitCoefficients', () {
    test('perfect linear y = 2 + 3x', () {
      final points = [
        DataPoint(x: 0, y: 2, delta: 1),
        DataPoint(x: 1, y: 5, delta: 1),
        DataPoint(x: 2, y: 8, delta: 1),
      ];
      final c = RegressionSolver.getBestFitCoefficients(points, 1);
      expect(c.length, 2);
      expect(c[0], closeTo(2, 1e-9));
      expect(c[1], closeTo(3, 1e-9));
    });

    test('perfect quadratic y = 1 + 2x + 3x²', () {
      final points = [
        DataPoint(x: -1, y: 2, delta: 1), // 1 - 2 + 3 = 2
        DataPoint(x: 0, y: 1, delta: 1),
        DataPoint(x: 1, y: 6, delta: 1), // 1 + 2 + 3
        DataPoint(x: 2, y: 17, delta: 1), // 1 + 4 + 12
      ];
      final c = RegressionSolver.getBestFitCoefficients(points, 2);
      expect(c.length, 3);
      expect(c[0], closeTo(1, 1e-8));
      expect(c[1], closeTo(2, 1e-8));
      expect(c[2], closeTo(3, 1e-8));
    });

    test('perfect cubic y = 1 + x + x² + x³', () {
      double f(double x) => 1 + x + x * x + x * x * x;
      final xs = [-2.0, -1.0, 0.0, 1.0, 2.0];
      final points = [
        for (final x in xs) DataPoint(x: x, y: f(x), delta: 1),
      ];
      final c = RegressionSolver.getBestFitCoefficients(points, 3);
      expect(c.length, 4);
      expect(c[0], closeTo(1, 1e-7));
      expect(c[1], closeTo(1, 1e-7));
      expect(c[2], closeTo(1, 1e-7));
      expect(c[3], closeTo(1, 1e-7));
    });

    test('singular / identical x → zero coefficients', () {
      final points = [
        DataPoint(x: 1, y: 0, delta: 1),
        DataPoint(x: 1, y: 1, delta: 1),
        DataPoint(x: 1, y: 2, delta: 1),
      ];
      // unique X = 1 → rank 1 for order 1; still solvable for a0 only.
      // For order 2 with uniqueX=1, rank=1 → [a0, 0, 0] from 1×1.
      final c = RegressionSolver.getBestFitCoefficients(points, 2);
      expect(c.length, 3);
      // Only rank-1 mean of y (weighted): all same weight → a0 = mean(y)=1
      expect(c[0], closeTo(1, 1e-9));
      expect(c[1], 0);
      expect(c[2], 0);
    });

    test('insufficient points for order still returns length order+1', () {
      final points = [
        DataPoint(x: 0, y: 1, delta: 1),
        DataPoint(x: 1, y: 2, delta: 1),
      ];
      final c = RegressionSolver.getBestFitCoefficients(points, 3);
      expect(c.length, 4);
      // rank = min(4, 2) = 2 → linear subspace fit into cubic slot
      expect(c[0], closeTo(1, 1e-9));
      expect(c[1], closeTo(1, 1e-9));
      expect(c[2], 0);
      expect(c[3], 0);
    });

    test('no points → all zeros', () {
      final c = RegressionSolver.getBestFitCoefficients([], 1);
      expect(c, [0.0, 0.0]);
    });
  });

  group('RegressionSolver.getYValueAt', () {
    test('polynomial evaluation', () {
      expect(RegressionSolver.getYValueAt([2, 3], 4), 2 + 3 * 4);
      expect(RegressionSolver.getYValueAt([1, 0, 2], 3), 1 + 2 * 9);
    });
  });
}
