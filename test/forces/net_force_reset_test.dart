import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/model/net_force_model.dart';

void main() {
  test('resetAll restores defaults', () {
    final m = NetForceModel();
    m.attachPuller(m.pullers.first, 0);
    m.showSumOfForces = true;
    m.showValues = true;
    m.showSpeed = true;
    m.go();
    m.step(0.5);
    m.resetAll();
    expect(m.cartPosition, 0);
    expect(m.cartVelocity, 0);
    expect(m.isRunning, isFalse);
    expect(m.isCompleted, isFalse);
    expect(m.winner, isNull);
    expect(m.hasStarted, isFalse);
    expect(m.showSumOfForces, isFalse);
    expect(m.showValues, isFalse);
    expect(m.showSpeed, isFalse);
    expect(m.pullers.every((p) => !p.isAttached), isTrue);
  });
}
