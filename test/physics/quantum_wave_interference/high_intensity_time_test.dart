import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/time_speed.dart';
import 'package:kratos/physics/quantum_wave_interference/models/high_intensity_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_controller.dart';

void main() {
  test('HI speed factors 0.15 / 0.35 / 0.65', () {
    final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(1)));
    expect(c.model.clock.speedFactors.slow, 0.15);
    expect(c.model.clock.speedFactors.normal, 0.35);
    expect(c.model.clock.speedFactors.fast, 0.65);
  });

  test('fast advances more sim time than normal for same wall dt', () {
    double advance(TimeSpeed speed) {
      final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(1)));
      c.setEmitting(true);
      c.setTimeSpeed(speed);
      for (var i = 0; i < 30; i++) {
        c.stepWall(1 / 60);
      }
      return c.scene.solver.time;
    }

    expect(advance(TimeSpeed.fast), greaterThan(advance(TimeSpeed.normal)));
    expect(advance(TimeSpeed.normal), greaterThan(advance(TimeSpeed.slow)));
  });

  test('stepOnce ignores TimeSpeed', () {
    final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(1)));
    c.setTimeSpeed(TimeSpeed.fast);
    c.setPlaying(false);
    final t0 = c.scene.solver.time;
    c.stepOnce();
    expect(c.scene.solver.time - t0, closeTo(1 / 60, 1e-12));
  });
}
