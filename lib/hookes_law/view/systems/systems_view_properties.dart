import 'package:flutter/foundation.dart';

/// Systems view flags. `js/systems/view/SystemsViewProperties.ts`.
///
/// Not part of the spring model. Total / Components only chooses which
/// arrows are drawn.
enum SystemsKind { parallel, series }

enum SpringForceRepresentation { total, components }

class SystemsViewProperties extends ChangeNotifier {
  SystemsKind _systemType = SystemsKind.parallel;
  SpringForceRepresentation _springForceRepresentation =
      SpringForceRepresentation.total;
  bool appliedForceVectorVisible = false;
  bool springForceVectorVisible = false;
  bool displacementVectorVisible = false;
  bool equilibriumPositionVisible = false;
  bool valuesVisible = false;
  int generation = 0;

  SystemsKind get systemType => _systemType;

  set systemType(SystemsKind value) {
    if (value == _systemType) {
      return;
    }
    _systemType = value;
    notifyListeners();
  }

  SpringForceRepresentation get springForceRepresentation =>
      _springForceRepresentation;

  set springForceRepresentation(SpringForceRepresentation value) {
    if (!springForceVectorVisible) {
      return;
    }
    if (value == _springForceRepresentation) {
      return;
    }
    _springForceRepresentation = value;
    notifyListeners();
  }

  bool get valuesEnabled =>
      appliedForceVectorVisible ||
      springForceVectorVisible ||
      displacementVectorVisible;

  bool get showTotalSpringForce =>
      springForceVectorVisible &&
      _springForceRepresentation == SpringForceRepresentation.total;

  bool get showComponentSpringForces =>
      springForceVectorVisible &&
      _springForceRepresentation == SpringForceRepresentation.components;

  void setAppliedForceVectorVisible(bool value) =>
      _set(() => appliedForceVectorVisible = value);

  void setSpringForceVectorVisible(bool value) =>
      _set(() => springForceVectorVisible = value);

  void setDisplacementVectorVisible(bool value) =>
      _set(() => displacementVectorVisible = value);

  void setEquilibriumPositionVisible(bool value) =>
      _set(() => equilibriumPositionVisible = value);

  void setValuesVisible(bool value) {
    if (!valuesEnabled) {
      return;
    }
    _set(() => valuesVisible = value);
  }

  void reset() {
    _systemType = SystemsKind.parallel;
    _springForceRepresentation = SpringForceRepresentation.total;
    appliedForceVectorVisible = false;
    springForceVectorVisible = false;
    displacementVectorVisible = false;
    equilibriumPositionVisible = false;
    valuesVisible = false;
    generation++;
    notifyListeners();
  }

  void _set(void Function() apply) {
    apply();
    notifyListeners();
  }
}
