/// ChangeNotifier wrapping [MakeIsotopesModel] + [SimulationClock].
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/make_isotopes_model.dart';

class MakeIsotopesController extends ChangeNotifier {
  MakeIsotopesController({MakeIsotopesModel? model})
      : model = model ?? MakeIsotopesModel(),
        clock = SimulationClock(fps: 60);

  final MakeIsotopesModel model;
  final SimulationClock clock;

  int _lastRevision = -1;

  /// View-only: AtomScale display mode (massNumber | atomicMass).
  ScaleDisplayMode displayMode = ScaleDisplayMode.massNumber;

  /// View-only accordion expanded flags (PhET AccordionBox).
  bool symbolExpanded = false;
  bool abundanceExpanded = false;

  void attach(TickerProvider vsync) {
    clock.attach(vsync);
    clock.onTick = (dt, _) {
      model.step(dt);
      _publishIfNeeded(force: true);
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

  bool beginDrag(int neutronId, double modelX, double modelY) {
    final ok = model.beginDrag(neutronId, modelX, modelY);
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

  void setAtomPosition(double x, double y) {
    model.setAtomPosition(x, y);
    _publishIfNeeded(force: true);
  }

  void setDisplayMode(ScaleDisplayMode mode) {
    if (displayMode == mode) return;
    displayMode = mode;
    notifyListeners();
  }

  void setSymbolExpanded(bool value) {
    if (symbolExpanded == value) return;
    symbolExpanded = value;
    notifyListeners();
  }

  void setAbundanceExpanded(bool value) {
    if (abundanceExpanded == value) return;
    abundanceExpanded = value;
    notifyListeners();
  }

  void reset() {
    model.reset();
    displayMode = ScaleDisplayMode.massNumber;
    symbolExpanded = false;
    abundanceExpanded = false;
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

enum ScaleDisplayMode { massNumber, atomicMass }
