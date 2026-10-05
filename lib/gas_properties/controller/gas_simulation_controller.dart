import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../gas_properties_constants.dart';
import '../model/diffusion_model.dart';
import '../model/hold_constant.dart';
import '../model/ideal_gas_law_model.dart';
import '../model/particle_type.dart';
import '../model/random_source.dart';
import '../render/gas_render_state.dart';
import '../solver/hold_constant_solver.dart';

/// Bridges Flutter Ticker → Phase 2 IdealGasLawModel.
class GasSimulationController extends ChangeNotifier {
  GasSimulationController({
    required this.profile,
    RandomSource? random,
    bool autoTick = true,
  }) {
    model = IdealGasLawModel(
      profile: profile,
      random: random ?? RandomSource(),
      pressureNoiseEnabled: true,
    );
    _ticker = Ticker(_onTick);
    if (autoTick) _ticker.start();
  }

  final IdealGasProfile profile;
  late final IdealGasLawModel model;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  GasRenderState? _renderCache;

  bool widthVisible = false;
  bool wallVelocityVisible = false;
  bool stopwatchVisible = false;
  bool stopwatchRunning = false;
  double stopwatchPs = 0;
  bool collisionCounterVisible = false;
  bool pressureUnitsAtm = true;
  bool temperatureUnitsKelvin = true;

  HoldConstantOops? get lastOops => model.holdConstantSolver.lastOops;

  GasRenderState get renderState =>
      _renderCache ??= GasRenderState.fromModel(
        model,
        widthVisible: widthVisible,
        wallVelocityVisible: wallVelocityVisible,
        temperatureUnitsKelvin: temperatureUnitsKelvin,
        pressureUnitsAtm: pressureUnitsAtm,
      );

  void _invalidateRender() => _renderCache = null;

  @override
  void notifyListeners() {
    _invalidateRender();
    super.notifyListeners();
  }

