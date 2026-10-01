import '../gas_properties_constants.dart';
import '../model/container_state.dart';
import '../model/hold_constant.dart';
import '../model/particle_system.dart';
import '../model/particle_type.dart';
import '../model/random_source.dart';
import '../model/simulation_clock.dart';
import '../solver/collision_solver.dart';
import '../solver/gas_law_solver.dart';
import '../solver/hold_constant_solver.dart';
import '../solver/histogram_solver.dart';
import '../solver/pressure_solver.dart';
import '../solver/temperature_solver.dart';

/// Screen profile for Ideal Gas Law family.
enum IdealGasProfile {
  /// Ideal: Hold Constant ×5, left wall does no work (pause+redistribute).
  ideal,

  /// Explore: Hold Nothing only, left wall does work.
  explore,

  /// Energy: Hold Volume, fixed width, histograms, injection T, PP toggle.
  energy,
}

/// Ideal / Explore / Energy shared model — IdealGasLawModel.ts
///
/// Step order (Phase 1): heat → move → escape → container → collide →
/// holdConstant → temperature → pressure.
class IdealGasLawModel {
  IdealGasLawModel({
    this.profile = IdealGasProfile.ideal,
    RandomSource? random,
    bool pressureNoiseEnabled = true,
  }) : random = random ?? RandomSource() {
    final fixedW =
        profile == IdealGasProfile.energy ? GasPropertiesConstants.energyFixedWidth : null;
    container = ContainerState(
      leftWallDoesWork: profile == IdealGasProfile.explore,
      fixedWidth: fixedW,
    );
    temperatureSolver = TemperatureSolver();
    pressureSolver = PressureSolver(
      pressureNoiseEnabled: pressureNoiseEnabled,
      random: this.random,
    );
    particleSystem = ParticleSystem(
      getInitialTemperature: () => temperatureSolver.getInitialTemperature(),
      container: container,
      random: this.random,
    );
    collisionSolver = CollisionSolver(
      container: container,
      particleArrays: particleSystem.insideParticleArrays,
    );
    holdConstantSolver = HoldConstantSolver();
    if (profile == IdealGasProfile.energy) {
      holdConstantSolver.holdConstant = HoldConstant.volume;
      energySampling = EnergySamplingState();
    } else if (profile == IdealGasProfile.explore) {
      holdConstantSolver.holdConstant = HoldConstant.nothing;
    }
    clock = SimulationClock();
  }

  final IdealGasProfile profile;
  final RandomSource random;

  late final ContainerState container;
  late final ParticleSystem particleSystem;
  late final TemperatureSolver temperatureSolver;
  late final PressureSolver pressureSolver;
  late final CollisionSolver collisionSolver;
  late final HoldConstantSolver holdConstantSolver;
  late final SimulationClock clock;
  EnergySamplingState? energySampling;

  double heatCoolFactor = 0;
  ParticleType particleType = ParticleType.heavy;
  int collisionCount = 0;
  int collisionSamplePeriod =
      GasPropertiesConstants.defaultCollisionSamplePeriod;

  /// Last executed step phases (for step-order tests).
  final List<String> lastStepPhases = [];

  HoldConstant get holdConstant => holdConstantSolver.holdConstant;
  set holdConstant(HoldConstant v) => holdConstantSolver.holdConstant = v;

  int get numberOfParticles => particleSystem.numberOfParticles;
  double? get temperatureKelvin => temperatureSolver.temperatureKelvin;
  double get pressureKpa => pressureSolver.pressureKpa;
  double get displayedPressureKpa => pressureSolver.displayedPressureKpa;
  double get volume => container.volume;

  bool get particleCollisionsEnabled => particleSystem.collisionsEnabled;
  set particleCollisionsEnabled(bool v) {
    particleSystem.collisionsEnabled = v;
    collisionSolver.particleParticleCollisionsEnabled = v;
  }

  // —— Clock ——

  void play() => clock.resume();
  void pause() => clock.pause();
  bool get isPlaying => clock.isPlaying;

  void stepRealTime(double realSeconds) {
    final dt = clock.stepRealTime(realSeconds);
    if (dt > 0) _stepSystemAndUpdate(dt);
  }

  /// Step button — always advances 0.2 ps model time.
  void stepOnce() {
    final dt = clock.stepOnce();
    _stepSystemAndUpdate(dt);
  }

  /// Preferred entry for tests: advances clock then physics.
  void advance(double dtPs) {
    clock.stepModel(dtPs);
    _stepSystemAndUpdate(dtPs);
  }

