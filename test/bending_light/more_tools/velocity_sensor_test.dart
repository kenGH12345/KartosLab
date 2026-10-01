import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';
import 'package:kratos/bending_light/model/substance.dart';

void main() {
  test('velocity is zero off a ray and nonzero on a ray', () {
    final model = MoreToolsModel()..setLaserOn(true);
    model.velocitySensor.enabled = true;
    model.velocitySensor.position = const BlVec2(1e-3, 1e-3);
    model.updateModel();
    expect(model.velocitySensor.value.magnitude, 0);

    final incident = model.rays.firstWhere((r) => r.rayType == 'incident');
    model.velocitySensor.position = BlVec2(
      (incident.tail.x + incident.tip.x) / 2,
      (incident.tail.y + incident.tip.y) / 2,
    );
    model.updateModel();
    expect(model.velocitySensor.value.magnitude, greaterThan(0));
    expect(
      model.velocitySensor.value.magnitude,
      closeTo(incident.getSpeed(), incident.getSpeed() * 1e-6),
    );
  });

  test('a denser medium slows the measured velocity', () {
    final air = MoreToolsModel()..setLaserOn(true);
    air.setBottomSubstance(Substance.air);
    final glass = MoreToolsModel()..setLaserOn(true);
    final rayAir = air.rays.firstWhere((r) => r.rayType == 'incident');
    final rayGlass = glass.rays.firstWhere((r) => r.rayType == 'transmitted');
    expect(rayGlass.getSpeed(), lessThan(rayAir.getSpeed()));
  });

  test('reset disables the velocity sensor', () {
    final model = MoreToolsModel()..setLaserOn(true);
    model.velocitySensor.enabled = true;
    model.reset();
    expect(model.velocitySensor.enabled, isFalse);
    expect(model.velocitySensor.value.magnitude, 0);
  });
}
