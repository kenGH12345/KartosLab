import 'package:flutter/foundation.dart';

import '../model/amplitude_direction.dart';
import '../model/nm_vec.dart';
import '../model/time_speed.dart';
import '../model/two_dimensions_model.dart';
import '../normal_modes_constants.dart';

class TwoDimensionsController extends ChangeNotifier {
  TwoDimensionsController() {
    model.setExactPositions();
  }

  final TwoDimensionsModel model = TwoDimensionsModel();
  bool amplitudesExpanded = true;

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

  void setAmplitudeDirection(AmplitudeDirection d) {
    model.amplitudeDirection = d;
    notifyListeners();
  }

  void toggleAmplitudeCell(int row, int col) {
    model.toggleAmplitudeCell(row, col);
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
    amplitudesExpanded = true;
    notifyListeners();
  }

  void beginDrag(int i, int j) {
    model.draggingMassIndexes = DragIndex(i, j);
    notifyListeners();
  }

  void updateDrag(int i, int j, NmVec displacement) {
    model.arrowsVisible = false;
    model.masses[i][j].displacement = displacement;
    notifyListeners();
  }

  void endDrag({required bool interrupted}) {
    if (!interrupted) {
      model.draggingMassIndexes = null;
    }
    model.computeModeAmplitudesAndPhases();
    notifyListeners();
  }

  void setAmplitudesExpanded(bool v) {
    amplitudesExpanded = v;
    notifyListeners();
  }
}
