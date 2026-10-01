import 'dart:math' as math;

import '../fmw_constants.dart';
import '../solver/wave_packet_math.dart';

/// Lightweight Fourier component. PhET `FourierComponent.ts`
class FourierComponent {
  const FourierComponent(this.waveNumber, this.amplitude);

  /// k (rad/m) or ω (rad/ms)
  final double waveNumber;

  /// Unitless amplitude (includes Δk scaling when from WavePacket).
  final double amplitude;
}

/// Gaussian wave packet. PhET `WavePacket.ts`
class WavePacket {
  WavePacket() {
    reset();
  }

  /// Wavelength when component spacing is 2π. Always 1.
  final double L = FmwConstants.wavePacketL;

  /// Period when component spacing is 2π. Always 1.
  final double T = FmwConstants.wavePacketT;

  /// k / ω range [0, 24π]
  static final double waveNumberMin = 0;
  static final double waveNumberMax = 24 * math.pi;

  /// Valid component spacings: 0, π/4, π/2, π
  static final List<double> componentSpacingValues = [
    0,
    math.pi / 4,
    math.pi / 2,
    math.pi,
  ];

  static final double centerMin = 9 * math.pi;
  static final double centerMax = 15 * math.pi;
  static final double standardDeviationMin = math.pi;
  static final double standardDeviationMax = 4 * math.pi;

  /// Default = values[3] = π
  double componentSpacing = math.pi;

  /// Default k0 / ω0 = 12π
  double center = 12 * math.pi;

  /// Default σ = 3π
  double standardDeviation = 3 * math.pi;

  /// Conjugate σₓ = 1 / σ
  double get conjugateStandardDeviation => 1 / standardDeviation;

  set conjugateStandardDeviation(double value) {
    standardDeviation = 1 / value;
  }

  double get conjugateStandardDeviationMin => 1 / standardDeviationMax;
  double get conjugateStandardDeviationMax => 1 / standardDeviationMin;

  /// Width = 2σ
  double get width => 2 * standardDeviation;

  /// Length (λ1 or T1). Infinity when spacing is 0.
  double get length {
    if (componentSpacing == 0) return double.infinity;
    return 2 * math.pi / componentSpacing;
  }

  /// PhET `getNumberOfComponents` — Infinity when spacing is 0.
  double getNumberOfComponents() {
    if (componentSpacing == 0) return double.infinity;
    return ((waveNumberMax - waveNumberMin) / componentSpacing).floor() + 1;
  }

  bool get hasInfiniteComponents => componentSpacing == 0;

  List<FourierComponent> get components {
    if (componentSpacing == 0) return const [];
    return WavePacketMath.createComponents(
      componentSpacing: componentSpacing,
      center: center,
      standardDeviation: standardDeviation,
      waveNumberMax: waveNumberMax - waveNumberMin,
    );
  }

  double getComponentAmplitude(double waveNumber) {
    return WavePacketMath.gaussianAmplitude(
      waveNumber: waveNumber,
      center: center,
      standardDeviation: standardDeviation,
    );
  }

  void setComponentSpacing(double value) {
    assert(componentSpacingValues.contains(value));
    componentSpacing = value;
  }

  void setCenter(double value) {
    center = value.clamp(centerMin, centerMax);
  }

  void setStandardDeviation(double value) {
    standardDeviation =
        value.clamp(standardDeviationMin, standardDeviationMax);
  }

  void reset() {
    componentSpacing = componentSpacingValues[3];
    center = 12 * math.pi;
    standardDeviation = 3 * math.pi;
  }
}
