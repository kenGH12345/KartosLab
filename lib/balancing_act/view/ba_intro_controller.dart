import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/balancing_act/ba_mvt.dart';
import 'package:kratos/balancing_act/model/ba_enums.dart';
import 'package:kratos/balancing_act/model/ba_intro_model.dart';
import 'package:kratos/balancing_act/model/ba_mass.dart';
import 'package:kratos/balancing_act/model/ba_vector2.dart';
import 'package:kratos/balancing_act/model/balance_lab_model.dart';
import 'package:kratos/common/simulation_clock.dart';

/// Clock + Intro model bridge. Physics driven only by [BAIntroModel.step].
class BaIntroController extends ChangeNotifier {
  BaIntroController({
    BAIntroModel? model,
    BalanceViewProperties? viewProperties,
  })  : model = model ?? BAIntroModel(),
        viewProperties = viewProperties ?? BalanceViewProperties(),
        mvt = BaModelViewTransform(),
        clock = SimulationClock(fps: 60) {
    clock.onTick = _onTick;
  }

  final BAIntroModel model;
  final BalanceViewProperties viewProperties;
  final BaModelViewTransform mvt;
  final SimulationClock clock;

  BaMass? _dragging;
  BaVector2? _dragOffset;

  BaMass? get dragging => _dragging;

  void attach(TickerProvider vsync) {
    // Re-bind ticker (leave/re-enter). SimulationClock.attach disposes the old
    // ticker; force a clean play so _isRunning cannot strand a dead ticker.
    if (clock.isRunning) {
      clock.pause();
    }
    clock.attach(vsync);
    clock.play();
  }

  void _onTick(double dt, double total) {
    model.step(dt);
    notifyListeners();
  }

  void beginDrag(BaMass mass, Offset viewPos) {
    final modelPos = mvt.viewToModel(viewPos);
    _dragging = mass;
    _dragOffset = mass.position.minus(modelPos);
    model.beginDrag(mass);
    notifyListeners();
  }

  void updateDrag(Offset viewPos) {
    final mass = _dragging;
    final offset = _dragOffset;
    if (mass == null || offset == null) return;
    final modelPos = mvt.viewToModel(viewPos);
    model.dragMassTo(mass, modelPos.plus(offset));
    notifyListeners();
  }

  void endDrag() {
    final mass = _dragging;
    if (mass == null) return;
    model.endDrag(mass);
    _dragging = null;
    _dragOffset = null;
    notifyListeners();
  }

  void resetAll() {
    _dragging = null;
    _dragOffset = null;
    model.reset();
    viewProperties.reset();
    notifyListeners();
  }

  void setMassLabelsVisible(bool v) {
    viewProperties.massLabelsVisible = v;
    notifyListeners();
  }

  void setForcesVisible(bool v) {
    viewProperties.forceVectorsFromObjectsVisible = v;
    notifyListeners();
  }

  void setLevelVisible(bool v) {
    viewProperties.levelIndicatorVisible = v;
    notifyListeners();
  }

  void setPositionChoice(PositionIndicatorChoice c) {
    viewProperties.positionMarkerState = c;
    notifyListeners();
  }

  void setSupportsEnabled(bool enabled) {
    model.setSupportsEnabled(enabled);
    notifyListeners();
  }

  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }
}
