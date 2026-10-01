import '../model/container_state.dart';
import '../model/hold_constant.dart';
import '../model/particle_system.dart';
import 'gas_law_solver.dart';
import 'temperature_solver.dart';

/// Oops reason when Hold Constant cannot be satisfied.
enum HoldConstantOops {
  temperatureContainerEmpty,
  temperatureLidOpen,
  pressureContainerEmpty,
  pressureVolumeTooLarge,
  pressureVolumeTooSmall,
  maximumTemperature,
}

/// Hold Constant compensation — IdealGasLawModel.compensateForHoldConstant.
class HoldConstantSolver {
  HoldConstant holdConstant = HoldConstant.nothing;
  HoldConstantOops? lastOops;

  void reset() {
    holdConstant = HoldConstant.nothing;
    lastOops = null;
  }

  /// Returns possibly updated hold mode.
  HoldConstant compensate({
    required HoldConstant mode,
    required ContainerState container,
    required ParticleSystem particleSystem,
    required TemperatureSolver temperatureSolver,
    required double pressureKpa,
  }) {
    holdConstant = mode;
    lastOops = null;

    if (mode == HoldConstant.pressureV) {
      if (pressureKpa <= 0 || particleSystem.numberOfParticles == 0) {
        return holdConstant;
      }
      final previousWidth = container.width;
      final t = GasLawSolver.temperatureFromAverageKe(
            n: particleSystem.numberOfParticles,
            averageKe: particleSystem.averageKineticEnergy,
          ) ??
          0.0;
      var containerWidth =
          GasLawSolver.volumeFromNtp(
            n: particleSystem.numberOfParticles,
            temperatureK: t,
            pressureKpa: pressureKpa,
          ) /
          (container.height * container.depth);
      // PhET Utils.toFixedNumber(width, 5)
      containerWidth = double.parse(containerWidth.toStringAsFixed(5));

      if (containerWidth < container.widthRangeMin ||
          containerWidth > container.widthRangeMax) {
        lastOops = containerWidth > container.widthRangeMax
            ? HoldConstantOops.pressureVolumeTooLarge
            : HoldConstantOops.pressureVolumeTooSmall;
        holdConstant = HoldConstant.nothing;
        containerWidth = containerWidth.clamp(
          container.widthRangeMin,
          container.widthRangeMax,
        );
      }
      container.resizeImmediately(containerWidth);
      if (previousWidth > 0) {
        particleSystem.redistributeParticles(containerWidth / previousWidth);
      }
    } else if (mode == HoldConstant.pressureT) {
      if (pressureKpa <= 0 || particleSystem.numberOfParticles == 0) {
        return holdConstant;
      }
      final desired = GasLawSolver.temperatureFromNpv(
        n: particleSystem.numberOfParticles,
        pressureKpa: pressureKpa,
        volumePm3: container.volume,
      );
      particleSystem.setTemperature(desired);
      temperatureSolver.temperatureKelvin = desired;
    }
    return holdConstant;
  }

  HoldConstant onParticlesBecameZero(HoldConstant mode) {
    if (mode == HoldConstant.temperature ||
        mode == HoldConstant.pressureT ||
        mode == HoldConstant.pressureV) {
      lastOops = mode == HoldConstant.temperature
          ? HoldConstantOops.temperatureContainerEmpty
          : HoldConstantOops.pressureContainerEmpty;
      holdConstant = HoldConstant.nothing;
      return HoldConstant.nothing;
    }
    return mode;
  }

  HoldConstant onLidOpened(HoldConstant mode) {
    if (mode == HoldConstant.temperature) {
      lastOops = HoldConstantOops.temperatureLidOpen;
      holdConstant = HoldConstant.nothing;
      return HoldConstant.nothing;
    }
    return mode;
  }

  HoldConstant onMaxTemperature(HoldConstant mode) {
    lastOops = HoldConstantOops.maximumTemperature;
    if (mode != HoldConstant.nothing && mode != HoldConstant.volume) {
      holdConstant = HoldConstant.nothing;
      return HoldConstant.nothing;
    }
    return mode;
  }

  static bool temperatureRadioEnabled({
    required int n,
    required bool lidOpen,
  }) =>
      n != 0 && !lidOpen;

  static bool pressureRadioEnabled(double pressureKpa) => pressureKpa != 0;
}
