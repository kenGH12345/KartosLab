import 'dart:math' as math;

import '../normal_modes_constants.dart';

/// Shared frequency / amplitude helpers from One/TwoDimensionsModel.
class NormalModeMath {
  NormalModeMath._();

  static double sqrtKOverM() {
    return math.sqrt(
      NormalModesConstants.springConstant / NormalModesConstants.massValue,
    );
  }

  /// 1D mode frequency for 0-based mode index [i], [n] visible masses.
  /// `OneDimensionModel.js` modeFrequencyProperties DerivedProperty.
  static double frequency1D(int i, int n) {
    if (i >= n) return 0;
    return 2 *
        sqrtKOverM() *
        math.sin(math.pi / 2 * (i + 1) / (n + 1));
  }

  /// 2D mode frequency for 0-based [i],[j].
  static double frequency2D(int i, int j, int n) {
    if (i >= n || j >= n) return 0;
    final wi = frequency1D(i, n);
    final wj = frequency1D(j, n);
    return math.sqrt(wi * wi + wj * wj);
  }

  /// Flash/PhET 2D click amplitude cap. `TwoDimensionsModel.js` maxAmplitudes.
  static double maxAmplitude2D(int n) {
    final springLength =
        NormalModesConstants.distanceBetweenXWalls / (n + 1);
    return NormalModesConstants.twoDBaseMaxAmplitude * springLength;
  }

  /// `Utils.toFixed(value, 2)` used for frequency labels.
  static String toFixed2(double value) {
    final rounded = (value * 100).round() / 100;
    return rounded.toStringAsFixed(2);
  }

  static String frequencyLabel(int i, int n) {
    final w = frequency1D(i, n);
    final ratio = w / sqrtKOverM();
    return '${toFixed2(ratio)}\u03C9\u2080';
  }
}
