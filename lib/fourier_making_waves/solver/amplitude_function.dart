import 'dart:math' as math;

import '../model/domain.dart';
import '../model/series_type.dart';

/// Signature matching PhET `getAmplitudeFunction.ts` AmplitudeFunction.
typedef AmplitudeFunction = double Function(
  double A,
  int n,
  double x,
  double t,
  double L,
  double T,
);

/// Six amplitude functions + selector. PhET `getAmplitudeFunction.ts`
class AmplitudeFunctions {
  AmplitudeFunctions._();

  static AmplitudeFunction getAmplitudeFunction(
    Domain domain,
    SeriesType seriesType,
  ) {
    switch (domain) {
      case Domain.space:
        return seriesType == SeriesType.sin
            ? getAmplitudeSpaceSine
            : getAmplitudeSpaceCosine;
      case Domain.time:
        return seriesType == SeriesType.sin
            ? getAmplitudeTimeSine
            : getAmplitudeTimeCosine;
      case Domain.spaceAndTime:
        return seriesType == SeriesType.sin
            ? getAmplitudeSpaceAndTimeSine
            : getAmplitudeSpaceAndTimeCosine;
    }
  }

  static double getAmplitudeSpaceSine(
    double A,
    int n,
    double x,
    double t,
    double L,
    double T,
  ) {
    return A * math.sin(2 * math.pi * n * x / L);
  }

  static double getAmplitudeSpaceCosine(
    double A,
    int n,
    double x,
    double t,
    double L,
    double T,
  ) {
    return A * math.cos(2 * math.pi * n * x / L);
  }

  static double getAmplitudeTimeSine(
    double A,
    int n,
    double x,
    double t,
    double L,
    double T,
  ) {
    return A * math.sin(2 * math.pi * n * x / T);
  }

  static double getAmplitudeTimeCosine(
    double A,
    int n,
    double x,
    double t,
    double L,
    double T,
  ) {
    return A * math.cos(2 * math.pi * n * x / T);
  }

  static double getAmplitudeSpaceAndTimeSine(
    double A,
    int n,
    double x,
    double t,
    double L,
    double T,
  ) {
    return A * math.sin(2 * math.pi * n * (x / L - t / T));
  }

  static double getAmplitudeSpaceAndTimeCosine(
    double A,
    int n,
    double x,
    double t,
    double L,
    double T,
  ) {
    return A * math.cos(2 * math.pi * n * (x / L - t / T));
  }
}
