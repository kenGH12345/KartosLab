/// Atom Screen view-only properties — shred `AtomViewProperties`.
library;

import 'package:flutter/foundation.dart';

import '../model/baa_model.dart';
import '../model/electron_model.dart';

/// Labels / accordion / electron depiction flags (View layer).
class AtomViewState extends ChangeNotifier {
  AtomViewState(this.model);

  final BAAModel model;

  bool elementNameVisible = true;
  bool neutralAtomOrIonVisible = true;
  bool nuclearStabilityVisible = false;

  // Match reference screenshots with all three open; seats stay fixed when
  // collapsed so headers do not shift (PhET cold-start collapses net/mass).
  bool periodicTableExpanded = true;
  bool netChargeExpanded = true;
  bool massNumberExpanded = true;

  void setElementNameVisible(bool v) {
    if (elementNameVisible == v) return;
    elementNameVisible = v;
    notifyListeners();
  }

  void setNeutralAtomOrIonVisible(bool v) {
    if (neutralAtomOrIonVisible == v) return;
    neutralAtomOrIonVisible = v;
    notifyListeners();
  }

  void setNuclearStabilityVisible(bool v) {
    if (nuclearStabilityVisible == v) return;
    nuclearStabilityVisible = v;
    model.setAnimateNuclearInstability(v);
    notifyListeners();
  }

  void setPeriodicTableExpanded(bool v) {
    if (periodicTableExpanded == v) return;
    periodicTableExpanded = v;
    notifyListeners();
  }

  void setNetChargeExpanded(bool v) {
    if (netChargeExpanded == v) return;
    netChargeExpanded = v;
    notifyListeners();
  }

  void setMassNumberExpanded(bool v) {
    if (massNumberExpanded == v) return;
    massNumberExpanded = v;
    notifyListeners();
  }

  void setElectronModel(ElectronModelType type) {
    model.setElectronModel(type);
    notifyListeners();
  }

  void reset() {
    elementNameVisible = true;
    neutralAtomOrIonVisible = true;
    nuclearStabilityVisible = false;
    periodicTableExpanded = true;
    netChargeExpanded = true;
    massNumberExpanded = true;
    model.setAnimateNuclearInstability(false);
    model.setElectronModel(ElectronModelType.shells);
    notifyListeners();
  }
}
