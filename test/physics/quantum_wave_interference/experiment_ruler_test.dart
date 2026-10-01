import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_screen_scale.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/models/experiment_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/experiment/experiment_controller.dart';

void main() {
  test('ruler visibility does not change physics', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    final wl = c.scene.wavelengthNm;
    final i0 = c.scene.intensityAtPhysicalX(0);
    c.setRulerVisible(true);
    c.setRulerPosition(100, 50);
    expect(c.scene.wavelengthNm, wl);
    expect(c.scene.intensityAtPhysicalX(0), i0);
  });

  test('ruler scale follows detector zoom', () {
    final c = ExperimentController(model: ExperimentModel(random: SeededQwiRandom(1)));
    c.setDetectorScreenScaleIndex(2);
    expect(c.model.ruler.scaleHalfWidthMm, DetectorScreenScale.options[2].maxMM);
  });
}
