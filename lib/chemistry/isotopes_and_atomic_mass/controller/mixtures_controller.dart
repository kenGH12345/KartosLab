/// ChangeNotifier wrapping [MixturesModel] for Mix Isotopes screen.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/interactivity_mode.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/mixtures_model.dart';

class MixturesController extends ChangeNotifier {
  MixturesController({MixturesModel? model})
      : model = model ?? MixturesModel(),
        clock = SimulationClock(fps: 60);

  final MixturesModel model;
  final SimulationClock clock;

  int _lastRevision = -1;

  /// View-only AccordionBox expanded flags (PhET AccordionBox default expanded).
  bool compositionExpanded = true;
  bool averageMassExpanded = true;

  void attach(TickerProvider vsync) {
    clock.attach(vsync);
    clock.onTick = (dt, elapsed) {
      _publishIfNeeded();
    };
    clock.play();
    _publishIfNeeded(force: true);
  }

  void _publishIfNeeded({bool force = false}) {
    if (force || model.revision != _lastRevision) {
      _lastRevision = model.revision;
      notifyListeners();
    }
  }

  void selectElement(int z) {
    model.selectElement(z);
    _publishIfNeeded(force: true);
  }

  void setInteractivityMode(InteractivityMode mode) {
    model.setInteractivityMode(mode);
    _publishIfNeeded(force: true);
  }

  void setShowingNaturesMix(bool showing) {
    model.setShowingNaturesMix(showing);
    _publishIfNeeded(force: true);
  }

  void setIsotopeQuantity(int massNumber, int quantity) {
    model.setIsotopeQuantity(massNumber, quantity);
    _publishIfNeeded(force: true);
  }

  bool beginDrag(int particleId, double modelX, double modelY) {
    final ok = model.beginDrag(particleId, modelX, modelY);
    if (ok) _publishIfNeeded(force: true);
    return ok;
  }

  bool updateDrag(double modelX, double modelY) {
    final ok = model.updateDrag(modelX, modelY);
    if (ok) _publishIfNeeded(force: true);
    return ok;
  }

  bool endDrag() {
    final ok = model.endDrag();
    _publishIfNeeded(force: true);
    return ok;
  }

  void clear() {
    if (model.showingNaturesMix) return;
    model.clearTestChamber();
    _publishIfNeeded(force: true);
  }

  /// Count-level helpers used by tests / future UI shortcuts.
  bool moveBucketToChamber(int massNumber) {
    final ok = model.moveBucketToChamber(massNumber);
    if (ok) _publishIfNeeded(force: true);
    return ok;
  }

  void setCompositionExpanded(bool value) {
    if (compositionExpanded == value) return;
    compositionExpanded = value;
    notifyListeners();
  }

  void setAverageMassExpanded(bool value) {
    if (averageMassExpanded == value) return;
    averageMassExpanded = value;
    notifyListeners();
  }

  void reset() {
    model.reset();
    compositionExpanded = true;
    averageMassExpanded = true;
    clock.reset();
    clock.play();
    _publishIfNeeded(force: true);
  }

  @override
  void dispose() {
    clock.pause();
    clock.dispose();
    super.dispose();
  }
}
