import 'package:flutter/material.dart';

import '../../../common/simulation_clock.dart';
import '../audio/peg_sound_generation.dart';
import '../model/intro_model.dart';
import '../model/peg.dart';
import '../model/plinko_common_model.dart';
import '../model/plinko_random.dart';

enum HistogramDisplayMode { counter, cylinder, fraction }

/// View-only properties shared by Intro/Lab.
class PlinkoViewProperties {
  HistogramDisplayMode histogramMode;
  bool isSoundEnabled;
  bool isTheoreticalHistogramVisible;

  PlinkoViewProperties({
    this.histogramMode = HistogramDisplayMode.counter,
    this.isSoundEnabled = false,
    this.isTheoreticalHistogramVisible = false,
  });

  void reset({required HistogramDisplayMode defaultMode}) {
    histogramMode = defaultMode;
    isSoundEnabled = false;
    isTheoreticalHistogramVisible = false;
  }
}

/// Intro controller — SimulationClock → IntroModel.step.
class IntroController extends ChangeNotifier {
  IntroController({PlinkoRandom? random})
      : model = IntroModel(random: random ?? PlinkoRandom()),
        clock = SimulationClock(fps: 60) {
    viewProperties = PlinkoViewProperties(
      histogramMode: HistogramDisplayMode.cylinder,
    );
    pegSound = PegSoundGeneration();
    clock.onTick = _onTick;
    model.onChanged = notifyListeners;
    model.onBallsMoved = notifyListeners;
    model.onBallHittingPeg = _onPegHit;
  }

  final IntroModel model;
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
    pegSound.enabled = viewProperties.isSoundEnabled;
    pegSound.playBallHittingPegSound(direction);
  }

  void play() {
    if (!model.isBallCapReached) {
      model.play();
      notifyListeners();
    }
  }

  void setBallMode(BallMode mode) {
    model.setBallMode(mode);
    notifyListeners();
  }

  void setHistogramMode(HistogramDisplayMode mode) {
    viewProperties.histogramMode = mode;
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
    viewProperties.reset(defaultMode: HistogramDisplayMode.cylinder);
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
