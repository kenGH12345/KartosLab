import 'package:flutter/foundation.dart';

import '../model/amplitude_direction.dart';
import '../model/nm_vec.dart';
import '../model/one_dimension_model.dart';
import '../model/time_speed.dart';
import '../normal_modes_constants.dart';

class OneDimensionController extends ChangeNotifier {
  OneDimensionController() {
    model.setExactPositions();
  }

  final OneDimensionModel model = OneDimensionModel();
  bool spectrumExpanded = true;
  bool modesExpanded = true;

  void tick(double dt) {
    model.step(dt);
    notifyListeners();
  }

  void playPause() {
    model.playing = !model.playing;
    notifyListeners();
  }

  void stepOnce() {
    model.singleStep(NormalModesConstants.fixedDt);
    notifyListeners();
  }

  void setTimeSpeed(NmTimeSpeed speed) {
    model.timeSpeed = speed;
    notifyListeners();
  }

  void setNumberOfMasses(int n) {
    model.setNumberOfMasses(n);
    notifyListeners();
  }

  void setSpringsVisible(bool v) {
    model.springsVisible = v;
    notifyListeners();
  }

  void setPhasesVisible(bool v) {
    model.phasesVisible = v;
    notifyListeners();
  }

  void setAmplitudeDirection(AmplitudeDirection d) {
    model.amplitudeDirection = d;
    if (!model.playing && model.draggingMassIndex <= 0) {
      model.setExactPositions();
    }
    notifyListeners();
  }

  void setModeAmplitude(int i, double v) {
    model.setModeAmplitude(i, v);
    notifyListeners();
  }

  void setModePhase(int i, double v) {
    model.setModePhase(i, v);
    notifyListeners();
  }

  void initialPositions() {
    model.initialPositions();
    notifyListeners();
  }

  void zeroPositions() {
    model.zeroPositions();
    notifyListeners();
  }

  void reset() {
    model.reset();
    spectrumExpanded = true;
    modesExpanded = true;
    notifyListeners();
  }

  void beginDrag(int massIndex) {
    model.draggingMassIndex = massIndex;
    notifyListeners();
  }

  void updateDrag(int massIndex, double axisDisplacement) {
    model.arrowsVisible = false;
    final mass = model.masses[massIndex];
    if (model.amplitudeDirection == AmplitudeDirection.horizontal) {
      mass.displacement = NmVec(axisDisplacement, mass.displacement.y);
    } else {
      mass.displacement = NmVec(mass.displacement.x, axisDisplacement);
    }
    notifyListeners();
  }

  void endDrag({required bool interrupted}) {
    if (!interrupted) {
      model.draggingMassIndex = -1;
    }
    model.computeModeAmplitudesAndPhases();
    notifyListeners();
  }

  void setSpectrumExpanded(bool v) {
    spectrumExpanded = v;
    notifyListeners();
  }

  void setModesExpanded(bool v) {
    modesExpanded = v;
    notifyListeners();
  }
}
