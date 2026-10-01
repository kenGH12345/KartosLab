import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/forces/model/motion_model.dart';
import 'package:kratos/forces/model/net_force_model.dart';

/// Black-box behavioral acceptance at model level (View binds to these APIs).
void main() {
  group('Behavioral — Net Force', () {
    test('add/remove pullers, equal/unequal, go, return, reset', () {
      final m = NetForceModel();
      final L = m.pullers.firstWhere((p) => p.id == 'largeLeft');
      final R = m.pullers.firstWhere((p) => p.id == 'largeRight');
      m.attachPuller(L, 0);
      m.attachPuller(R, 0);
      expect(m.netForce, 0);
      m.go();
      for (var i = 0; i < 30; i++) {
        m.step(1 / 60);
      }
      expect(m.cartPosition.abs(), lessThan(1e-6));
      m.detachPuller(R);
      expect(m.netForce, -150);
      m.returnCart();
      expect(m.cartPosition, 0);
      expect(L.isAttached, isTrue);
      m.resetAll();
      expect(L.isAttached, isFalse);
    });
  });

  group('Behavioral — Motion', () {
    test('stack / force / pause / step / stopwatch / reset', () {
      final m = MotionModel(MotionScreenStyle.motion);
      final fridge = m.catalog.firstWhere((i) => i.id == 'fridge');
      m.addToStack(fridge);
      expect(m.totalMass, 250);
      m.setAppliedForce(100);
      m.step(1 / 60);
      expect(m.sim.velocity, greaterThan(0));
      final x = m.sim.position;
      m.isPlaying = false;
      m.step(1 / 60);
      expect(m.sim.position, x);
      m.manualStep();
      expect(m.sim.position, isNot(x));
      m.showStopwatch = true;
      m.stopwatchRunning = true;
      m.isPlaying = true;
      m.step(1);
      expect(m.stopwatchElapsed, greaterThan(0));
      m.reset();
      expect(m.stack.single.id, 'crate1');
      expect(m.sim.appliedForce, 0);
    });
  });

  group('Behavioral — Friction', () {
    test('static hold, breakaway, kinetic stop, reverse', () {
      final m = MotionModel(MotionScreenStyle.friction);
      expect(m.sim.frictionCoeff, 0.25);
      m.setAppliedForce(50); // below μmg≈122
      for (var i = 0; i < 60; i++) {
        m.step(1 / 60);
      }
      expect(m.sim.speed, 0);
      m.setAppliedForce(300);
      m.step(1 / 60);
      expect(m.sim.speed, greaterThan(0));
      m.setAppliedForce(0);
      for (var i = 0; i < 600; i++) {
        m.step(1 / 60);
      }
      expect(m.sim.speed, 0);
      m.setAppliedForce(-300);
      m.step(1 / 60);
      expect(m.sim.velocity, lessThan(0));
      m.reset();
      expect(m.sim.frictionCoeff, 0.25);
    });
  });

  group('Behavioral — Acceleration', () {
    test('bucket mass, force→a, friction slider, reset', () {
      final m = MotionModel(MotionScreenStyle.acceleration);
      final bucket = m.catalog.firstWhere((i) => i.id == 'bucket');
      expect(bucket.mass, 100);
      m.addToStack(bucket);
      expect(m.totalMass, 150);
      m.setFriction(0);
      m.setAppliedForce(150);
      m.sim.updateForces();
      expect(m.sim.sumOfForces / m.sim.mass, closeTo(1.0, 1e-9));
      m.step(1 / 60);
      expect(m.sim.acceleration, closeTo(1.0, 1e-6));
      m.reset();
      expect(m.hasAccelerometer, isTrue);
      expect(m.stack.single.id, 'crate1');
    });
  });

  group('Cross-screen model isolation', () {
    test('independent models do not share state', () {
      final a = NetForceModel();
      final b = MotionModel(MotionScreenStyle.motion);
      final c = MotionModel(MotionScreenStyle.friction);
      a.attachPuller(a.pullers.first, 0);
      a.go();
      a.step(1);
      b.setAppliedForce(200);
      b.step(1);
      c.setFriction(0.5);
      expect(a.cartPosition, isNot(0));
      expect(b.sim.velocity, isNot(0));
      expect(c.sim.frictionCoeff, 0.5);
      expect(b.sim.frictionCoeff, 0);
      a.resetAll();
      b.reset();
      c.reset();
      expect(a.cartPosition, 0);
      expect(b.sim.velocity, 0);
      expect(c.sim.frictionCoeff, 0.25);
    });
  });
}
