import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/model/net_force_model.dart';

void main() {
  test('attach / detach / go / return / reset interaction sequence', () {
    final m = NetForceModel();
    final left = m.pullers.firstWhere((p) => p.id == 'largeLeft');
    final right = m.pullers.firstWhere((p) => p.id == 'smallRight1');

    m.attachPuller(left, 0);
    m.attachPuller(right, 1);
    expect(m.netForce, -150 + 50);

    m.go();
    expect(m.isRunning, isTrue);
    expect(m.hasStarted, isTrue);
    m.step(1 / 60);
    expect(m.cartPosition, isNot(0));

    m.pause();
    final x = m.cartPosition;
    m.step(1);
    expect(m.cartPosition, x);

    m.returnCart();
    expect(m.cartPosition, 0);
    expect(left.knotIndex, 0);
    expect(right.knotIndex, 1);

    m.resetAll();
    expect(left.knotIndex, isNull);
    expect(m.hasStarted, isFalse);
  });

  test('cannot go without pullers', () {
    final m = NetForceModel();
    m.go();
    expect(m.isRunning, isFalse);
  });
}
