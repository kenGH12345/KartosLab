import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/balancing_act/ba_mvt.dart';
import 'package:kratos/balancing_act/model/ba_enums.dart';
import 'package:kratos/balancing_act/model/ba_mass.dart';
import 'package:kratos/balancing_act/model/ba_vector2.dart';
import 'package:kratos/balancing_act/model/balance_lab_model.dart';
import 'package:kratos/common/simulation_clock.dart';

/// Clock + Balance Lab model bridge. Physics only via [BalanceLabModel.step].
class BaBalanceLabController extends ChangeNotifier {
  BaBalanceLabController({
    BalanceLabModel? model,
    BalanceViewProperties? viewProperties,
  })  : model = model ?? BalanceLabModel(),
        viewProperties = viewProperties ?? BalanceViewProperties(),
        mvt = BaModelViewTransform(),
        clock = SimulationClock(fps: 60) {
    clock.onTick = _onTick;
  }

  final BalanceLabModel model;
  final BalanceViewProperties viewProperties;
  final BaModelViewTransform mvt;
  final SimulationClock clock;

  BaMass? _dragging;
  BaVector2? _dragOffset;

  BaMass? get dragging => _dragging;

  void attach(TickerProvider vsync) {
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

  /// Creator press: spawn mass at pointer and start drag (source forwarding).
  void startBrickCreator(int numBricks, Offset viewPos) {
    final modelPos = mvt.viewToModel(viewPos);
    final mass = model.createBrickStack(numBricks, modelPos);
    _dragging = mass;
    _dragOffset = const BaVector2(0, 0);
    notifyListeners();
  }

  void startPersonCreator(BaMassType type, Offset viewPos) {
    final modelPos = mvt.viewToModel(viewPos);
    final mass = model.createPerson(type, modelPos);
    _dragging = mass;
    _dragOffset = const BaVector2(0, 0);
    notifyListeners();
  }

  void startMysteryCreator(int mysteryId, Offset viewPos) {
    final modelPos = mvt.viewToModel(viewPos);
    final mass = model.createMystery(mysteryId, modelPos);
    _dragging = mass;
    _dragOffset = const BaVector2(0, 0);
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

  void nextCarouselPage() {
    model.carousel.nextPage();
    notifyListeners();
  }

  void previousCarouselPage() {
    model.carousel.previousPage();
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
