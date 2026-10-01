import '../gases_intro_constants.dart';
import 'hold_constant.dart';
import 'random_source.dart';

/// Port of PressureModel + PressureGauge @ 10c7c08.
class PressureSolver {
  PressureSolver({
    this.pressureNoiseEnabled = false,
    RandomSource? random,
  }) : _random = random ?? RandomSource();

  final RandomSource _random;

  double pressure = 0; // kPa, model (no noise)
  double displayedPressure = 0; // kPa, gauge
  bool updatePressureEnabled = false;
  bool pressureNoiseEnabled;
  double _dtAccumulator = 0;

  void reset() {
    pressure = 0;
    displayedPressure = 0;
    updatePressureEnabled = false;
    _dtAccumulator = 0;
  }

  void onNumberOfParticlesChanged(int n) {
    if (n == 0) {
      pressure = 0;
      displayedPressure = 0;
      updatePressureEnabled = false;
    }
  }

  /// P = (N k T / V) * PRESSURE_CONVERSION_SCALE → kPa
  static double compute({
    required int numberOfParticles,
    required double? temperatureK,
    required double volumePm3,
  }) {
    if (numberOfParticles <= 0 || volumePm3 <= 0) return 0;
    final t = temperatureK ?? 0;
    final p = (numberOfParticles * GasesIntroConstants.boltzmann * t) / volumePm3;
    return p * GasesIntroConstants.pressureConversionScale;
  }

  double computePressureKpa({
    required int n,
    required double? temperatureK,
    required double volumePm3,
  }) =>
      compute(
        numberOfParticles: n,
        temperatureK: temperatureK,
        volumePm3: volumePm3,
      );

  void update({
    required double dtPressureGauge,
    required int numberOfCollisions,
    required int numberOfParticles,
    required double? temperatureK,
    required double volumePm3,
    required HoldConstant holdConstant,
    required void Function() blowLidOff,
  }) {
    if (!updatePressureEnabled && numberOfCollisions > 0) {
      updatePressureEnabled = true;
    }
    if (!updatePressureEnabled) return;

    pressure = compute(
      numberOfParticles: numberOfParticles,
      temperatureK: temperatureK,
      volumePm3: volumePm3,
    );

    stepGauge(
      dt: dtPressureGauge,
      holdConstant: holdConstant,
      temperatureK: temperatureK,
    );

    if (pressure > GasesIntroConstants.maxPressureKpa) {
      blowLidOff();
    }
  }

  void stepGauge({
    required double dt,
    required HoldConstant holdConstant,
    required double? temperatureK,
  }) {
    if (pressure == 0) {
      displayedPressure = 0;
    }

    _dtAccumulator += dt;
    if (_dtAccumulator < GasesIntroConstants.pressureGaugeRefreshPs) return;
    _dtAccumulator = 0;

    final constantPressure = holdConstant == HoldConstant.pressureT ||
        holdConstant == HoldConstant.pressureV;
    final noiseOn = !constantPressure && pressureNoiseEnabled;

    var noise = 0.0;
    if (noiseOn) {
      final maxP = GasesIntroConstants.maxPressureKpa;
      final amp = GasesIntroConstants.maxPressureNoiseKpa *
          (1 - (pressure / maxP).clamp(0.0, 1.0));
      final tempScale = (((temperatureK ?? 0) - 5) / 45).clamp(0.0, 1.0);
      noise = amp * tempScale * _random.nextDouble();
      if (noise < pressure) {
        noise *= _random.nextBool() ? 1 : -1;
      }
    }
    displayedPressure = pressure + noise;
  }

  double get displayedAtmospheres =>
      displayedPressure * GasesIntroConstants.atmPerKpa;
}