  void _onTick(Duration elapsed) {
    final dt = _lastElapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt <= 0 || dt > 0.25) {
      notifyListeners();
      return;
    }
    model.stepRealTime(dt);
    if (stopwatchVisible && stopwatchRunning) {
      stopwatchPs = (stopwatchPs + model.clock.toModelDt(dt))
          .clamp(0.0, GasPropertiesConstants.maxStopwatchPs);
    }
    notifyListeners();
  }

  void play() {
    model.play();
    notifyListeners();
  }

  void pause() {
    model.pause();
    notifyListeners();
  }

  void togglePlayPause() {
    if (model.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void stepOnce() {
    model.stepOnce();
    notifyListeners();
  }

  void reset() {
    model.reset();
    widthVisible = false;
    wallVelocityVisible = false;
    stopwatchVisible = false;
    stopwatchRunning = false;
    stopwatchPs = 0;
    collisionCounterVisible = false;
    pressureUnitsAtm = true;
    temperatureUnitsKelvin = true;
    notifyListeners();
  }

  void setHeatCool(double factor) {
    model.setHeatCool(factor);
    notifyListeners();
  }

  void setHoldConstant(HoldConstant value) {
    model.setHoldConstant(value);
    notifyListeners();
  }

  void setNumberHeavy(int n) {
    model.setNumberHeavy(n);
    notifyListeners();
  }

  void setNumberLight(int n) {
    model.setNumberLight(n);
    notifyListeners();
  }

  void setParticleType(ParticleType t) {
    model.particleType = t;
    notifyListeners();
  }

  void pump([int delta = 50]) {
    model.pump(delta);
    notifyListeners();
  }

  void eraseParticles() {
    model.eraseParticles();
    notifyListeners();
  }

  void beginWidthAdjust() {
    model.beginWidthAdjust();
    notifyListeners();
  }

  void setWidthDuringAdjust(double widthPm) {
    model.setWidthDuringAdjust(widthPm);
    notifyListeners();
  }

  void endWidthAdjust() {
    model.endWidthAdjust();
    notifyListeners();
  }

  void setWidthImmediate(double widthPm) {
    model.setWidthImmediate(widthPm);
    notifyListeners();
  }

  void returnLid() {
    model.container.returnLid();
    notifyListeners();
  }

  void nudgeLidWidth(double dWidth) {
    final c = model.container;
    if (!c.lidIsOn) return;
    c.setLidWidth(c.lidWidth + dWidth);
    notifyListeners();
  }

  /// LidHandleDragListener — sets lid width from model X of opening left edge.
  void setLidWidthFromOpeningLeft(double openingLeftPm) {
    final c = model.container;
    if (!c.lidIsOn) return;
    if (openingLeftPm >= c.getOpeningRight()) {
      c.setLidWidth(c.maxLidWidth);
    } else {
      final openingWidth = c.getOpeningRight() - openingLeftPm;
      c.setLidWidth(c.maxLidWidth - openingWidth);
    }
    notifyListeners();
  }

  void setPressureNoiseEnabled(bool enabled) {
    model.pressureSolver.pressureNoiseEnabled = enabled;
    notifyListeners();
  }

  void setPressureUnitsAtm(bool atm) {
    pressureUnitsAtm = atm;
    notifyListeners();
  }

  void setTemperatureUnitsKelvin(bool kelvin) {
    temperatureUnitsKelvin = kelvin;
    notifyListeners();
  }

  /// Clears transient UI interaction flags after Reset / cancel.
  void clearTransientInteraction() {
    model.setHeatCool(0);
    notifyListeners();
  }

  void setParticleCollisionsEnabled(bool v) {
    model.particleCollisionsEnabled = v;
    notifyListeners();
  }

  void setInjectionTemperature(double k) {
    model.setInjectionTemperature(k);
    notifyListeners();
  }

  void matchContainerInjectionTemperature() {
    model.setMatchContainerInjectionTemperature();
    notifyListeners();
  }

  void zoomIn() {
    model.energySampling?.zoomIn();
    notifyListeners();
  }

  void zoomOut() {
    model.energySampling?.zoomOut();
    notifyListeners();
  }

  void setWidthVisible(bool v) {
    widthVisible = v;
    notifyListeners();
  }

  void setWallVelocityVisible(bool v) {
    wallVelocityVisible = v;
    notifyListeners();
  }

  void setStopwatchVisible(bool v) {
    stopwatchVisible = v;
    // PhET: hiding stopwatch stops and resets it.
    if (!v) {
      stopwatchRunning = false;
      stopwatchPs = 0;
    }
    notifyListeners();
  }

  void setStopwatchRunning(bool v) {
    stopwatchRunning = v;
    notifyListeners();
  }

  void resetStopwatch() {
    stopwatchRunning = false;
    stopwatchPs = 0;
    notifyListeners();
  }

  void setCollisionCounterVisible(bool v) {
    collisionCounterVisible = v;
    notifyListeners();
  }

  void clearOops() {
    model.holdConstantSolver.lastOops = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

/// Bridges Flutter Ticker → Phase 2 DiffusionModel.
class DiffusionSimulationController extends ChangeNotifier {
  DiffusionSimulationController({
    RandomSource? random,
    bool autoTick = true,
  }) {
    model = DiffusionModel(random: random ?? RandomSource());
    _ticker = Ticker(_onTick);
    if (autoTick) _ticker.start();
  }

  late final DiffusionModel model;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  bool centerOfMassVisible = false;
  bool flowRateVisible = false;
  bool scaleVisible = false;
  bool dataExpanded = true;

  void _onTick(Duration elapsed) {
    final dt = _lastElapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt <= 0 || dt > 0.25) {
      notifyListeners();
      return;
    }
    model.stepRealTime(dt);
    notifyListeners();
  }

  void togglePlayPause() {
    if (model.clock.isPlaying) {
      model.clock.pause();
    } else {
      model.clock.resume();
    }
    notifyListeners();
  }

  void pause() {
    model.clock.pause();
    notifyListeners();
  }

  void play() {
    model.clock.resume();
    notifyListeners();
  }

  void stepOnce() {
    model.stepOnce();
    notifyListeners();
  }

  void reset() {
    model.reset();
    centerOfMassVisible = false;
    flowRateVisible = false;
    scaleVisible = false;
    notifyListeners();
  }

  void setCenterOfMassVisible(bool v) {
    centerOfMassVisible = v;
    notifyListeners();
  }

  void setFlowRateVisible(bool v) {
    flowRateVisible = v;
    notifyListeners();
  }

  void setSlow(bool slow) {
    model.setSlow(slow);
    notifyListeners();
  }

  void setHasDivider(bool v) {
    model.setHasDivider(v);
    notifyListeners();
  }

  void setLeftCount(int n) {
    model.setLeftCount(n);
    notifyListeners();
  }

  void setRightCount(int n) {
    model.setRightCount(n);
    notifyListeners();
  }

  void setLeftMass(int m) {
    model.setLeftMass(m);
    notifyListeners();
  }

  void setRightMass(int m) {
    model.setRightMass(m);
    notifyListeners();
  }

  void setLeftRadius(int r) {
    model.setLeftRadius(r);
    notifyListeners();
  }

  void setRightRadius(int r) {
    model.setRightRadius(r);
    notifyListeners();
  }

  void setLeftTemperature(int t) {
    model.setLeftTemperature(t);
    notifyListeners();
  }

  void setRightTemperature(int t) {
    model.setRightTemperature(t);
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
