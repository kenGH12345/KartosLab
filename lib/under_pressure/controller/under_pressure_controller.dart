import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/under_pressure/model/under_pressure_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_units.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';

/// Screen controller — owns Model + clock; View only notifies / reads.
class UnderPressureController extends ChangeNotifier {
  UnderPressureController({
    UnderPressureModel? model,
    SimulationClock? clock,
    UpMvt? mvt,
  })  : model = model ?? UnderPressureModel(),
        clock = clock ?? SimulationClock(fps: 60),
        mvt = mvt ?? const UpMvt() {
    this.clock.onTick = _onTick;
    // Ensure fluid color / sensor values reflect defaults.
    this.model.fluidColorModel.markDensityChanged();
    this.model.step(0);
    refreshSensors();
  }

  final UnderPressureModel model;
  final SimulationClock clock;
  final UpMvt mvt;

  /// Sensor panel layout rect in view coordinates (for dock snap).
  /// Source: 100×130 yellow panel left of control panel.
  static const double sensorPanelWidth = 100;
  static const double sensorPanelHeight = 130;

  bool _disposed = false;
  int _listenerGeneration = 0;

  int get listenerGeneration => _listenerGeneration;

  double get tipDeltaYModel => UpBarometerMetrics.tipDeltaYModel(mvt);

  void _onTick(double dt, double total) {
    if (_disposed) return;
    model.step(dt);
    refreshSensors();
    notifyListeners();
  }

  void attachTicker(TickerProvider vsync) {
    clock.attach(vsync);
    if (!clock.isRunning) {
      clock.play();
    }
  }

  /// Update all barometer readings using **tip** coordinates.
  void refreshSensors() {
    model.refreshSensorValues(tipDeltaY: tipDeltaYModel);
  }

  /// Drag sensor: [centerModel] is gauge center; measurement uses tip.
  void setSensorCenter(int index, Offset centerModel) {
    final s = model.barometers[index];
    s.position = centerModel;
    if (s.isDocked) {
      s.value = null;
    } else {
      final tip = UpBarometerMetrics.tipFromCenter(centerModel, mvt);
      s.value = model.getPressureAtCoords(tip.dx, tip.dy);
    }
    notifyListeners();
  }

  /// Release over sensor panel → dock (source snap-back).
  void endSensorDrag(int index, {required bool overSensorPanel}) {
    final s = model.barometers[index];
    if (overSensorPanel) {
      s.reset();
    } else {
      final tip = UpBarometerMetrics.tipFromCenter(s.position, mvt);
      s.value = model.getPressureAtCoords(tip.dx, tip.dy);
    }
    notifyListeners();
  }

  void setDensity(double value) {
    model.fluidDensity =
        value.clamp(model.fluidDensityMin, model.fluidDensityMax);
    model.fluidColorModel.step();
    refreshSensors();
    notifyListeners();
  }

  void setGravity(double value) {
    model.gravity = value.clamp(model.gravityMin, model.gravityMax);
    refreshSensors();
    notifyListeners();
  }

  void setAtmosphere(bool on) {
    model.isAtmosphere = on;
    refreshSensors();
    notifyListeners();
  }

  void setUnits(MeasureUnits units) {
    model.measureUnits = units;
    notifyListeners();
  }

  void setRulerVisible(bool v) {
    model.isRulerVisible = v;
    notifyListeners();
  }

  void setGridVisible(bool v) {
    model.isGridVisible = v;
    notifyListeners();
  }

  void setRulerPosition(Offset viewPos) {
    model.rulerPosition = viewPos;
    notifyListeners();
  }

  void setScene(UnderPressureScene scene) {
    model.setScene(scene);
    refreshSensors();
    notifyListeners();
  }

  void setDensityExpanded(bool v) {
    model.fluidDensityControlExpanded = v;
    notifyListeners();
  }

  void setGravityExpanded(bool v) {
    model.gravityControlExpanded = v;
    notifyListeners();
  }

  void resetAll() {
    model.reset();
    model.fluidColorModel.markDensityChanged();
    model.step(0);
    refreshSensors();
    clock.reset();
    notifyListeners();
  }

  void setInputFlow(double rate) {
    if (model.currentScene != UnderPressureScene.square &&
        model.currentScene != UnderPressureScene.trapezoid &&
        model.currentScene != UnderPressureScene.mystery) {
      return;
    }
    final pool = model.currentScene == UnderPressureScene.trapezoid
        ? model.trapezoid
        : model.currentScene == UnderPressureScene.mystery
            ? model.mystery
            : model.square;
    pool.inputFaucet.flowRate = rate.clamp(0, pool.inputFaucet.maxFlowRate);
    notifyListeners();
  }

  void setOutputFlow(double rate) {
    if (model.currentScene != UnderPressureScene.square &&
        model.currentScene != UnderPressureScene.trapezoid &&
        model.currentScene != UnderPressureScene.mystery) {
      return;
    }
    final pool = model.currentScene == UnderPressureScene.trapezoid
        ? model.trapezoid
        : model.currentScene == UnderPressureScene.mystery
            ? model.mystery
            : model.square;
    pool.outputFaucet.flowRate = rate.clamp(0, pool.outputFaucet.maxFlowRate);
    notifyListeners();
  }

  void setMysteryChoice(String choice) {
    model.setMysteryChoice(choice);
    refreshSensors();
    notifyListeners();
  }

  void setMysteryFluidIndex(int index) {
    model.mystery.setCustomFluidDensityIndex(index);
    refreshSensors();
    notifyListeners();
  }

  void setMysteryGravityIndex(int index) {
    model.mystery.setCustomGravityIndex(index);
    refreshSensors();
    notifyListeners();
  }

  /// Mass drag — [centerModel] is mass center (source MassNode).
  void beginMassDrag(int index) {
    model.chamber.masses[index].setDragging(true);
    notifyListeners();
  }

  void updateMassCenter(int index, Offset centerModel) {
    final mass = model.chamber.masses[index];
    if (!mass.isDragging) return;
    mass.position = centerModel;
    notifyListeners();
  }

  void endMassDrag(int index) {
    final mass = model.chamber.masses[index];
    mass.setDragging(false);
    refreshSensors();
    notifyListeners();
  }

  /// Source drop-hit probe for tests / QA (MassModel.isInTargetDroppedArea).
  bool massWouldHitDropTarget(int index) =>
      model.chamber.masses[index].isInTargetDroppedArea();

  @override
  void notifyListeners() {
    _listenerGeneration++;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    clock.pause();
    clock.dispose();
    super.dispose();
  }
}
