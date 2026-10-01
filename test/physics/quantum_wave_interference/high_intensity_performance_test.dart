import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/constants/qwi_constants.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/models/high_intensity_model.dart';
import 'package:kratos/physics/quantum_wave_interference/render_data/high_intensity/wave_field_render_data.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_controller.dart';

void main() {
  test('wave sample + step budget (soft)', () {
    final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(1)));
    c.setEmitting(true);
    final sw = Stopwatch()..start();
    for (var i = 0; i < 30; i++) {
      c.stepOnce();
    }
    final stepMs = sw.elapsedMilliseconds;
    sw.reset();
    WaveFieldRenderData.sample(c.scene);
    final sampleMs = sw.elapsedMilliseconds;
    expect(stepMs, lessThan(5000));
    expect(sampleMs, lessThan(15000));
    // ignore: avoid_print
    print('HI perf: 30 stepOnce=${stepMs}ms; one 120² sample=${sampleMs}ms');
  });

  test('hit buffer capped at maxHits', () {
    final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(2)));
    c.setDetectionMode(DetectorMode.hits);
    c.setEmitting(true);
    expect(c.scene.hits.maxHits, QwiConstants.maxHits);
    expect(c.scene.hits.length, lessThanOrEqualTo(QwiConstants.maxHits));
  });
}
