import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/model/motion_model.dart';

void main() {
  test('motion force drives velocity', () {
    final m = MotionModel(MotionScreenStyle.motion);
    m.setAppliedForce(100);
    for (var i = 0; i < 60; i++) {
      m.step(1 / 60);
    }
    expect(m.sim.velocity, closeTo(2, 0.05)); // a=2 for 1s
  });

  test('acceleration screen exposes accelerometer flag', () {
    final m = MotionModel(MotionScreenStyle.acceleration);
    expect(m.hasAccelerometer, isTrue);
    expect(m.hasStopwatch, isFalse);
    expect(m.catalog.any((i) => i.isBucket), isTrue);
  });
}
