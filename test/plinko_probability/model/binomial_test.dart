import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/plinko_probability/model/lab_model.dart';

void main() {
  group('Binomial theoretical', () {
    final model = LabModel();

    test('mu = n p', () {
      expect(model.getTheoreticalAverage(12, 0.5), 6);
      expect(model.getTheoreticalAverage(10, 0.3), closeTo(3.0, 1e-12));
    });

    test('sigma = sqrt(n p (1-p))', () {
      expect(
        model.getTheoreticalStandardDeviation(12, 0.5),
        closeTo(math.sqrt(3), 1e-12),
      );
    });

    test('C(5,2) = 10', () {
      expect(model.getBinomialCoefficient(5, 2), 10);
    });

    test('P(n,k,p) sums to ~1', () {
      model
        ..numberOfRows = 8
        ..probability = 0.5;
      final dist = model.getBinomialDistribution();
      expect(dist.reduce((a, b) => a + b), closeTo(1.0, 1e-10));
    });

    test('normalized max is 1', () {
      model
        ..numberOfRows = 12
        ..probability = 0.5;
      final norm = model.getNormalizedBinomialDistribution();
      expect(norm.reduce(math.max), closeTo(1.0, 1e-12));
    });
  });
}
