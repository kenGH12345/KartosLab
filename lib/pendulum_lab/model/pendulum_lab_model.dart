import 'package:flutter/foundation.dart';

import '../pl_constants.dart';
import 'body.dart';
import 'lab_stopwatch.dart';
import 'pendulum.dart';
import 'period_timer.dart';
import 'ruler.dart';

/// Intro-screen model. Source: `PendulumLabModel.js`.
class PendulumLabModel extends ChangeNotifier {
  PendulumLabModel({
    this.hasPeriodTimer = false,
    this.rulerInitiallyVisible = true,
  }) {
    pendula = [
      Pendulum(
        index: 0,
        mass: PlConstants.pendulum0Mass,
        length: PlConstants.pendulum0Length,
        hasPeriodTimer: hasPeriodTimer,
        gravity: () => gravity,
        friction: () => friction,
      ),
      Pendulum(
        index: 1,
        mass: PlConstants.pendulum1Mass,
        length: PlConstants.pendulum1Length,
        hasPeriodTimer: hasPeriodTimer,
        gravity: () => gravity,
        friction: () => friction,
      ),
    ];
    for (final p in pendula) {
      p.onChanged = notifyListeners;
      p.stepListeners.add((_) => periodTimer?.syncFromTrace());
    }
    ruler = PlRuler(initiallyVisible: rulerInitiallyVisible);
    _applyNumberOfPendula();
  }

  final bool hasPeriodTimer;
  final bool rulerInitiallyVisible;

  late final List<Pendulum> pendula;
  late final PlRuler ruler;
  final PlStopwatch stopwatch = PlStopwatch();

  /// Lab only.
  PeriodTimer? periodTimer;

  PlBody body = PlBody.earth;
  double gravity = PlConstants.earthGravity;
  double customGravity = PlConstants.earthGravity;
  double timeSpeed = PlConstants.normalTimeSpeed;
  int numberOfPendula = 1;
  bool isPlaying = true;
  double friction = 0;
  bool isPeriodTraceVisible = false;
  double energyZoom = 1;

  void setBody(PlBody next) {
    final old = body;
    body = next;
    if (next != PlBody.custom) {
      gravity = next.gravity!;
    } else {
      if (old == PlBody.planetX) {
        gravity = customGravity;
      } else {
        customGravity = gravity;
      }
    }
    _onGravityChanged();
  }

  void setGravity(double value) {
    gravity = value.clamp(PlConstants.gravityMin, PlConstants.gravityMax);
    final match = PlBodyData.matchingGravity(gravity);
    if (match == null) {
      body = PlBody.custom;
    }
    if (body == PlBody.custom) {
      customGravity = gravity;
    }
    _onGravityChanged();
  }

  void _onGravityChanged() {
    for (final p in pendula) {
      p.notifyGravityChanged();
    }
    periodTimer?.onPendulumParameterChanged(periodTimer!.activePendulum);
    notifyListeners();
  }

  void setRulerVisible(bool value) {
    ruler.isVisible = value;
    notifyListeners();
  }

  void setStopwatchVisible(bool value) {
    stopwatch.isVisible = value;
    notifyListeners();
  }

  void clearThermal(Pendulum pendulum) {
    pendulum.resetThermalEnergy();
    notifyListeners();
  }

  void setLength(int index, double value) {
    pendula[index].length =
        value.clamp(PlConstants.lengthMin, PlConstants.lengthMax);
    periodTimer?.onPendulumParameterChanged(pendula[index]);
    notifyListeners();
  }

  void setMass(int index, double value) {
    pendula[index].mass =
        value.clamp(PlConstants.massMin, PlConstants.massMax);
    notifyListeners();
  }

  void setFriction(double value) {
    friction = value.clamp(0, PlConstants.frictionMax);
    notifyListeners();
  }

  void setTimeSpeed(double value) {
    timeSpeed = value;
    notifyListeners();
  }

  void setNumberOfPendula(int value) {
    numberOfPendula = value.clamp(1, 2);
    _applyNumberOfPendula();
    notifyListeners();
  }

  void _applyNumberOfPendula() {
    for (var i = 0; i < pendula.length; i++) {
      pendula[i].isVisible = numberOfPendula > i;
    }
    if (!hasPeriodTimer) {
      _syncPeriodTraceVisibility();
    }
  }

  void setPeriodTraceVisible(bool value) {
    isPeriodTraceVisible = value;
    if (hasPeriodTimer) {
      periodTimer?.setVisible(value);
    } else {
      _syncPeriodTraceVisibility();
    }
    notifyListeners();
  }

  void _syncPeriodTraceVisibility() {
    for (final p in pendula) {
      p.periodTrace.isVisible = isPeriodTraceVisible && p.isVisible;
    }
  }

  void setPlaying(bool value) {
    isPlaying = value;
    notifyListeners();
  }

  /// Joist `step(dt)`.
  void step(double dt) {
    if (isPlaying) {
      modelStep(
        (dt > PlConstants.maxWallDt ? PlConstants.maxWallDt : dt) *
            (timeSpeed * PlConstants.periodTimerOffsetFactor),
      );
    }
  }

  void modelStep(double dt) {
    stopwatch.step(dt);
    // A running stopwatch advances its readout every step.
    var changed = stopwatch.isRunning;
    for (var i = 0; i < numberOfPendula; i++) {
      final pendulum = pendula[i];
      if (!pendulum.isStationary()) {
        final damp = pendulum.angle.abs() < PlConstants.dampThreshold &&
            pendulum.angularAcceleration.abs() < PlConstants.dampThreshold &&
            pendulum.angularVelocity.abs() < PlConstants.dampThreshold;
        if (damp) {
          pendulum.angle = 0;
          pendulum.angularVelocity = 0;
        }
        pendulum.step(dt);
        changed = true;
      }
    }
    // Skip the notify when nothing moved: otherwise an idle-but-playing sim
    // triggers a full-screen rebuild on every clock tick (60/s), which
    // competes with pointer-event frames during bob drags (jank).
    if (changed) {
      notifyListeners();
    }
  }

  void stepManual() {
    modelStep(PlConstants.manualStepDt);
  }

  void returnPendula() {
    for (final p in pendula) {
      p.resetThermalEnergy();
      p.resetMotion();
    }
    periodTimer?.stop();
    notifyListeners();
  }

  void reset() {
    body = PlBody.earth;
    gravity = PlConstants.earthGravity;
    customGravity = PlConstants.earthGravity;
    timeSpeed = PlConstants.normalTimeSpeed;
    numberOfPendula = 1;
    isPlaying = true;
    friction = 0;
    isPeriodTraceVisible = false;
    energyZoom = 1;
    ruler.reset();
    stopwatch.reset();
    for (final p in pendula) {
      p.reset();
    }
    _applyNumberOfPendula();
    notifyListeners();
  }
}