  void _stepSystemAndUpdate(double dtPs) {
    lastStepPhases
      ..clear()
      ..addAll(GasPropertiesConstants.stepOrder);

    // 1 heat
    particleSystem.heatCool(heatCoolFactor);
    // 2 move
    particleSystem.step(dtPs);
    // 3 escape
    particleSystem.escapeParticles();
    // 4 container
    container.step(dtPs);
    // 5 collide
    collisionSolver.particleParticleCollisionsEnabled =
        particleSystem.collisionsEnabled;
    collisionSolver.update();
    collisionCount += collisionSolver.numberOfParticleContainerCollisions;

    // 6–8 hold / T / P
    _updateDerived(dtPs, collisionSolver.numberOfParticleContainerCollisions);

    energySampling?.step(
      dt: dtPs,
      isPlaying: clock.isPlaying,
      heavy: particleSystem.heavyParticles,
      light: particleSystem.lightParticles,
    );
  }

  void _updateDerived(double dtPressureGauge, int numberOfCollisions) {
    holdConstantSolver.holdConstant = holdConstantSolver.compensate(
      mode: holdConstantSolver.holdConstant,
      container: container,
      particleSystem: particleSystem,
      temperatureSolver: temperatureSolver,
      pressureKpa: pressureSolver.pressureKpa,
    );

    temperatureSolver.update(
      numberOfParticles: numberOfParticles,
      getAverageKineticEnergy: () => particleSystem.averageKineticEnergy,
    );

    pressureSolver.update(
      dtPressureGauge: dtPressureGauge,
      numberOfCollisions: numberOfCollisions,
      numberOfParticles: numberOfParticles,
      temperatureK: temperatureSolver.temperatureKelvin,
      volumePm3: container.volume,
      holdConstant: holdConstantSolver.holdConstant,
      blowLidOff: container.blowLidOff,
    );

    _verifyModel();
  }

  void updateWhenPaused() {
    _updateDerived(GasPropertiesConstants.pressureGaugeRefreshPs, 0);
  }

  void _verifyModel() {
    final t = temperatureSolver.temperatureKelvin;
    if (t != null && t >= GasPropertiesConstants.maxTemperatureK) {
      holdConstantSolver.holdConstant =
          holdConstantSolver.onMaxTemperature(holdConstantSolver.holdConstant);
      particleSystem.eraseAll();
      container.returnLid();
      temperatureSolver.temperatureKelvin = null;
      pressureSolver.reset();
    }
  }

  // —— Controls ——

  void setHeatCool(double factor) {
    if (!clock.isPlaying) return;
    if (holdConstant == HoldConstant.temperature ||
        holdConstant == HoldConstant.pressureT) {
      return;
    }
    heatCoolFactor = factor.clamp(-1.0, 1.0);
  }

  void setHoldConstant(HoldConstant value) {
    if (profile == IdealGasProfile.explore) {
      holdConstantSolver.holdConstant = HoldConstant.nothing;
      return;
    }
    if (profile == IdealGasProfile.energy) {
      holdConstantSolver.holdConstant = HoldConstant.volume;
      return;
    }
    if (value == HoldConstant.temperature && container.isOpen) {
      holdConstantSolver.onLidOpened(value);
      return;
    }
    if (numberOfParticles == 0 &&
        (value == HoldConstant.temperature ||
            value == HoldConstant.pressureT ||
            value == HoldConstant.pressureV)) {
      holdConstantSolver.onParticlesBecameZero(value);
      return;
    }
    holdConstantSolver.holdConstant = value;
  }

  void setNumberHeavy(int n) {
    final prev = numberOfParticles;
    particleSystem.setNumberHeavy(n);
    _onNChanged(prev);
    if (!clock.isPlaying) updateWhenPaused();
  }

  void setNumberLight(int n) {
    final prev = numberOfParticles;
    particleSystem.setNumberLight(n);
    _onNChanged(prev);
    if (!clock.isPlaying) updateWhenPaused();
  }

  void pump([int delta = 50]) {
    final prev = numberOfParticles;
    if (particleType == ParticleType.heavy) {
      particleSystem.addHeavy(delta);
    } else {
      particleSystem.addLight(delta);
    }
    _onNChanged(prev);
    if (!clock.isPlaying) updateWhenPaused();
  }

  void eraseParticles() {
    final prev = numberOfParticles;
    particleSystem.eraseAll();
    _onNChanged(prev);
    if (!clock.isPlaying) updateWhenPaused();
  }

