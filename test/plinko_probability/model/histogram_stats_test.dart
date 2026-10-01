import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/plinko_probability/model/histogram.dart';

void main() {
  group('Histogram statistics', () {
    test('single sample: average=bin, stddev=0', () {
      final h = Histogram(12);
      h.bins[12].visibleBinCount++;
      h.updateStatistics(12);
      expect(h.landedBallsNumber, 1);
      expect(h.average, 12);
      expect(h.standardDeviation, 0);
      expect(h.standardDeviationOfMean, 0);
    });

    test('bins 0 and 2: mean=1, sample stddev=sqrt(2)', () {
      final h = Histogram(4);
      h.bins[0].visibleBinCount++;
      h.updateStatistics(0);
      h.bins[2].visibleBinCount++;
      h.updateStatistics(2);
      expect(h.average, closeTo(1.0, 1e-12));
      expect(h.standardDeviation, closeTo(math.sqrt(2), 1e-12));
      expect(
        h.standardDeviationOfMean,
        closeTo(math.sqrt(2) / math.sqrt(2), 1e-12),
      );
    });

    test('fractional counts sum to 1', () {
      final h = Histogram(3);
      for (final k in [0, 1, 1, 2]) {
        h.bins[k].visibleBinCount++;
        h.updateStatistics(k);
      }
      final sum =
          List.generate(4, h.getFractionalBinCount).reduce((a, b) => a + b);
      expect(sum, closeTo(1.0, 1e-12));
    });

    test('normalized sample has max 1', () {
      final h = Histogram(3);
      for (final k in [1, 1, 2]) {
        h.bins[k].visibleBinCount++;
        h.updateStatistics(k);
      }
      final norm = h.getNormalizedSampleDistribution();
      expect(norm.reduce(math.max), 1.0);
    });
  });
}
