import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/intro_model.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';
import 'package:kratos/bending_light/model/substance.dart';

void main() {
  test('moving the intensity probe updates the reading', () {
    final model = IntroModel(
      bottomSubstance: Substance.water,
      horizontalPlayAreaOffset: true,
    );
    model.setLaserOn(true);
    model.intensityMeter.enabled = true;
    model.intensityMeter.sensorPosition = const BlVec2(-1e-4, 1e-4);
    model.updateModel();
    expect(model.intensityMeter.reading.isMiss, isTrue);

    final incident = model.rays.firstWhere((r) => r.rayType == 'incident');
    model.intensityMeter.sensorPosition = BlVec2(
      (incident.tail.x + incident.tip.x) / 2,
      (incident.tail.y + incident.tip.y) / 2,
    );
    model.updateModel();
    expect(model.intensityMeter.reading.isMiss, isFalse);
    expect(model.intensityMeter.reading.displayPercent, greaterThan(0));
  });

  test('velocity sensor value follows probe position', () {
    final model = MoreToolsModel()..setLaserOn(true);
    model.velocitySensor.enabled = true;
    final incident = model.rays.firstWhere((r) => r.rayType == 'incident');
    model.velocitySensor.position = BlVec2(
      (incident.tail.x + incident.tip.x) / 2,
      (incident.tail.y + incident.tip.y) / 2,
    );
    model.updateModel();
    expect(model.velocitySensor.value.magnitude, greaterThan(0));

    model.velocitySensor.position = const BlVec2(1e-3, 1e-3);
    model.updateModel();
    expect(model.velocitySensor.value.magnitude, 0);
  });

  test('wave probe samples when the sensor is enabled and time steps', () {
    final model = MoreToolsModel()..setLaserOn(true);
    model.waveSensor.enabled = true;
    final incident = model.rays.firstWhere((r) => r.rayType == 'incident');
    model.waveSensor.probe1.position = BlVec2(
      (incident.tail.x + incident.tip.x) / 2,
      (incident.tail.y + incident.tip.y) / 2,
    );
    model.updateModel();
    final before = model.waveSensor.probe1.series.length;
    model.step();
    expect(model.waveSensor.probe1.series.length, greaterThan(before));
  });
}
