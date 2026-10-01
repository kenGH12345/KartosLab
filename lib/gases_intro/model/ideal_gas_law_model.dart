import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../gases_intro_constants.dart';
import '../render/render_data.dart';
import 'collision_solver.dart';
import 'container_model.dart';
import 'hold_constant.dart';
import 'particle.dart';
import 'particle_system.dart';
import 'pressure_solver.dart';
import 'random_source.dart';
import 'temperature_solver.dart';

/// Ideal Gas Law model — PV = NkT.
/// Port of IdealGasLawModel + BaseModel @ 10c7c08.
///
/// [hasHoldConstantControls] is UI-only (Intro=false, Laws=true).
class IdealGasLawModel extends ChangeNotifier {
  IdealGasLawModel({
    this.hasHoldConstantControls = true,
    this.pressureNoiseEnabled = false,
    RandomSource? random,
    bool autoTick = true,
  }) : random = random ?? RandomSource() {
    container = ContainerModel();
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
    _ticker = Ticker(_onTick);
    if (autoTick) _ticker.start();
  }

  final RandomSource random;
  final bool hasHoldConstantControls;

  late final ContainerModel container;
  late final ParticleSystem particleSystem;
  late final TemperatureSolver temperatureSolver;
  late final PressureSolver pressureSolver;
  late final CollisionSolver collisionSolver;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  bool isPlaying = true;
  double heatCoolFactor = 0;
  HoldConstant holdConstant = HoldConstant.nothing;
  bool pressureNoiseEnabled;

  bool widthVisible = false;
  bool stopwatchVisible = false;
  bool collisionCounterVisible = false;
  ParticleKind particleType = ParticleKind.heavy;

  double stopwatchPs = 0;
  int collisionCount = 0;

  bool _wasPlayingBeforeWidthAdjust = true;
  double _widthAtAdjustStart = GasesIntroConstants.widthDefault;

  int get numberOfParticles => particleSystem.numberOfParticles;
  double? get temperature => temperatureSolver.temperature;
  double? get temperatureK => temperature;
  double get pressure => pressureSolver.pressure;
  double get pressureKpa => pressure;
  double get displayedPressure => pressureSolver.displayedPressure;
  double get volume => container.volume;
  double get width => container.width;

  ParticleKind get pumpParticleType => particleType;
  set pumpParticleType(ParticleKind k) => particleType = k;

  RenderData get renderData {
    final c = container;
    return RenderData(
      containerLeft: c.left,
      containerRight: c.right,
      containerBottom: c.bottom,
      containerTop: c.top,
      wallThickness: c.wallThickness,
      lidIsOn: c.lidIsOn,
      lidWidth: c.lidWidth,
      isOpen: c.isOpen,
      openingLeft: c.getOpeningLeft(),
      openingRight: c.getOpeningRight(),
      particles: [
        for (final p in particleSystem.heavyParticles)
          ParticleRender(
            x: p.x,
            y: p.y,
            radius: p.radius,
            kind: ParticleKind.heavy,
            color: const Color(GasesIntroConstants.heavyParticleColor),
            highlight: const Color(GasesIntroConstants.heavyParticleHighlight),
          ),
        for (final p in particleSystem.lightParticles)
          ParticleRender(
            x: p.x,
            y: p.y,
            radius: p.radius,
            kind: ParticleKind.light,
            color: const Color(GasesIntroConstants.lightParticleColor),
            highlight: const Color(GasesIntroConstants.lightParticleHighlight),
          ),
      ],
      temperatureK: temperature,
      pressureKpa: pressure,
      displayedPressureKpa: displayedPressure,
      volumePm3: volume,
      numberOfHeavy: particleSystem.numberOfHeavy,
      numberOfLight: particleSystem.numberOfLight,
      isPlaying: isPlaying,
      heatCoolFactor: heatCoolFactor,
      holdConstant: holdConstant,
      widthVisible: widthVisible,
      widthPm: c.width,
    );
  }

