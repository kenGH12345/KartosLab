import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/model/famb_constants.dart';
import 'package:kratos/forces/model/net_force_model.dart';

void main() {
  group('NetForceModel', () {
    test('puller forces are 50/100/150', () {
      final m = NetForceModel();
      expect(
        m.pullers.where((p) => p.size == PullerSize.small).every(
              (p) => p.force == 50,
            ),
        isTrue,
      );
      expect(
        m.pullers.where((p) => p.size == PullerSize.medium).every(
              (p) => p.force == 100,
            ),
        isTrue,
      );
      expect(
        m.pullers.where((p) => p.size == PullerSize.large).every(
              (p) => p.force == 150,
            ),
        isTrue,
      );
    });

    test('equal forces → net zero → cart stays', () {
      final m = NetForceModel();
      m.attachPuller(m.pullers.firstWhere((p) => p.id == 'largeLeft'), 0);
      m.attachPuller(m.pullers.firstWhere((p) => p.id == 'largeRight'), 0);
      expect(m.leftForce, -150);
      expect(m.rightForce, 150);
      expect(m.netForce, 0);
      m.go();
      for (var i = 0; i < 120; i++) {
        m.step(1 / 60);
      }
      expect(m.cartPosition, 0);
      expect(m.isCompleted, isFalse);
    });

    test('left > right → cart moves left and left wins', () {
      final m = NetForceModel();
      m.attachPuller(m.pullers.firstWhere((p) => p.id == 'largeLeft'), 0);
      m.attachPuller(m.pullers.firstWhere((p) => p.id == 'mediumLeft'), 1);
      m.go();
      for (var i = 0; i < 10000; i++) {
        m.step(1 / 60);
        if (m.isCompleted) break;
      }
      expect(m.isCompleted, isTrue);
      expect(m.winner, 'left');
      expect(m.cartPosition, -NetForceConstants.winThreshold);
    });

    test('right > left → right wins at +403', () {
      final m = NetForceModel();
      m.attachPuller(m.pullers.firstWhere((p) => p.id == 'largeRight'), 0);
      m.go();
      for (var i = 0; i < 10000; i++) {
        m.step(1 / 60);
        if (m.isCompleted) break;
      }
      expect(m.winner, 'right');
      expect(m.cartPosition, NetForceConstants.winThreshold);
    });

    test('zero force does not move', () {
      final m = NetForceModel();
      m.go(); // no pullers — go should no-op when not hasAttached
      expect(m.isRunning, isFalse);
      m.step(1);
      expect(m.cartPosition, 0);
    });

    test('return keeps pullers attached', () {
      final m = NetForceModel();
      final p = m.pullers.firstWhere((p) => p.id == 'largeLeft');
      m.attachPuller(p, 2);
      m.go();
      m.step(1 / 60);
      m.returnCart();
      expect(m.cartPosition, 0);
      expect(m.cartVelocity, 0);
      expect(p.knotIndex, 2);
      expect(m.isCompleted, isFalse);
    });

    test('resetAll clears pullers', () {
      final m = NetForceModel();
      m.attachPuller(m.pullers.first, 0);
      m.resetAll();
      expect(m.pullers.every((p) => p.knotIndex == null), isTrue);
      expect(m.hasStarted, isFalse);
    });

    test('integration uses 0.003 and 60', () {
      final m = NetForceModel();
      m.attachPuller(m.pullers.firstWhere((p) => p.id == 'largeRight'), 0);
      // F=150, dt=1 → Δv = 150*0.003 = 0.45, Δx = 0.45*60 = 27
      m.go();
      m.step(1);
      expect(m.cartVelocity, closeTo(150 * 0.003, 1e-9));
      expect(m.cartPosition, closeTo(150 * 0.003 * 60, 1e-6));
    });

    test('pause stops motion', () {
      final m = NetForceModel();
      m.attachPuller(m.pullers.firstWhere((p) => p.id == 'largeRight'), 0);
      m.go();
      m.step(1 / 60);
      final x = m.cartPosition;
      m.pause();
      m.step(1);
      expect(m.cartPosition, x);
    });
  });
}
