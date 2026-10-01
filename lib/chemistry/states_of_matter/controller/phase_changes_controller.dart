import 'package:flutter/material.dart';

import '../../../common/simulation_clock.dart';
import '../model/phase_changes_model.dart';
import '../model/substance_type.dart';
import '../som_constants.dart';

/// Owns [PhaseChangesModel] and drives it via [SimulationClock].
class PhaseChangesController extends ChangeNotifier {
  PhaseChangesController({
    PhaseChangesModel? model,
    SimulationClock? clock,
  })  : model = model ?? PhaseChangesModel(),
        clock = clock ?? SimulationClock(fps: 60) {
    this.clock.onTick = _onTick;
  }

  final PhaseChangesModel model;
  final SimulationClock clock;

  bool _attached = false;

  void attach(TickerProvider vsync) {
    if (_attached) return;
    clock.attach(vsync);
    _attached = true;
    _syncClockToModelPlaying();
  }

  void _onTick(double dt, double totalTime) {
    if (model.isPlaying) {
      model.step(dt);
    }
    notifyListeners();
  }

  void _syncClockToModelPlaying() {
    if (model.isPlaying) {
      clock.play();
    } else {
      clock.pause();
    }
  }

  void setPlaying(bool playing) {
    if (model.isPlaying == playing && clock.isRunning == playing) return;
    model.isPlaying = playing;
    if (playing) {
      clock.play();
    } else {
      clock.pause();
      if (model.heatingCoolingAmount != 0) {
        model.setHeatingCoolingAmount(0);
      }
    }
    notifyListeners();
  }

  void togglePlaying() => setPlaying(!model.isPlaying);

  void stepOnce() {
    if (model.isPlaying) return;
    model.stepInTime(SomConstants.nominalTimeStep);
    notifyListeners();
  }

  void setSubstance(SubstanceType substance) {
    model.setSubstance(substance);
    notifyListeners();
  }

  void setEpsilon(double epsilon) {
    model.setEpsilon(epsilon);
    notifyListeners();
  }

  void setTargetContainerHeight(double height) {
    model.setTargetContainerHeight(height);
    notifyListeners();
  }

  void setHeatingCoolingAmount(double amount) {
    if (!model.isPlaying || model.isExploded) {
      model.setHeatingCoolingAmount(0);
    } else {
      model.setHeatingCoolingAmount(amount.clamp(-1.0, 1.0));
    }
    notifyListeners();
  }

  void pumpMolecules([int count = 3]) {
    if (!model.isPumpEnabled) return;
    model.injectMoleculesFromPump(count);
    notifyListeners();
  }

  void returnLid() {
    model.returnLid();
    notifyListeners();
  }

  void togglePhaseDiagram() {
    model.phaseDiagramExpanded = !model.phaseDiagramExpanded;
    notifyListeners();
  }

  void toggleInteractionPotential() {
    model.interactionPotentialExpanded = !model.interactionPotentialExpanded;
    notifyListeners();
  }

  void resetAll() {
    model.reset();
    model.heatingCoolingAmount = 0;
    clock.reset();
    _syncClockToModelPlaying();
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
