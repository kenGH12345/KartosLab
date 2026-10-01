import 'dart:math' as math;

import '../fmw_constants.dart';
import '../model/axis_description.dart';
import '../model/domain.dart';
import '../model/series_type.dart';
import 'amplitude_function.dart';

/// Sample point equivalent to PhET `Vector2` used in chart data sets.
class FmwPoint {
  const FmwPoint(this.x, this.y);

  final double x;
  final double y;

  @override
  String toString() => 'FmwPoint($x, $y)';

  @override
  bool operator ==(Object other) =>
      other is FmwPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

/// Fourier sum / harmonic sampling. PhET `FourierSeries` / `Harmonic`.
class FourierSynthesis {
  FourierSynthesis._();

  /// Sum of harmonics. `FourierSeries.createSumDataSet`
  ///
  /// Uses `dx = xRange.length / MAX_POINTS_PER_DATA_SET` (not numberOfPoints-1).
  static List<FmwPoint> createSumDataSet({
    required List<double> amplitudes,
    required AxisDescription xAxisDescription,
    required Domain domain,
    required SeriesType seriesType,
    required double t,
    double L = FmwConstants.L,
    double T = FmwConstants.T,
  }) {
    assert(t >= 0);
    final xRange = xAxisDescription.createRangeForDomain(domain, L, T);
    final xMin = xRange.$1;
    final xMax = xRange.$2;
    final dx = (xMax - xMin) / FmwConstants.maxPointsPerDataSet;
    final amplitudeFunction =
        AmplitudeFunctions.getAmplitudeFunction(domain, seriesType);

    final sumDataSet = <FmwPoint>[];
    var x = xMin;
    while (x <= xMax) {
      var y = 0.0;
      for (var i = 0; i < amplitudes.length; i++) {
        final amplitude = amplitudes[i];
        if (amplitude != 0) {
          final order = i + 1;
          y += amplitudeFunction(amplitude, order, x, t, L, T);
        }
      }
      sumDataSet.add(FmwPoint(x, y));
      x += dx;
    }
    return sumDataSet;
  }

  /// Single harmonic data set. `Harmonic.createDataSetStatic`
  ///
  /// [numberOfPoints] defaults to order-scaled count used by `HarmonicsChart`.
  static List<FmwPoint> createHarmonicDataSet({
    required int order,
    required double amplitude,
    required AxisDescription xAxisDescription,
    required Domain domain,
    required SeriesType seriesType,
    required double t,
    int? numberOfPoints,
    int maxHarmonics = FmwConstants.maxHarmonics,
    double L = FmwConstants.L,
    double T = FmwConstants.T,
  }) {
    assert(order >= 1);
    assert(t >= 0);

    final points = numberOfPoints ??
        math.max(
          2,
          (FmwConstants.maxPointsPerDataSet * order / maxHarmonics).ceil(),
        );

    final xRange = xAxisDescription.createRangeForDomain(domain, L, T);
    return createHarmonicDataSetForRange(
      order: order,
      amplitude: amplitude,
      numberOfPoints: points,
      xMin: xRange.$1,
      xMax: xRange.$2,
      domain: domain,
      seriesType: seriesType,
      t: t,
      L: L,
      T: T,
    );
  }

  /// Harmonic samples over an explicit x range (Wave Packet components).
  static List<FmwPoint> createHarmonicDataSetForRange({
    required int order,
    required double amplitude,
    required int numberOfPoints,
    required double xMin,
    required double xMax,
    required Domain domain,
    required SeriesType seriesType,
    required double t,
    required double L,
    required double T,
  }) {
    assert(order >= 1);
    assert(numberOfPoints > 0);
    assert(L > 0 && T > 0);
    assert(t >= 0);

    final amplitudeFunction =
        AmplitudeFunctions.getAmplitudeFunction(domain, seriesType);
    final dx = (xMax - xMin) / (numberOfPoints - 1);

    final dataSet = <FmwPoint>[];
    var x = xMin;
    for (var i = 0; i < numberOfPoints; i++) {
      final y = amplitudeFunction(amplitude, order, x, t, L, T);
      dataSet.add(FmwPoint(x, y));
      x += dx;
    }
    return dataSet;
  }
}
