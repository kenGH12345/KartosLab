import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../../../common/simulation_clock.dart';
import '../model/multiple_particle_model.dart';
import '../model/phase_state.dart';
import '../model/substance_type.dart';
import '../som_constants.dart';

/// Owns [MultipleParticleModel] for the States tab and drives it via [SimulationClock].
class StatesOfMatterController extends ChangeNotifier {
  StatesOfMatterController({
    MultipleParticleModel? model,
    SimulationClock? clock,
  })  : model = model ??
            MultipleParticleModel(
              validSubstances: const {
                SubstanceType.neon,
                SubstanceType.argon,
                SubstanceType.diatomicOxygen,
                SubstanceType.water,
              },
            ),
        clock = clock ?? SimulationClock(fps: 60) {
    this.clock.onTick = _onTick;
  }

  final MultipleParticleModel model;
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

  /// Sync play/pause across model + clock.
  void setPlaying(bool playing) {
    if (model.isPlaying == playing && clock.isRunning == playing) {
      return;
    }
    model.isPlaying = playing;
    if (playing) {
      clock.play();
    } else {
      clock.pause();
      // Match PhET: force heater to zero when paused.
      if (model.heatingCoolingAmount != 0) {
        model.setHeatingCoolingAmount(0);
      }
    }
    notifyListeners();
  }

  void togglePlaying() => setPlaying(!model.isPlaying);

  /// Single model frame while paused (PhET TimeControl step).
  void stepOnce() {
    if (model.isPlaying) return;
    model.stepInTime(SomConstants.nominalTimeStep);
    notifyListeners();
  }

  void setSubstance(SubstanceType substance) {
    model.setSubstance(substance);
    notifyListeners();
  }

  void setPhase(PhaseState phase) {
    model.setPhase(phase);
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

  void resetAll() {
    model.reset();
    // reset() already clears heatingCoolingAmount; keep explicit for contract.
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
