import 'dart:math' as math;

import 'wave_math.dart';

/// Peter J. Acklam approximation — port of `inverseStandardNormalCDF.ts`.
const _a = <double>[
  -3.969683028665376e+1,
  2.209460984245205e+2,
  -2.759285104469687e+2,
  1.383577518672690e+2,
  -3.066479806614716e+1,
  2.506628277459239,
];

const _b = <double>[
  -5.447609879822406e+1,
  1.615858368580409e+2,
  -1.556989798598866e+2,
  6.680131188771972e+1,
  -1.328068155288572e+1,
];

const _c = <double>[
  -7.784894002430293e-3,
  -3.223964580411365e-1,
  -2.400758277161838,
  -2.549732539343734,
  4.374664141464968,
  2.938163982698783,
];

const _d = <double>[
  7.784695709041462e-3,
  3.224671290700398e-1,
  2.445134137142996,
  3.754408661907416,
];

const double _lowTail = 0.02425;
const double _highTail = 1 - _lowTail;
const double _minProbability = 1e-12;
const double _maxProbability = 1 - _minProbability;

double inverseStandardNormalCdf(double probability) {
  final p = clampDouble(probability, _minProbability, _maxProbability);

  if (p < _lowTail) {
    final q = math.sqrt(-2 * math.log(p));
    return (((((_c[0] * q + _c[1]) * q + _c[2]) * q + _c[3]) * q + _c[4]) * q + _c[5]) /
        ((((_d[0] * q + _d[1]) * q + _d[2]) * q + _d[3]) * q + 1);
  }
  if (p > _highTail) {
    final q = math.sqrt(-2 * math.log(1 - p));
    return -(((((_c[0] * q + _c[1]) * q + _c[2]) * q + _c[3]) * q + _c[4]) * q + _c[5]) /
        ((((_d[0] * q + _d[1]) * q + _d[2]) * q + _d[3]) * q + 1);
  }

  final q = p - 0.5;
  final r = q * q;
  return (((((_a[0] * r + _a[1]) * r + _a[2]) * r + _a[3]) * r + _a[4]) * r + _a[5]) * q /
      (((((_b[0] * r + _b[1]) * r + _b[2]) * r + _b[3]) * r + _b[4]) * r + 1);
}