  void _onNChanged(int previousN) {
    final n = numberOfParticles;
    pressureSolver.onNumberOfParticlesChanged(n);
    if (n == 0) {
      holdConstantSolver.holdConstant =
          holdConstantSolver.onParticlesBecameZero(holdConstantSolver.holdConstant);
    }
    if (previousN > 0 &&
        n > 0 &&
        n < previousN &&
        holdConstant == HoldConstant.temperature) {
      if (temperatureSolver.temperatureKelvin == null) {
        temperatureSolver.update(
          numberOfParticles: n,
          getAverageKineticEnergy: () => particleSystem.averageKineticEnergy,
        );
      }
      final t = temperatureSolver.temperatureKelvin;
      if (t != null) particleSystem.setTemperature(t);
    }
    if (energySampling != null && (n == 0 || !clock.isPlaying)) {
      energySampling!.clearSamples();
      energySampling!.step(
        dt: GasPropertiesConstants.energySamplePeriodPs,
        isPlaying: false,
        heavy: particleSystem.heavyParticles,
        light: particleSystem.lightParticles,
      );
    }
  }

  // —— Ideal resize (pause + redistribute) ——

  bool _wasPlayingBeforeWidthAdjust = true;
  double _widthAtAdjustStart = GasPropertiesConstants.widthDefault;

  void beginWidthAdjust() {
    if (holdConstant == HoldConstant.volume || container.isFixedWidth) return;
    if (container.leftWallDoesWork) {
      // Explore: unpause if needed
      if (!clock.isPlaying) clock.resume();
      container.userIsAdjustingWidth = true;
      return;
    }
    _wasPlayingBeforeWidthAdjust = clock.isPlaying;
    clock.pause();
    container.userIsAdjustingWidth = true;
    _widthAtAdjustStart = container.width;
  }

  void setWidthDuringAdjust(double newWidth) {
    if (holdConstant == HoldConstant.volume || container.isFixedWidth) return;
    container.setDesiredWidth(newWidth);
    if (!container.leftWallDoesWork) {
      container.resizeImmediately(newWidth);
    }
  }

  void endWidthAdjust() {
    if (!container.userIsAdjustingWidth) return;
    container.userIsAdjustingWidth = false;
    if (!container.leftWallDoesWork) {
      final scale = container.width / _widthAtAdjustStart;
      if (scale > 0 && (scale - 1).abs() > 1e-12) {
        particleSystem.redistributeParticles(scale);
      }
      clock.isPlaying = _wasPlayingBeforeWidthAdjust;
      if (!clock.isPlaying) updateWhenPaused();
    }
  }

  void setWidthImmediate(double newWidth) {
    if (holdConstant == HoldConstant.volume || container.isFixedWidth) return;
    final previous = container.width;
    container.resizeImmediately(newWidth);
    if (previous > 0 && !container.leftWallDoesWork) {
      particleSystem.redistributeParticles(container.width / previous);
    }
    if (!clock.isPlaying) updateWhenPaused();
  }

  void setInjectionTemperature(double kelvin) {
    if (profile != IdealGasProfile.energy) return;
    temperatureSolver.setInjectionTemperatureEnabled = true;
    temperatureSolver.injectionTemperature = kelvin.clamp(
      GasPropertiesConstants.injectionTemperatureMin,
      GasPropertiesConstants.injectionTemperatureMax,
    );
  }

  void setMatchContainerInjectionTemperature() {
    if (profile != IdealGasProfile.energy) return;
    temperatureSolver.setInjectionTemperatureEnabled = false;
  }

  void reset() {
    clock.reset();
    heatCoolFactor = 0;
    particleType = ParticleType.heavy;
    collisionCount = 0;
    container.reset();
    particleSystem.reset();
    temperatureSolver.reset();
    pressureSolver.reset();
    holdConstantSolver.reset();
    if (profile == IdealGasProfile.energy) {
      holdConstantSolver.holdConstant = HoldConstant.volume;
      energySampling?.reset();
    } else if (profile == IdealGasProfile.explore) {
      holdConstantSolver.holdConstant = HoldConstant.nothing;
    }
    particleCollisionsEnabled = true;
  }

  /// PV = NkT check helper for tests.
  double expectedPressureKpa() {
    final t = temperatureKelvin;
    if (t == null || numberOfParticles == 0) return 0;
    return GasLawSolver.pressureKpa(
      n: numberOfParticles,
      temperatureK: t,
      volumePm3: volume,
    );
  }
}
