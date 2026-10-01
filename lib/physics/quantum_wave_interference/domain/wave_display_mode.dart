import 'dart:math' as math;

/// PhET `WaveDisplayMode.ts`.
///
/// Photons: [amplitude] | [electricField]
/// Matter: [amplitude] | [realPart]
enum WaveDisplayMode {
  amplitude,
  electricField,
  realPart,
}

extension WaveDisplayModeQuery on WaveDisplayMode {
  bool isAllowedForPhotons() =>
      this == WaveDisplayMode.amplitude || this == WaveDisplayMode.electricField;

  bool isAllowedForMatter() =>
      this == WaveDisplayMode.amplitude || this == WaveDisplayMode.realPart;

  /// Scalar for plots (`getDisplayedWaveValue`).
  double displayedValue(double re, double im) {
    switch (this) {
      case WaveDisplayMode.amplitude:
        return math.sqrt(re * re + im * im);
      case WaveDisplayMode.electricField:
      case WaveDisplayMode.realPart:
        return re;
    }
  }

  static WaveDisplayMode defaultForSource({required bool isPhoton}) =>
      isPhoton ? WaveDisplayMode.electricField : WaveDisplayMode.realPart;
}
