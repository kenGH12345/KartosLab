import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/curve_fitting/model/data_point.dart';
import 'package:kratos/curve_fitting/solver/statistics_solver.dart';

void main() {
  group('StatisticsSolver.computeRAndChiSquared', () {
    test('n < 2 → chi=0, r=0', () {
      final s = StatisticsSolver.computeRAndChiSquared(
        points: [DataPoint(x: 0, y: 1, delta: 1)],
        coefficients: [0, 1],
        order: 1,
      );
      expect(s.chiSquared, 0);
      expect(s.rSquared, 0);
    });

    test('exact linear fit → r²=1, χ²≈0', () {
      final points = [
        DataPoint(x: 0, y: 1, delta: 1),
        DataPoint(x: 1, y: 3, delta: 1),
        DataPoint(x: 2, y: 5, delta: 1),
      ];
      // y = 1 + 2x
      final s = StatisticsSolver.computeRAndChiSquared(
        points: points,
        coefficients: [1, 2],
        order: 1,
      );
      expect(s.rSquared, closeTo(1, 1e-12));
      expect(s.chiSquared, closeTo(0, 1e-12));
    });

    test('zero variance in y → r² is NaN', () {
      final points = [
        DataPoint(x: 0, y: 5, delta: 1),
        DataPoint(x: 1, y: 5, delta: 1),
        DataPoint(x: 2, y: 5, delta: 1),
      ];
      // Bad adjustable fit far from constant 5
      final s = StatisticsSolver.computeRAndChiSquared(
        points: points,
        coefficients: [0, 10],
        order: 1,
      );
      expect(s.rSquared, isNaN);
    });

    test('very poor fit → negative ratio clamped to r²=0', () {
      final points = [
        DataPoint(x: 0, y: 0, delta: 1),
        DataPoint(x: 1, y: 1, delta: 1),
        DataPoint(x: 2, y: 2, delta: 1),
        DataPoint(x: 3, y: 3, delta: 1),
      ];
      // Wild cubic-ish line far from data
      final s = StatisticsSolver.computeRAndChiSquared(
        points: points,
        coefficients: [100, -50],
        order: 1,
      );
      expect(s.rSquared, 0);
      expect(s.chiSquared, greaterThan(0));
    });

    test('reduced χ² uses dof = n - order - 1', () {
      final points = [
        DataPoint(x: 0, y: 0, delta: 1),
        DataPoint(x: 1, y: 0, delta: 1),
        DataPoint(x: 2, y: 0, delta: 1),
        DataPoint(x: 3, y: 0, delta: 1),
      ];
      // Fit y=1 constant residual 1 each → RSS = Σ w*(1)^2 = 4
      // dof = 4 - 1 - 1 = 2 → χ² = |4/2| = 2
      final s = StatisticsSolver.computeRAndChiSquared(
        points: points,
        coefficients: [1, 0],
        order: 1,
      );
      expect(s.chiSquared, closeTo(2, 1e-12));
    });

    test('partial fit yields r² in (0,1)', () {
      final points = [
        DataPoint(x: 0, y: 0, delta: 1),
        DataPoint(x: 1, y: 1, delta: 1),
        DataPoint(x: 2, y: 2, delta: 1),
        DataPoint(x: 3, y: 4, delta: 1), // off the line y=x
      ];
      final s = StatisticsSolver.computeRAndChiSquared(
        points: points,
        coefficients: [0, 1],
        order: 1,
      );
      expect(s.rSquared, greaterThan(0));
      expect(s.rSquared, lessThan(1));
      expect(s.chiSquared, greaterThan(0));
    });
  });
}
