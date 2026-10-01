import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/waves_intro/model/scene_kind.dart';
import 'package:kratos/waves_intro/model/water_drop.dart';
import 'package:kratos/waves_intro/model/wave_scene.dart';
import 'package:kratos/waves_intro/waves_intro_constants.dart';

void main() {
  test('WaterDrop falls at WATER_DROP_SPEED and absorbs at y<0', () {
    var absorbed = false;
    final drop = WaterDrop(
      amplitude: 8,
      startsOscillation: true,
      sourceSeparation: 0,
      sign: 1,
      onAbsorption: () => absorbed = true,
    );
    expect(drop.y, WaterDrop.initialDistanceAboveLattice);
    // Need > 100/140 seconds of scene dt
    final need = WaterDrop.initialDistanceAboveLattice / WaterDrop.waterDropSpeed;
    drop.step(need + 0.01);
    expect(absorbed, isTrue);
    expect(drop.y, lessThan(0));
  });

  test('water: slider sets desired*; lattice freq changes after drop absorbs',
      () {
    final scene = WaveScene(config: SceneConfig.water);
    scene.setAmplitude(5);
    scene.setFrequency(0.9);
    expect(scene.desiredAmplitude, 5);
    expect(scene.desiredFrequency, 0.9);
    // Lattice values still at defaults until absorption
    expect(scene.amplitude, WavesIntroConstants.initialAmplitude);
    expect(scene.frequency, SceneConfig.water.defaultFrequency);

    scene.setButtonPressed(true);
    final period = 1 / WavesIntroConstants.eventRate;
    for (var i = 0; i < 80; i++) {
      scene.advanceTime(period, manualStep: true);
      if (scene.continuousOscillating) break;
    }
    expect(scene.continuousOscillating, isTrue);
    expect(scene.amplitude, 5);
    expect(scene.frequency, closeTo(0.9, 1e-12));
  });

  test('water: button does not immediately set continuousOscillating', () {
    final scene = WaveScene(config: SceneConfig.water);
    scene.setButtonPressed(true);
    expect(scene.continuousOscillating, isFalse);
    expect(scene.buttonPressed, isTrue);
  });
}
