import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/rutherford_scattering/model/rs_base_model.dart';
import 'package:kratos/rutherford_scattering/model/rutherford_atom_model.dart';
import 'package:kratos/rutherford_scattering/rs_constants.dart';

/// ChangeNotifier wrapping [RsBaseModel] + [SimulationClock].
class RsSimulationController extends ChangeNotifier {
  RsSimulationController(this.model)
      : clock = SimulationClock(fps: 1 / RsConstants.manualStepDt);

  final RsBaseModel model;
  final SimulationClock clock;

  int _lastRevision = -1;

  void attach(TickerProvider vsync) {
    clock.attach(vsync);
    clock.onTick = (dt, _) {
      model.step(dt);
      _publishIfNeeded(force: true);
    };
    if (model.running) {
      clock.play();
    }
    _publishIfNeeded(force: true);
  }

  void _publishIfNeeded({bool force = false}) {
    if (force || model.revision != _lastRevision) {
      _lastRevision = model.revision;
      notifyListeners();
    }
  }

  void setGunOn(bool value) {
    model.setGunOn(value);
    _publishIfNeeded(force: true);
  }

  void setRunning(bool value) {
    model.setRunning(value);
    if (value) {
      clock.play();
    } else {
      clock.pause();
    }
    _publishIfNeeded(force: true);
  }

  void toggleRunning() => setRunning(!model.running);

  void manualStep() {
    if (model.running) return;
    model.manualStep();
    _publishIfNeeded(force: true);
  }

  void setAlphaParticleEnergy(double value) {
    model.setAlphaParticleEnergy(value);
    _publishIfNeeded(force: true);
  }

  void setShowTraces(bool value) {
    model.setShowTraces(value);
    _publishIfNeeded(force: true);
  }

  void setProtonCount(int value) {
    model.setProtonCount(value);
    _publishIfNeeded(force: true);
  }

  void setNeutronCount(int value) {
    model.setNeutronCount(value);
    _publishIfNeeded(force: true);
  }

  void setUserInteraction(bool value) {
    model.setUserInteraction(value);
    _publishIfNeeded(force: true);
  }

  void setScene(RutherfordScene scene) {
    final m = model;
    if (m is RutherfordAtomModel) {
      m.setScene(scene);
      _publishIfNeeded(force: true);
    }
  }

  void reset() {
    model.reset();
    clock.reset();
    if (model.running) {
      clock.play();
    } else {
      clock.pause();
    }
    _publishIfNeeded(force: true);
  }

  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }
}
