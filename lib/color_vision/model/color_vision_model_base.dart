import 'package:flutter/foundation.dart';

import 'dart:ui';

import '../color_vision_constants.dart';

/// PhET `ColorVisionModel.js` base fields shared by both screens.
abstract class ColorVisionModelBase extends ChangeNotifier {
  bool playing = true;
  HeadMode headMode = HeadMode.noBrain;

  Color get perceivedColor;

  @protected
  void resetBase() {
    playing = true;
    headMode = HeadMode.noBrain;
  }

  void setPlaying(bool value) {
    if (playing == value) return;
    playing = value;
    notifyListeners();
  }

  void setHeadMode(HeadMode mode) {
    if (headMode == mode) return;
    headMode = mode;
    notifyListeners();
  }

  void step(double dt);
  void manualStep();
  void reset();
}
