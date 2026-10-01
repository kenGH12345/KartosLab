import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/waves_intro/model/scene_kind.dart';
import 'package:kratos/waves_intro/model/wave_scene.dart';
import 'package:kratos/waves_intro/waves_intro_constants.dart';

void main() {
  test('pulse ends after one period', () {
    final scene = WaveScene(config: SceneConfig.sound);
    scene.setDisturbanceType(DisturbanceType.pulse);
    scene.setButtonPressed(true);

    expect(scene.pulseFiring, isTrue);
    expect(scene.buttonPressed, isTrue);

    final period = 1 / scene.frequency;
    final wallDt = 1 / WavesIntroConstants.eventRate;
    // Advance enough wall time so scene time covers one period
    // (scaled by timeScaleFactor)
    final neededWall = period / scene.config.timeScaleFactor + wallDt * 2;
    var elapsed = 0.0;
    while (elapsed < neededWall && scene.pulseFiring) {
      scene.advanceTime(wallDt, manualStep: true);
      elapsed += wallDt;
    }

    expect(scene.pulseFiring, isFalse);
    expect(scene.buttonPressed, isFalse);
  });

  test('continuous keeps oscillating while button pressed', () {
    final scene = WaveScene(config: SceneConfig.sound);
    scene.setDisturbanceType(DisturbanceType.continuous);
    scene.setButtonPressed(true);
    expect(scene.continuousOscillating, isTrue);

    for (var i = 0; i < 40; i++) {
      scene.advanceTime(1 / WavesIntroConstants.eventRate, manualStep: true);
    }
    expect(scene.continuousOscillating, isTrue);
    expect(scene.pulseFiring, isFalse);
  });
}