  void _onTick(Duration elapsed) {
    final dt = _lastElapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt <= 0 || dt > 0.25) return;
    tick(dt);
  }

  void tick(double dtSeconds) {
    if (isPlaying) stepRealTime(dtSeconds);
    notifyListeners();
  }

  void stepRealTime(double dtSeconds) {
    stepModelTime(dtSeconds * GasesIntroConstants.normalPsPerSecond);
  }

  /// Step button — 0.2 ps even when paused.
  void stepOnce() {
    stepModelTime(GasesIntroConstants.modelTimeStepPs);
    notifyListeners();
  }

  void stepModelTime(double dtPs) {
    assert(dtPs > 0);
    stopwatchPs = (stopwatchPs + dtPs).clamp(0, 999.99);
    stepSystem(dtPs);
    updateModel(dtPs, collisionSolver.numberOfParticleContainerCollisions);
  }

  void stepSystem(double dt) {
    particleSystem.heatCool(heatCoolFactor);
    particleSystem.step(dt);
    particleSystem.escapeParticles();
    container.step(dt);
    collisionSolver.update();
    collisionCount += collisionSolver.numberOfParticleContainerCollisions;
  }

  void updateModel(double dtPressureGauge, int numberOfCollisions) {
    compensateForHoldConstant();
    temperatureSolver.update(
      numberOfParticles: numberOfParticles,
      getAverageKineticEnergy: () => particleSystem.averageKineticEnergy,
    );
    pressureSolver.pressureNoiseEnabled = pressureNoiseEnabled;
    pressureSolver.update(
      dtPressureGauge: dtPressureGauge,
      numberOfCollisions: numberOfCollisions,
      numberOfParticles: numberOfParticles,
      temperatureK: temperatureSolver.temperature,
      volumePm3: container.volume,
      holdConstant: holdConstant,
      blowLidOff: container.blowLidOff,
    );
    verifyModel();
  }

  void updateWhenPaused() {
    updateModel(GasesIntroConstants.pressureGaugeRefreshPs, 0);
  }

  void compensateForHoldConstant() {
    if (holdConstant == HoldConstant.pressureV) {
      final previousWidth = container.width;
      var containerWidth =
          computeIdealVolume() / (container.height * container.depth);
      containerWidth = double.parse(containerWidth.toStringAsFixed(5));
      if (containerWidth < GasesIntroConstants.widthMin ||
          containerWidth > GasesIntroConstants.widthMax) {
        holdConstant = HoldConstant.nothing;
        containerWidth = containerWidth.clamp(
          GasesIntroConstants.widthMin,
          GasesIntroConstants.widthMax,
        );
      }
      container.resizeImmediately(containerWidth);
      particleSystem.redistributeParticles(containerWidth / previousWidth);
    } else if (holdConstant == HoldConstant.pressureT) {
      final desired = computeIdealTemperature();
      particleSystem.setTemperature(desired);
      temperatureSolver.temperature = desired;
    }
  }

  double computeIdealVolume() {
    final n = numberOfParticles;
    final t = TemperatureSolver.compute(
          numberOfParticles: n,
          getAverageKineticEnergy: () => particleSystem.averageKineticEnergy,
        ) ??
        0;
    final p =
        pressureSolver.pressure / GasesIntroConstants.pressureConversionScale;
    return (n * GasesIntroConstants.boltzmann * t) / p;
  }

  double computeIdealTemperature() {
    final p =
        pressureSolver.pressure / GasesIntroConstants.pressureConversionScale;
    return (p * container.volume) /
        (numberOfParticles * GasesIntroConstants.boltzmann);
  }

  void verifyModel() {
    final t = temperatureSolver.temperature;
    if (t != null && t >= GasesIntroConstants.maxTemperatureK) {
      if (holdConstant != HoldConstant.nothing &&
          holdConstant != HoldConstant.volume) {
        holdConstant = HoldConstant.nothing;
      }
      particleSystem.eraseAll();
      container.lidIsOn = true;
      container.lidWidth = container.maxLidWidth;
      temperatureSolver.temperature = null;
      pressureSolver.pressure = 0;
      pressureSolver.displayedPressure = 0;
      pressureSolver.updatePressureEnabled = false;
    }
  }

  void play() {
    isPlaying = true;
    notifyListeners();
  }

  void pause() {
    isPlaying = false;
    notifyListeners();
  }

  void setPlaying(bool v) {
    isPlaying = v;
    notifyListeners();
  }

  void setHeatCool(double factor) {
    if (!isPlaying) return;
    if (holdConstant == HoldConstant.temperature ||
        holdConstant == HoldConstant.pressureT) {
      return;
    }
    heatCoolFactor = factor.clamp(-1.0, 1.0);
    notifyListeners();
  }

  void setCollisionCounterVisible(bool v) {
    collisionCounterVisible = v;
    notifyListeners();
  }

  void setHoldConstant(HoldConstant value) {
    // hasHoldConstantControls is UI-only (IdealScreen); model always accepts hold.
    if (value == HoldConstant.temperature && container.isOpen) {
      holdConstant = HoldConstant.nothing;
    } else if (numberOfParticles == 0 &&
        (value == HoldConstant.temperature ||
            value == HoldConstant.pressureT ||
            value == HoldConstant.pressureV)) {
      holdConstant = HoldConstant.nothing;
    } else {
      holdConstant = value;
    }
    notifyListeners();
  }

  void setParticleType(ParticleKind kind) {
    particleType = kind;
    notifyListeners();
  }

  void pump([int? delta]) {
    final d = delta ?? GasesIntroConstants.pumpParticlesPerAction;
    final prev = numberOfParticles;
    if (particleType == ParticleKind.heavy) {
      particleSystem.addHeavy(d);
    } else {
      particleSystem.addLight(d);
    }
    _onNChanged(prev);
    if (!isPlaying) updateWhenPaused();
    notifyListeners();
  }

  void setNumberHeavy(int n) {
    final prev = numberOfParticles;
    particleSystem.setNumberHeavy(n);
    _onNChanged(prev);
    if (!isPlaying) updateWhenPaused();
    notifyListeners();
  }

  void setNumberLight(int n) {
    final prev = numberOfParticles;
    particleSystem.setNumberLight(n);
    _onNChanged(prev);
    if (!isPlaying) updateWhenPaused();
    notifyListeners();
  }

  void eraseParticles() {
    final prev = numberOfParticles;
    particleSystem.eraseAll();
    _onNChanged(prev);
    if (!isPlaying) updateWhenPaused();
    notifyListeners();
  }

  void _onNChanged(int previousN) {
    final n = numberOfParticles;
    pressureSolver.onNumberOfParticlesChanged(n);
    if (n == 0 &&
        (holdConstant == HoldConstant.temperature ||
            holdConstant == HoldConstant.pressureT ||
            holdConstant == HoldConstant.pressureV)) {
      holdConstant = HoldConstant.nothing;
    }
    if (previousN > 0 &&
        n > 0 &&
        n < previousN &&
        holdConstant == HoldConstant.temperature) {
      if (temperatureSolver.temperature == null) {
        temperatureSolver.update(
          numberOfParticles: n,
          getAverageKineticEnergy: () => particleSystem.averageKineticEnergy,
        );
      }
      final t = temperatureSolver.temperature;
      if (t != null) particleSystem.setTemperature(t);
    }
  }

  void beginWidthAdjust() {
    if (holdConstant == HoldConstant.volume) return;
    _wasPlayingBeforeWidthAdjust = isPlaying;
    isPlaying = false;
    container.userIsAdjustingWidth = true;
    _widthAtAdjustStart = container.width;
    notifyListeners();
  }

  void setWidth(double newWidth) {
    if (holdConstant == HoldConstant.volume) return;
    final clamped = newWidth
        .clamp(GasesIntroConstants.widthMin, GasesIntroConstants.widthMax)
        .toDouble();
    final previous = container.width;
    if ((clamped - previous).abs() < 1e-9) return;

    if (!container.userIsAdjustingWidth) {
      container.resizeImmediately(clamped);
      particleSystem.redistributeParticles(clamped / previous);
      if (!isPlaying) updateWhenPaused();
    } else {
      container.resizeImmediately(clamped);
    }
    notifyListeners();
  }

  /// Discrete width change (no Ideal drag pause lifecycle).
  void setWidthImmediate(double newWidth) => setWidth(newWidth);

  void endWidthAdjust() {
    if (!container.userIsAdjustingWidth) return;
    container.userIsAdjustingWidth = false;
    final scale = container.width / _widthAtAdjustStart;
    if (scale > 0 && (scale - 1).abs() > 1e-12) {
      particleSystem.redistributeParticles(scale);
    }
    isPlaying = _wasPlayingBeforeWidthAdjust;
    if (!isPlaying) updateWhenPaused();
    notifyListeners();
  }

  void setWidthVisible(bool v) {
    widthVisible = v;
    notifyListeners();
  }

  void setStopwatchVisible(bool v) {
    stopwatchVisible = v;
    notifyListeners();
  }

  void returnLid() {
    container.returnLid();
    notifyListeners();
  }

  void reset() {
    isPlaying = true;
    heatCoolFactor = 0;
    holdConstant = HoldConstant.nothing;
    particleType = ParticleKind.heavy;
    widthVisible = false;
    stopwatchVisible = false;
    collisionCounterVisible = false;
    stopwatchPs = 0;
    collisionCount = 0;
    container.reset();
    particleSystem.reset();
    temperatureSolver.reset();
    pressureSolver.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
