/// ChangeNotifier owning [GaoModel] + [SimulationClock].
library;

import 'package:flutter/material.dart';

import '../../../common/simulation_clock.dart';
import '../gao_constants.dart';
import '../model/gao_body.dart';
import '../model/gao_model.dart';
import '../model/gao_vec.dart';
import '../render/gao_mvt.dart';

class GaoController extends ChangeNotifier {
  GaoController({required bool isModelScreen})
      : model = GaoModel(isModelScreen: isModelScreen),
        clock = SimulationClock(fps: GaoConstants.clockFrameRate) {
    clock.onTick = _onTick;
  }

  final GaoModel model;
  final SimulationClock clock;

  GaoBody? _draggingBody;
  GaoBody? _draggingVelocityBody;
  GaoMvt? lastMvt;
  Size? lastCanvasSize;

  void attach(TickerProvider vsync) => clock.attach(vsync);

  void _onTick(double dt, double _) {
    model.step(dt);
    notifyListeners();
  }

  void play() {
    model.setPlaying(true);
    clock.play();
    notifyListeners();
  }

  void pause() {
    model.setPlaying(false);
    clock.pause();
    notifyListeners();
  }

  void togglePlay() => model.isPlaying ? pause() : play();

  void stepForward() {
    if (model.isPlaying) return;
    model.stepWhilePaused();
    notifyListeners();
  }

  void rewind() {
    model.rewind();
    notifyListeners();
  }

  void resetAll() {
    pause();
    model.resetAll();
    clock.reset();
    notifyListeners();
  }

  void resetActiveScene() {
    model.resetActiveScene();
    notifyListeners();
  }

  void returnObjects() {
    pause();
    model.rewind();
    notifyListeners();
  }

  void selectScene(int index) {
    model.selectScene(index);
    notifyListeners();
  }

  void setTimeSpeed(GaoTimeSpeed speed) {
    model.setTimeSpeed(speed);
    notifyListeners();
  }

  void setGravityEnabled(bool enabled) {
    model.setGravityEnabled(enabled);
    notifyListeners();
  }

  void setShowGravityForce(bool v) {
    model.showGravityForce = v;
    notifyListeners();
  }

  void setShowVelocity(bool v) {
    model.showVelocity = v;
    notifyListeners();
  }

  void setShowPath(bool v) {
    model.setShowPath(v);
    notifyListeners();
  }

  void setShowGrid(bool v) {
    model.showGrid = v;
    notifyListeners();
  }

  void setShowMass(bool v) {
    model.showMass = v;
    notifyListeners();
  }

  void setShowMeasuringTape(bool v) {
    model.showMeasuringTapeFlag = v;
    notifyListeners();
  }

  void setZoomLevel(double level) {
    model.scene.zoomLevel =
        level.clamp(GaoConstants.zoomMin, GaoConstants.zoomMax);
    notifyListeners();
  }

  void setBodyMassRatio(GaoBody body, double ratio) {
    body.mass = body.tickMass * ratio.clamp(0.5, 2.0);
    body.clearPath();
    model.scene.engine.updateForceVectors();
    if (!model.isPlaying) model.scene.saveRewindPoint();
    notifyListeners();
  }

  void clearSimulationTime() {
    model.scene.clearSimulationTime();
    notifyListeners();
  }

  /// Public notify for overlay widgets (measuring tape drag).
  void touch() => notifyListeners();

  /// Earth Days or Earth Minutes display value.
  double get displayedTime {
    final t = model.scene.engine.simulationTime;
    if (model.scene.timeInDays) {
      return t / GaoConstants.secondsPerDay;
    }
    return t / 60.0;
  }

  bool get bodiesAreReturnable {
    for (final b in model.scene.bodies) {
      if (b.isCollided) return true;
      final mvt = lastMvt;
      final canvas = lastCanvasSize;
      if (mvt == null || canvas == null) continue;
      final p = mvt.modelToView(b.position);
      const margin = 40.0;
      if (p.dx < -margin ||
          p.dy < -margin ||
          p.dx > canvas.width + margin ||
          p.dy > canvas.height + margin) {
        return true;
      }
    }
    return false;
  }

  void updateViewContext({required GaoMvt mvt, required Size canvasSize}) {
    lastMvt = mvt;
    lastCanvasSize = canvasSize;
  }

  // ── Body drag ────────────────────────────────────────────────────────────

  void dragBodyStart(GaoBody body) {
    if (!body.isMovable) return;
    _draggingBody = body;
    body.userControlled = true;
    body.clearPath();
    notifyListeners();
  }

  void dragBody(GaoBody body, GaoVec modelPos) {
    if (!identical(_draggingBody, body)) return;
    body.position.setFrom(modelPos);
    body.clearPath();
    model.scene.engine.updateForceVectors();
    notifyListeners();
  }

  void dragBodyEnd(GaoBody body) {
    if (!identical(_draggingBody, body)) return;
    body.userControlled = false;
    _draggingBody = null;
    model.scene.engine.updateForceVectors();
    if (!model.isPlaying) model.scene.saveRewindPoint();
    notifyListeners();
  }

  // ── Velocity tip drag (DraggableVectorNode) ──────────────────────────────

  void dragVelocityStart(GaoBody body) {
    _draggingVelocityBody = body;
    notifyListeners();
  }

  /// Set velocity so tip in model space equals [tipModel]
  /// (`v = (tip - position) / velocityVectorScale`).
  void dragVelocity(GaoBody body, GaoVec tipModel) {
    final scale = model.scene.velocityVectorScale;
    if (scale == 0) return;
    body.velocity.setXY(
      (tipModel.x - body.position.x) / scale,
      (tipModel.y - body.position.y) / scale,
    );
    body.clearPath();
    notifyListeners();
  }

  /// Apply view-space tip delta: `Δv = Δmodel / scale`.
  void dragVelocityByDelta(GaoBody body, GaoVec modelDelta) {
    final scale = model.scene.velocityVectorScale;
    if (scale == 0) return;
    body.velocity.addScaled(modelDelta, 1 / scale);
    body.clearPath();
    notifyListeners();
  }

  void dragVelocityEnd(GaoBody body) {
    if (!identical(_draggingVelocityBody, body)) return;
    _draggingVelocityBody = null;
    if (!model.isPlaying) model.scene.saveRewindPoint();
    notifyListeners();
  }

  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }
}
