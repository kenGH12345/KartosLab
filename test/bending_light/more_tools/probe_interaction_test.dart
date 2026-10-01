import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';

void main() {
  test('drag-out moves the body and the probe tip separately after placement', () {
    final model = MoreToolsModel()..setLaserOn(true);
    final sensor = model.waveSensor;
    final body0 = sensor.bodyPosition;
    final tip0 = sensor.probe1.position;
    final drop = body0.plusXY(1e-6, 0);
    final dx = drop.x - body0.x;
    final dy = drop.y - body0.y;
    sensor.bodyPosition = drop;
    sensor.probe1.position = tip0.plusXY(dx, dy);
    sensor.enabled = true;
    expect(sensor.probe1.position.x - sensor.bodyPosition.x, closeTo(tip0.x - body0.x, 1e-15));

    sensor.probe1.position = sensor.probe1.position.plusXY(2e-6, 0);
    expect(sensor.bodyPosition.x, drop.x);
    expect(sensor.probe1.position.x, isNot(drop.x));
  });

  test('reset returns probes to the toolbox state', () {
    final model = MoreToolsModel();
    model.waveSensor.enabled = true;
    model.waveSensor.probe1.position = const BlVec2(1e-6, 1e-6);
    model.step();
    model.reset();
    expect(model.waveSensor.enabled, isFalse);
    expect(model.waveSensor.probe1.series, isEmpty);
  });
}
