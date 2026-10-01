import 'package:flutter/foundation.dart';

import '../fmw_constants.dart';
import '../model/wave_game_level.dart';
import '../model/wave_game_model.dart';

/// Owns [WaveGameModel] for level select + in-level play.
class WaveGameController extends ChangeNotifier {
  WaveGameController() : model = WaveGameModel();

  final WaveGameModel model;

  /// Last check-answer feedback (null = none).
  bool? lastCheckCorrect;

  WaveGameLevel? get selectedLevel => model.selectedLevel;

  bool get isLevelSelect => model.selectedLevel == null;

  void selectLevel(int levelNumber) {
    model.selectLevel(levelNumber);
    lastCheckCorrect = null;
    notifyListeners();
  }

  void backToLevels() {
    model.clearLevelSelection();
    lastCheckCorrect = null;
    notifyListeners();
  }

  void setGuessAmplitude(int order, double amplitude) {
    final level = model.selectedLevel;
    if (level == null || level.isSolved) return;
    final clamped = amplitude.clamp(
      -FmwConstants.maxAmplitude,
      FmwConstants.maxAmplitude,
    );
    level.guessSeries.setAmplitude(order, clamped.toDouble());
    lastCheckCorrect = null;
    notifyListeners();
  }

  void setNumberOfAmplitudeControls(int n) {
    final level = model.selectedLevel;
    if (level == null) return;
    level.numberOfAmplitudeControls =
        n.clamp(level.amplitudeControlsMin, level.amplitudeControlsMax);
    notifyListeners();
  }

  void eraseAmplitudes() {
    final level = model.selectedLevel;
    if (level == null || level.isSolved) return;
    level.eraseAmplitudes();
    lastCheckCorrect = null;
    notifyListeners();
  }

  int checkAnswer() {
    final level = model.selectedLevel;
    if (level == null || level.isSolved) return 0;
    final points = level.checkAnswer();
    lastCheckCorrect = points > 0;
    notifyListeners();
    return points;
  }

  void showAnswer() {
    final level = model.selectedLevel;
    if (level == null) return;
    level.showAnswer();
    lastCheckCorrect = true;
    notifyListeners();
  }

  void newWaveform() {
    final level = model.selectedLevel;
    if (level == null) return;
    level.newWaveform();
    lastCheckCorrect = null;
    notifyListeners();
  }

  void reset() {
    model.reset();
    lastCheckCorrect = null;
    notifyListeners();
  }
}
