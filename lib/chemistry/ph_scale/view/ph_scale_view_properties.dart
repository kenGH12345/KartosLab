import 'package:flutter/foundation.dart';

/// View toggles for Micro / My Solution — PhET `PHScaleViewProperties.ts`.
class PhScaleViewProperties extends ChangeNotifier {
  bool ratioVisible = false;
  bool particleCountsVisible = false;

  void setRatioVisible(bool v) {
    if (ratioVisible == v) return;
    ratioVisible = v;
    notifyListeners();
  }

  void setParticleCountsVisible(bool v) {
    if (particleCountsVisible == v) return;
    particleCountsVisible = v;
    notifyListeners();
  }

  void reset() {
    ratioVisible = false;
    particleCountsVisible = false;
    notifyListeners();
  }
}
