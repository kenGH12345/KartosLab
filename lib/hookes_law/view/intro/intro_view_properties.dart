import 'package:flutter/foundation.dart';

/// Intro view flags. `js/intro/view/IntroViewProperties.ts`.
///
/// These are not the spring model. Two systems share one set of flags.
class IntroViewProperties extends ChangeNotifier {
  int _numberOfSystems = 1;
  bool appliedForceVectorVisible = false;
  bool springForceVectorVisible = false;
  bool displacementVectorVisible = false;
  bool equilibriumPositionVisible = false;
  bool valuesVisible = false;
  int generation = 0;

  int get numberOfSystems => _numberOfSystems;

  set numberOfSystems(int value) {
    if (value != 1 && value != 2) {
      throw ArgumentError.value(value, 'numberOfSystems', 'must be 1 or 2');
    }
    if (value == _numberOfSystems) {
      return;
    }
    _numberOfSystems = value;
    notifyListeners();
  }

  /// Values checkbox is enabled only when at least one vector is shown.
  bool get valuesEnabled =>
      appliedForceVectorVisible ||
      springForceVectorVisible ||
      displacementVectorVisible;

  void setAppliedForceVectorVisible(bool value) =>
      _setFlag(() => appliedForceVectorVisible = value);

  void setSpringForceVectorVisible(bool value) =>
      _setFlag(() => springForceVectorVisible = value);

  void setDisplacementVectorVisible(bool value) =>
      _setFlag(() => displacementVectorVisible = value);

  void setEquilibriumPositionVisible(bool value) =>
      _setFlag(() => equilibriumPositionVisible = value);

  void setValuesVisible(bool value) {
    if (!valuesEnabled) {
      return;
    }
    _setFlag(() => valuesVisible = value);
  }

  void reset() {
    _numberOfSystems = 1;
    appliedForceVectorVisible = false;
    springForceVectorVisible = false;
    displacementVectorVisible = false;
    equilibriumPositionVisible = false;
    valuesVisible = false;
    generation++;
    notifyListeners();
  }

  void _setFlag(void Function() apply) {
    apply();
    notifyListeners();
  }
}
