import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/waves_intro/model/scene_kind.dart';
import 'package:kratos/waves_intro/model/wave_scene.dart';
import 'package:kratos/waves_intro/waves_intro_constants.dart';

void main() {
  test('reset clears lattice and restores defaults (sound direct source)', () {
    final scene = WaveScene(config: SceneConfig.sound);
    scene.setAmplitude(3);
    scene.setFrequency(0.3);
    scene.setDisturbanceType(DisturbanceType.pulse);
    scene.setButtonPressed(true);

    for (var i = 0; i < 30; i++) {
      scene.advanceTime(1 / WavesIntroConstants.eventRate, manualStep: true);
    }

    final srcI = WavesIntroConstants.pointSourceHorizontal;
    final srcJ = scene.lattice.height ~/ 2;
    expect(scene.lattice.getCurrentValue(srcI, srcJ).abs(), greaterThan(0));

    scene.reset();

    expect(scene.amplitude, WavesIntroConstants.initialAmplitude);
    expect(scene.frequency, SceneConfig.sound.defaultFrequency);
    expect(scene.disturbanceType, DisturbanceType.continuous);
    expect(scene.buttonPressed, isFalse);
    expect(scene.time, 0);

    var energy = 0.0;
    for (var i = 0; i < scene.lattice.width; i++) {
      for (var j = 0; j < scene.lattice.height; j++) {
        energy += scene.lattice.getCurrentValue(i, j).abs();
      }
    }
    expect(energy, 0);
  });

  test('water reset clears drops and desired*', () {
    final scene = WaveScene(config: SceneConfig.water);
    scene.setAmplitude(4);
    scene.setFrequency(0.8);
    scene.setButtonPressed(true);
    for (var i = 0; i < 10; i++) {
      scene.advanceTime(1 / WavesIntroConstants.eventRate, manualStep: true);
    }
    expect(scene.waterDrops, isNotEmpty);
    scene.reset();
    expect(scene.waterDrops, isEmpty);
    expect(scene.desiredAmplitude, WavesIntroConstants.initialAmplitude);
    expect(scene.desiredFrequency, SceneConfig.water.defaultFrequency);
  });
}
