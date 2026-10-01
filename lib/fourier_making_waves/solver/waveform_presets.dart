import 'dart:math' as math;

import '../model/domain.dart';
import '../model/series_type.dart';
import '../model/waveform_kind.dart';
import 'fourier_synthesis.dart';

/// Preset amplitudes + infinite-harmonics polylines. PhET `Waveform.ts`
class WaveformPresets {
  WaveformPresets._();

  static const double _pi = math.pi;

  /// Hardcoded wave-packet amplitude table. `Waveform.ts` WAVE_PACKET / issue #18
  static const List<List<double>> wavePacketAmplitudeTable = [
    [1.000000],
    [0.457833, 0.457833],
    [0.249352, 1.000000, 0.249352],
    [0.172422, 0.822578, 0.822578, 0.172422],
    [0.135335, 0.606531, 1.000000, 0.606531, 0.135335],
    [0.114162, 0.457833, 0.916855, 0.916855, 0.457833, 0.114162],
    [0.100669, 0.360448, 0.774837, 1.000000, 0.774837, 0.360448, 0.100669],
    [
      0.091394,
      0.295023,
      0.644389,
      0.952345,
      0.952345,
      0.644389,
      0.295023,
      0.091394,
    ],
    [
      0.084658,
      0.249352,
      0.539408,
      0.856997,
      1.000000,
      0.856997,
      0.539408,
      0.249352,
      0.084658,
    ],
    [
      0.079560,
      0.216255,
      0.457833,
      0.754840,
      0.969233,
      0.969233,
      0.754840,
      0.457833,
      0.216255,
      0.079560,
    ],
    [
      0.075574,
      0.191495,
      0.394652,
      0.661515,
      0.901851,
      1.000000,
      0.901851,
      0.661515,
      0.394652,
      0.191495,
      0.075574,
    ],
  ];

  /// `INFINITE_HARMONICS_BASE_POINTS.TRIANGLE`
  static const List<(double x, double y)> infiniteHarmonicsTriangle = [
    (-11 / 4, 1),
    (-9 / 4, -1),
    (-7 / 4, 1),
    (-5 / 4, -1),
    (-3 / 4, 1),
    (-1 / 4, -1),
    (1 / 4, 1),
    (3 / 4, -1),
    (5 / 4, 1),
    (7 / 4, -1),
    (9 / 4, 1),
    (11 / 4, -1),
  ];

  /// `INFINITE_HARMONICS_BASE_POINTS.SQUARE`
  static const List<(double x, double y)> infiniteHarmonicsSquare = [
    (-3, -1),
    (-3, 1),
    (-5 / 2, 1),
    (-5 / 2, -1),
    (-2, -1),
    (-2, 1),
    (-3 / 2, 1),
    (-3 / 2, -1),
    (-1, -1),
    (-1, 1),
    (-1 / 2, 1),
    (-1 / 2, -1),
    (0, -1),
    (0, 1),
    (1 / 2, 1),
    (1 / 2, -1),
    (1, -1),
    (1, 1),
    (3 / 2, 1),
    (3 / 2, -1),
    (2, -1),
    (2, 1),
    (5 / 2, 1),
    (5 / 2, -1),
    (3, -1),
    (3, 1),
  ];

  /// `INFINITE_HARMONICS_BASE_POINTS.SAWTOOTH`
  static const List<(double x, double y)> infiniteHarmonicsSawtooth = [
    (-7 / 2, 1),
    (-7 / 2, -1),
    (-5 / 2, 1),
    (-5 / 2, -1),
    (-3 / 2, 1),
    (-3 / 2, -1),
    (-1 / 2, 1),
    (-1 / 2, -1),
    (1 / 2, 1),
    (1 / 2, -1),
    (3 / 2, 1),
    (3 / 2, -1),
    (5 / 2, 1),
    (5 / 2, -1),
    (7 / 2, 1),
    (7 / 2, -1),
  ];

  static bool supportsInfiniteHarmonics(WaveformKind kind) {
    return kind == WaveformKind.triangle ||
        kind == WaveformKind.square ||
        kind == WaveformKind.sawtooth;
  }

