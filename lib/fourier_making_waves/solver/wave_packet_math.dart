import 'dart:math' as math;

import '../fmw_constants.dart';
import '../model/domain.dart';
import '../model/series_type.dart';
import '../model/wave_packet.dart';
import 'fourier_synthesis.dart';

/// Wave-packet Gaussian math. PhET `WavePacket.ts` / `WavePacketSumChart.ts` /
/// `WavePacketComponentsChart.ts`
class WavePacketMath {
  WavePacketMath._();

  /// Gaussian amplitude A(k). `WavePacket.getComponentAmplitude`
  ///
  /// A(k,k0,dk) = exp( -((k-k0)^2) / (2 * dk^2) ) / (dk * sqrt(2π))
  static double gaussianAmplitude({
    required double waveNumber,
    required double center,
    required double standardDeviation,
  }) {
    final sigma = standardDeviation;
    final dk = waveNumber - center;
    return math.exp(-(dk * dk) / (2 * sigma * sigma)) /
        (sigma * math.sqrt(2 * math.pi));
  }

  /// Fourier components for finite spacing. `WavePacket.componentsProperty`
  static List<FourierComponent> createComponents({
    required double componentSpacing,
    required double center,
    required double standardDeviation,
    required double waveNumberMax,
  }) {
    if (componentSpacing == 0) return const [];

    final numberOfComponents =
        (waveNumberMax / componentSpacing).floor() + 1;
    final components = <FourierComponent>[];
    for (var i = 0; i < numberOfComponents; i++) {
      final waveNumber = i * componentSpacing;
      final amplitude = gaussianAmplitude(
            waveNumber: waveNumber,
            center: center,
            standardDeviation: standardDeviation,
          ) *
          componentSpacing;
      components.add(FourierComponent(waveNumber, amplitude));
    }
    return components;
  }

  /// Waveform data sets for each Fourier component.
  /// `WavePacketComponentsChart.createComponentsDataSets`
  static List<List<FmwPoint>> createComponentsDataSets({
    required List<FourierComponent> components,
    required double componentSpacing,
    required Domain domain,
    required SeriesType seriesType,
    required double xMin,
    required double xMax,
  }) {
    assert(components.isNotEmpty);
    assert(componentSpacing >= 0);

    final L = 2 * math.pi / componentSpacing;
    final T = L; // WavePacket assumes L === T
    const t = 0.0;

    final dataSets = <List<FmwPoint>>[];
    for (var order = 1; order <= components.length; order++) {
      final amplitude = components[order - 1].amplitude;
      dataSets.add(
        FourierSynthesis.createHarmonicDataSetForRange(
          order: order,
          amplitude: amplitude,
          numberOfPoints: FmwConstants.maxPointsPerDataSet,
          xMin: xMin,
          xMax: xMax,
          domain: domain,
          seriesType: seriesType,
          t: t,
          L: L,
          T: T,
        ),
      );
    }
    return dataSets;
  }

  /// Sum y-values of aligned component data sets.
  /// `WavePacketSumChart.createSumDataSet`
  static List<FmwPoint> createFiniteSumDataSet(List<List<FmwPoint>> dataSets) {
    assert(dataSets.isNotEmpty);
    final pointsPerDataSet = dataSets.first.length;
    assert(pointsPerDataSet > 0);

    final dataSet = <FmwPoint>[];
    for (var i = 0; i < pointsPerDataSet; i++) {
      var sum = 0.0;
      final x = dataSets[0][i].x;
      for (var j = 0; j < dataSets.length; j++) {
        assert(dataSets[j][i].x == x);
        sum += dataSets[j][i].y;
      }
      dataSet.add(FmwPoint(x, sum));
    }
    return dataSet;
  }

  /// Infinite-components analytic wave packet.
  /// `WavePacketSumChart.createWavePacketDataSet`
  static List<FmwPoint> createWavePacketDataSet({
    required double center,
    required double conjugateStandardDeviation,
    required SeriesType seriesType,
    required double xMin,
    required double xMax,
  }) {
    assert(center > 0);
    assert(conjugateStandardDeviation > 0);

    final dataSet = <FmwPoint>[];
    final numberOfPoints = FmwConstants.maxPointsPerDataSet + 1;
    final dx = (xMax - xMin) / numberOfPoints;

    for (var i = 0; i < numberOfPoints; i++) {
      final x = xMin + (i * dx);
      final sinCosTerm = seriesType == SeriesType.sin
          ? math.sin(center * x)
          : math.cos(center * x);
      final y = math.exp(
            -(x * x) /
                (2 *
                    conjugateStandardDeviation *
                    conjugateStandardDeviation),
          ) *
          sinCosTerm;
      dataSet.add(FmwPoint(x, y));
    }
    return dataSet;
  }

  /// Continuous Gaussian amplitude curve on Amplitudes chart.
  /// `WavePacketAmplitudesChart.createContinuousWaveformDataSet`
  ///
  /// Samples k from [0, 24π] with step π/10; amplitude = A(k) or A(k)·Δk.
  static List<FmwPoint> createContinuousWaveformDataSet({
    required double center,
    required double standardDeviation,
    required double componentSpacing,
    double waveNumberMin = 0,
    double? waveNumberMax,
  }) {
    final maxK = waveNumberMax ?? (24 * math.pi);
    final step = math.pi / 10;
    final dataSet = <FmwPoint>[];
    var waveNumber = waveNumberMin;
    final end = maxK + step;
    while (waveNumber <= end) {
      var amplitude = gaussianAmplitude(
        waveNumber: waveNumber,
        center: center,
        standardDeviation: standardDeviation,
      );
      if (componentSpacing != 0) {
        amplitude *= componentSpacing;
      }
      dataSet.add(FmwPoint(waveNumber, amplitude));
      waveNumber += step;
    }
    return dataSet;
  }

  /// Width-indicator math for Amplitudes chart.
  /// width = 2σ; position = (center, A(center+σ)[·spacing])
  static ({double width, double x, double y}) amplitudesWidthIndicator({
    required double center,
    required double standardDeviation,
    required double componentSpacing,
  }) {
    final width = 2 * standardDeviation;
    var y = gaussianAmplitude(
      waveNumber: center + standardDeviation,
      center: center,
      standardDeviation: standardDeviation,
    );
    if (componentSpacing != 0) {
      y *= componentSpacing;
    }
    return (width: width, x: center, y: y);
  }

  /// Width-indicator math for Sum chart.
  /// width = 2σₓ; position = (0, 1/√e)
  static ({double width, double x, double y}) sumWidthIndicator({
    required double conjugateStandardDeviation,
  }) {
    return (
      width: 2 * conjugateStandardDeviation,
      x: 0,
      y: 1 / math.sqrt(math.e),
    );
  }

  /// Envelope from sin and cos data sets: y = sqrt(y1² + y2²).
  /// `WavePacketSumChart.createEnvelopeDataSet`
  static List<FmwPoint> createEnvelopeDataSet(
    List<FmwPoint> dataSet1,
    List<FmwPoint> dataSet2,
  ) {
    assert(dataSet1.isNotEmpty);
    assert(dataSet1.length == dataSet2.length);

    final dataSet = <FmwPoint>[];
    for (var i = 0; i < dataSet1.length; i++) {
      final x = dataSet1[i].x;
      assert(x == dataSet2[i].x);
      final y1 = dataSet1[i].y;
      final y2 = dataSet2[i].y;
      dataSet.add(FmwPoint(x, math.sqrt(y1 * y1 + y2 * y2)));
    }
    return dataSet;
  }
}
