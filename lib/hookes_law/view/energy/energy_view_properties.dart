import 'package:flutter/foundation.dart';

/// Which graph is shown. Not a physical property. `EnergyGraph.ts`.
enum EnergyGraphKind { barGraph, energyPlot, forcePlot }

/// Energy view flags. `EnergyViewProperties.ts`.
///
/// The spring model is not in here. Graph choice and the Force Plot energy
/// triangle are view state. Values is always enabled; Energy has no
/// "at least one vector" gate.
class EnergyViewProperties extends ChangeNotifier {
  EnergyGraphKind graph = EnergyGraphKind.barGraph;
  bool energyOnForcePlotVisible = false;
  bool appliedForceVectorVisible = false;
  bool displacementVectorVisible = false;
  bool equilibriumPositionVisible = false;
  bool valuesVisible = false;
  int generation = 0;

  set graphKind(EnergyGraphKind value) {
    if (value == graph) {
      return;
    }
    graph = value;
    notifyListeners();
  }

  void setEnergyOnForcePlotVisible(bool value) {
    if (graph != EnergyGraphKind.forcePlot) {
      return;
    }
    _setFlag(() => energyOnForcePlotVisible = value);
  }

  void setAppliedForceVectorVisible(bool value) =>
      _setFlag(() => appliedForceVectorVisible = value);

  void setDisplacementVectorVisible(bool value) =>
      _setFlag(() => displacementVectorVisible = value);

  void setEquilibriumPositionVisible(bool value) =>
      _setFlag(() => equilibriumPositionVisible = value);

  void setValuesVisible(bool value) => _setFlag(() => valuesVisible = value);

  bool get showEnergyPlot => graph == EnergyGraphKind.energyPlot;

  bool get showForcePlot => graph == EnergyGraphKind.forcePlot;

  void reset() {
    graph = EnergyGraphKind.barGraph;
    energyOnForcePlotVisible = false;
    appliedForceVectorVisible = false;
    displacementVectorVisible = false;
    equilibriumPositionVisible = false;
    valuesVisible = false;
    generation++;
    notifyListeners();
  }

  void _setFlag(VoidCallback write) {
    write();
    notifyListeners();
  }
}
