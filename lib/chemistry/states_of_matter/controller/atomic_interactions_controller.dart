import 'package:flutter/material.dart';

import '../../../common/simulation_clock.dart';
import '../model/atom_pair.dart';
import '../model/dual_atom_model.dart';
import '../model/force_display_mode.dart';
import '../som_constants.dart';

/// Owns [DualAtomModel] for the Interaction tab.
class AtomicInteractionsController extends ChangeNotifier {
  AtomicInteractionsController({
    DualAtomModel? model,
    SimulationClock? clock,
  })  : model = model ?? DualAtomModel(),
        clock = clock ?? SimulationClock(fps: 60) {
    this.clock.onTick = _onTick;
  }

  final DualAtomModel model;
  final SimulationClock clock;

  bool _attached = false;

  void attach(TickerProvider vsync) {
    if (_attached) return;
    clock.attach(vsync);
    _attached = true;
    _syncClock();
  }

  void _onTick(double dt, double totalTime) {
    if (model.isPlaying) {
      model.step(dt);
    }
    notifyListeners();
  }

  void _syncClock() {
    if (model.isPlaying) {
      clock.play();
    } else {
      clock.pause();
    }
  }

  void setPlaying(bool playing) {
    model.setPlaying(playing);
    _syncClock();
    notifyListeners();
  }

  void togglePlaying() => setPlaying(!model.isPlaying);

  void stepOnce() {
    if (model.isPlaying) return;
    model.stepInternal(
      SomConstants.nominalTimeStep * DualAtomModel.normalMotionTimeMultiplier,
    );
    notifyListeners();
  }

  void setTimeSpeed(InteractionTimeSpeed speed) {
    model.setTimeSpeed(speed);
    notifyListeners();
  }

  void setAtomPair(AtomPair pair) {
    model.setAtomPair(pair);
    notifyListeners();
  }

  void setForcesDisplayMode(ForceDisplayMode mode) {
    model.setForcesDisplayMode(mode);
    notifyListeners();
  }

  void toggleForcesExpanded() {
    model.toggleForcesExpanded();
    notifyListeners();
  }

  void setEpsilon(double epsilon) {
    model.setEpsilon(epsilon);
    notifyListeners();
  }

  void setAdjustableAtomSigma(double sigma) {
    model.setAdjustableAtomSigma(sigma);
    notifyListeners();
  }

  void dragTo(double xPm) {
    model.dragMovableAtomTo(xPm);
    notifyListeners();
  }

  void endDrag() {
    model.endDrag();
    notifyListeners();
  }

  void returnAtom() {
    model.resetMovableAtomPos();
    model.updateForces();
    notifyListeners();
  }

  void resetAll() {
    model.reset();
    clock.reset();
    _syncClock();
    notifyListeners();
  }

  @override
  void dispose() {
    clock.pause();
    clock.dispose();
    model.dispose();
    super.dispose();
  }
}
