import 'dart:ui';

import '../color_vision_constants.dart';
import 'color_vision_model_base.dart';
import 'event_timer.dart';
import 'rgb_photon_beam.dart';

/// PhET `RGBModel.js`.
class RgbModel extends ColorVisionModelBase {
  RgbModel({CvRandom? random}) : _random = random ?? CvRandom() {
    redBeam = RgbPhotonBeam(
      colorHex: '#ff0000',
      getIntensity: () => redIntensity,
      setPerceivedIntensity: (v) => perceivedRedIntensity = v,
      beamLength: ColorVisionConstants.redBeamLength,
      random: _random,
    );
    greenBeam = RgbPhotonBeam(
      colorHex: '#00ff00',
      getIntensity: () => greenIntensity,
      setPerceivedIntensity: (v) => perceivedGreenIntensity = v,
      beamLength: ColorVisionConstants.greenBeamLength,
      random: _random,
    );
    blueBeam = RgbPhotonBeam(
      colorHex: '#0000ff',
      getIntensity: () => blueIntensity,
      setPerceivedIntensity: (v) => perceivedBlueIntensity = v,
      beamLength: ColorVisionConstants.blueBeamLength,
      random: _random,
    );

    _redTimer = EventTimer(
      getPeriodBeforeNextEvent: () =>
          IntensityEventModel(() => redIntensity).getPeriodBeforeNextEvent(),
      onEvent: redBeam.createPhoton,
    );
    _greenTimer = EventTimer(
      getPeriodBeforeNextEvent: () =>
          IntensityEventModel(() => greenIntensity).getPeriodBeforeNextEvent(),
      onEvent: greenBeam.createPhoton,
    );
    _blueTimer = EventTimer(
      getPeriodBeforeNextEvent: () =>
          IntensityEventModel(() => blueIntensity).getPeriodBeforeNextEvent(),
      onEvent: blueBeam.createPhoton,
    );
  }

  final CvRandom _random;

  double redIntensity = 0;
  double greenIntensity = 0;
  double blueIntensity = 0;

  double perceivedRedIntensity = 0;
  double perceivedGreenIntensity = 0;
  double perceivedBlueIntensity = 0;

  late final RgbPhotonBeam redBeam;
  late final RgbPhotonBeam greenBeam;
  late final RgbPhotonBeam blueBeam;

  late final EventTimer _redTimer;
  late final EventTimer _greenTimer;
  late final EventTimer _blueTimer;

  @override
  Color get perceivedColor {
    final r = (perceivedRedIntensity * ColorVisionConstants.colorScaleFactor)
        .floor()
        .clamp(0, 255);
    final g = (perceivedGreenIntensity * ColorVisionConstants.colorScaleFactor)
        .floor()
        .clamp(0, 255);
    final b = (perceivedBlueIntensity * ColorVisionConstants.colorScaleFactor)
        .floor()
        .clamp(0, 255);
    return Color.fromARGB(255, r, g, b);
  }

  void setRedIntensity(double value) {
    redIntensity = value.clamp(0, 100);
    _redTimer.timeBeforeNextEvent = 0;
    notifyListeners();
  }

  void setGreenIntensity(double value) {
    greenIntensity = value.clamp(0, 100);
    _greenTimer.timeBeforeNextEvent = 0;
    notifyListeners();
  }

  void setBlueIntensity(double value) {
    blueIntensity = value.clamp(0, 100);
    _blueTimer.timeBeforeNextEvent = 0;
    notifyListeners();
  }

  void _stepBeams(double timeElapsed) {
    redBeam.updateAnimationFrame(timeElapsed);
    greenBeam.updateAnimationFrame(timeElapsed);
    blueBeam.updateAnimationFrame(timeElapsed);
  }

  void _stepTimers(double dt) {
    _redTimer.step(dt);
    _greenTimer.step(dt);
    _blueTimer.step(dt);
  }

  @override
  void step(double dt) {
    dt = dt < ColorVisionConstants.maxDt ? dt : ColorVisionConstants.maxDt;
    if (!playing) return;
    _stepBeams(dt);
    _stepTimers(dt);
    notifyListeners();
  }

  @override
  void manualStep() {
    _stepBeams(ColorVisionConstants.manualStepDt);
    _stepTimers(ColorVisionConstants.manualStepDt);
    notifyListeners();
  }

  @override
  void reset() {
    resetBase();
    redIntensity = 0;
    greenIntensity = 0;
    blueIntensity = 0;
    perceivedRedIntensity = 0;
    perceivedGreenIntensity = 0;
    perceivedBlueIntensity = 0;
    redBeam.reset();
    greenBeam.reset();
    blueBeam.reset();
    notifyListeners();
  }
}
