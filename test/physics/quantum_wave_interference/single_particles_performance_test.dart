import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/quantum_wave_interference.dart';
import 'package:kratos/physics/quantum_wave_interference/view/single_particles/single_particles_controller.dart';

void main() {
  test('1000 particles hit buffer stays capped and sampling finishes', () {
    final model = SingleParticlesModel(random: SeededQwiRandom(99));
    model.scene.setAutoRepeat(true);
    model.clock.setSpeed(TimeSpeed.fast);
    final sw = Stopwatch()..start();
    for (var i = 0; i < 80000 && model.scene.hits.length < 1000; i++) {
      model.step(1 / 60);
    }
    sw.stop();
    expect(model.scene.hits.length, greaterThanOrEqualTo(100));
    expect(model.scene.hits.length, lessThanOrEqualTo(QwiConstants.maxHits));
    // Sanity: should not take tens of seconds in unit test env.
    expect(sw.elapsedMilliseconds, lessThan(120000));
  });

  test('wave resample cache does not allocate unbounded widgets', () {
    final c = SingleParticlesController(model: SingleParticlesModel(random: SeededQwiRandom(1)));
    c.fireOnce();
    for (var i = 0; i < 30; i++) {
      c.stepOnce();
      c.resampleWave();
    }
    expect(c.waveField.rgba.length, c.waveField.gridWidth * c.waveField.gridHeight * 4);
  });
}
