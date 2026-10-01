import '../gas_properties_constants.dart';
import '../model/hold_constant.dart';
import '../model/random_source.dart';
import 'gas_law_solver.dart';

/// Pressure model + gauge sampling/noise — PressureModel.ts
class PressureSolver {
  PressureSolver({
    this.pressureNoiseEnabled = true,
    RandomSource? random,
  }) : _random = random ?? RandomSource();

  final RandomSource _random;

  /// Exact model pressure (kPa), no noise.
  double pressureKpa = 0;

  /// Gauge display (kPa), refreshed every 0.75 ps with optional noise.
  double displayedPressureKpa = 0;

  bool updatePressureEnabled = false;
  bool pressureNoiseEnabled;
  double dtAccumulator = 0;

  void reset() {
    pressureKpa = 0;
    displayedPressureKpa = 0;
    updatePressureEnabled = false;
    dtAccumulator = 0;
  }

  void onNumberOfParticlesChanged(int n) {
    if (n == 0) {
      pressureKpa = 0;
      displayedPressureKpa = 0;
      updatePressureEnabled = false;
    }
  }

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

    pressureKpa = GasLawSolver.pressureKpa(
      n: numberOfParticles,
      temperatureK: temperatureK ?? 0,
      volumePm3: volumePm3,
    );

    stepGauge(dt: dtPressureGauge, holdConstant: holdConstant, temperatureK: temperatureK);

    if (pressureKpa > GasPropertiesConstants.maxPressureKpa) {
      blowLidOff();
    }
  }

  void stepGauge({
    required double dt,
    required HoldConstant holdConstant,
    required double? temperatureK,
  }) {
    if (pressureKpa == 0) {
      displayedPressureKpa = 0;
    }

    dtAccumulator += dt;
    if (dtAccumulator < GasPropertiesConstants.pressureGaugeRefreshPs) return;
    dtAccumulator = 0;

    final constantPressure = holdConstant == HoldConstant.pressureT ||
        holdConstant == HoldConstant.pressureV;
    final noiseOn = !constantPressure && pressureNoiseEnabled;

    var noise = 0.0;
    if (noiseOn) {
      // LinearFunction(0, maxP, MAX_NOISE, MIN_NOISE)
      final maxP = GasPropertiesConstants.maxPressureKpa;
      final amp = GasPropertiesConstants.maxPressureNoiseKpa +
          (GasPropertiesConstants.minPressureNoiseKpa -
                  GasPropertiesConstants.maxPressureNoiseKpa) *
              (pressureKpa / maxP).clamp(0.0, 1.0);
      // LinearFunction(5, 50, 0, 1)
      final t = temperatureK ?? 0;
      final tempScale = ((t - 5) / 45).clamp(0.0, 1.0);
      noise = amp * tempScale * _random.nextDouble();
      if (noise < pressureKpa) {
        noise *= _random.nextBool() ? 1 : -1;
      }
    }
    displayedPressureKpa = pressureKpa + noise;
  }
}