  /// Amplitudes ordered by increasing harmonic order (length = [numberOfHarmonics]).
  static List<double> getAmplitudes(
    WaveformKind kind,
    int numberOfHarmonics,
    SeriesType seriesType,
  ) {
    assert(numberOfHarmonics >= 1);
    switch (kind) {
      case WaveformKind.sinusoid:
        return List<double>.generate(
          numberOfHarmonics,
          (i) => i == 0 ? 1.0 : 0.0,
        );
      case WaveformKind.triangle:
        return _triangleAmplitudes(numberOfHarmonics, seriesType);
      case WaveformKind.square:
        return _squareAmplitudes(numberOfHarmonics, seriesType);
      case WaveformKind.sawtooth:
        assert(seriesType != SeriesType.cos,
            'cannot make a sawtooth wave out of cosines');
        return _sawtoothAmplitudes(numberOfHarmonics);
      case WaveformKind.wavePacket:
        return List<double>.from(
          wavePacketAmplitudeTable[numberOfHarmonics - 1],
        );
      case WaveformKind.custom:
        throw StateError('getAmplitudes is not supported for CUSTOM.');
    }
  }

  static List<double> _triangleAmplitudes(int nHarmonics, SeriesType seriesType) {
    final amplitudes = <double>[];
    for (var n = 1; n <= nHarmonics; n++) {
      if (seriesType == SeriesType.sin) {
        // 8/(1*PI^2), 0, -8/(9*PI^2), ...
        amplitudes.add(
          n % 2 == 0
              ? 0
              : math.pow(-1, (n - 1) / 2).toDouble() *
                  (8 / (n * n * _pi * _pi)),
        );
      } else {
        // 8/(1*PI^2), 0, 8/(9*PI^2), ...
        amplitudes.add(n % 2 == 0 ? 0 : (8 / (n * n * _pi * _pi)));
      }
    }
    return amplitudes;
  }

  static List<double> _squareAmplitudes(int nHarmonics, SeriesType seriesType) {
    final amplitudes = <double>[];
    for (var n = 1; n <= nHarmonics; n++) {
      if (seriesType == SeriesType.sin) {
        // 4/(1*PI), 0, 4/(3*PI), ...
        amplitudes.add(n % 2 == 0 ? 0 : (4 / (n * _pi)));
      } else {
        // 4/(1*PI), 0, -4/(3*PI), ...
        amplitudes.add(
          n % 2 == 0
              ? 0
              : math.pow(-1, (n - 1) / 2).toDouble() * (4 / (n * _pi)),
        );
      }
    }
    return amplitudes;
  }

  static List<double> _sawtoothAmplitudes(int nHarmonics) {
    final amplitudes = <double>[];
    for (var n = 1; n <= nHarmonics; n++) {
      // 2/(1*PI), -2/(2*PI), 2/(3*PI), ...
      amplitudes.add(math.pow(-1, n - 1).toDouble() * (2 / (n * _pi)));
    }
    return amplitudes;
  }

  /// Infinite-harmonics polyline, or null if unsupported.
  static List<FmwPoint>? getInfiniteHarmonicsDataSet(
    WaveformKind kind,
    Domain domain,
    SeriesType seriesType,
    double t,
    double L,
    double T,
  ) {
    final List<(double x, double y)>? base;
    switch (kind) {
      case WaveformKind.triangle:
        base = infiniteHarmonicsTriangle;
      case WaveformKind.square:
        base = infiniteHarmonicsSquare;
      case WaveformKind.sawtooth:
        base = infiniteHarmonicsSawtooth;
      case WaveformKind.sinusoid:
      case WaveformKind.wavePacket:
      case WaveformKind.custom:
        return null;
    }
    return mapBasePointsToDataSet(base, domain, seriesType, t, L, T);
  }

  /// PhET `mapBasePointsToDataSet` in `Waveform.ts`.
  static List<FmwPoint> mapBasePointsToDataSet(
    List<(double x, double y)> basePoints,
    Domain domain,
    SeriesType seriesType,
    double t,
    double L,
    double T,
  ) {
    final x = domain == Domain.time ? T : L;
    var shiftX = seriesType == SeriesType.sin ? 0.0 : (-0.25 * x);

    if (domain == Domain.spaceAndTime) {
      final remainder = (t / T - x / L) % 1;
      shiftX += remainder * x;
    }

    return [
      for (final p in basePoints) FmwPoint(x * p.$1 + shiftX, p.$2),
    ];
  }
}
