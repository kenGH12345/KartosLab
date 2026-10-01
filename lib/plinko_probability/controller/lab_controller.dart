import 'package:flutter/material.dart';

import '../../../common/simulation_clock.dart';
import '../audio/peg_sound_generation.dart';
import '../model/lab_model.dart';
import '../model/peg.dart';
import '../model/plinko_common_model.dart';
import '../model/plinko_random.dart';
import 'intro_controller.dart';

/// Lab controller — SimulationClock → LabModel.step.
class LabController extends ChangeNotifier {
  LabController({PlinkoRandom? random})
      : model = LabModel(random: random ?? PlinkoRandom()),
        clock = SimulationClock(fps: 60) {
    viewProperties = PlinkoViewProperties(
      histogramMode: HistogramDisplayMode.counter,
    );
    pegSound = PegSoundGeneration();
    clock.onTick = _onTick;
    model.onChanged = notifyListeners;
    model.onBallsMoved = notifyListeners;
    model.onBallHittingPeg = _onPegHit;
  }

  final LabModel model;
  final SimulationClock clock;
  late final PlinkoViewProperties viewProperties;
  late final PegSoundGeneration pegSound;

  void attach(TickerProvider vsync) {
    clock.attach(vsync);
    clock.play();
  }

  void _onTick(double dt, double _) {
    model.step(dt);
    pegSound.step(dt);
    notifyListeners();
  }

  void _onPegHit(PegDirection direction) {
    // Sound only in ball hopper mode (LabScreenView.js)
    if (model.hopperMode != HopperMode.ball) return;
    pegSound.enabled = viewProperties.isSoundEnabled;
    pegSound.playBallHittingPegSound(direction);
  }

  void playPressed() {
    if (model.isBallCapReached) return;
    model.playPressed();
    notifyListeners();
  }

  void pausePressed() {
    model.pausePressed();
    notifyListeners();
  }

  void setBallMode(BallMode mode) {
    model.setBallMode(mode);
    if (mode != BallMode.continuous) {
      model.setPlaying(false);
    }
    notifyListeners();
  }

  void setHopperMode(HopperMode mode) {
    model.setHopperMode(mode);
    notifyListeners();
  }

  void setNumberOfRows(int rows) {
    model.setNumberOfRows(rows);
    notifyListeners();
  }

  void setProbability(double p) {
    model.setProbability(p);
    notifyListeners();
  }

  void setHistogramMode(HistogramDisplayMode mode) {
    viewProperties.histogramMode = mode;
    notifyListeners();
  }

  void setIdealVisible(bool v) {
    viewProperties.isTheoreticalHistogramVisible = v;
    notifyListeners();
  }

  void erase() {
    model.erase();
    notifyListeners();
  }

  void toggleSound() {
    viewProperties.isSoundEnabled = !viewProperties.isSoundEnabled;
    pegSound.enabled = viewProperties.isSoundEnabled;
    notifyListeners();
  }

  void resetAll() {
    model.reset();
    viewProperties.reset(defaultMode: HistogramDisplayMode.counter);
    pegSound
      ..reset()
      ..enabled = false;
    clock.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    pegSound.dispose();
    clock.dispose();
    super.dispose();
  }
}
