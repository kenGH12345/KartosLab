import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

void main() {
  group('Angular dynamics update order', () {
    test('one-step oracle: omega += alpha then theta += omega*dt then damp', () {
      final model = BalanceModel();
      model.setColumnState(ColumnState.noColumns);
      final m = BaMass.generic(40, const BaVector2(0, 0));
      model.plank.addMassToSurfaceAt(m, 1.5);

      model.plank.updateNetTorque();
      final tau = model.plank.currentNetTorque;
      final inertia = BaGeometry.momentOfInertia;
      var alpha = tau / inertia;
      if (alpha.abs() <= BaGeometry.angularAccelerationEpsilon) alpha = 0;

      expect(model.plank.angularVelocity, 0);
      expect(model.plank.tiltAngle, 0);

      const dt = 1 / 60;
      var expectedOmega = 0.0 + alpha; // SOURCE: omega += alpha (no *dt)
      if (expectedOmega.abs() <= BaGeometry.angularVelocityEpsilon) {
        expectedOmega = 0;
      }
      var expectedAngle = 0.0 + expectedOmega * dt;
      if (expectedAngle.abs() > model.plank.maxTiltAngle) {
        expectedAngle = model.plank.maxTiltAngle;
        expectedOmega = 0;
      } else if (expectedAngle.abs() < BaGeometry.nearLevelAngleEpsilon) {
        expectedAngle = 0;
      }
      expectedOmega *= BaGeometry.dampingFactor;

      model.step(dt);

      expect(model.plank.tiltAngle, closeTo(expectedAngle, 1e-12));
      expect(model.plank.angularVelocity, closeTo(expectedOmega, 1e-12));
    });

    test('multi-step: damping compounds; alpha never multiplied by dt', () {
      final model = BalanceModel();
      model.setColumnState(ColumnState.noColumns);
      final m = BaMass.generic(50, const BaVector2(0, 0));
      model.plank.addMassToSurfaceAt(m, 2.0);

      const dt = 1 / 60;
      var omega = 0.0;
      var angle = 0.0;

      for (var step = 0; step < 5; step++) {
        model.plank.updateNetTorque();
        var alpha = model.plank.currentNetTorque / BaGeometry.momentOfInertia;
        if (alpha.abs() <= BaGeometry.angularAccelerationEpsilon) alpha = 0;
        omega += alpha; // NOT alpha * dt
        if (omega.abs() <= BaGeometry.angularVelocityEpsilon) omega = 0;
        var newAngle = angle + omega * dt;
        if (newAngle.abs() > model.plank.maxTiltAngle) {
          newAngle = model.plank.maxTiltAngle * (angle < 0 ? -1 : 1);
          omega = 0;
        } else if (newAngle.abs() < BaGeometry.nearLevelAngleEpsilon) {
          newAngle = 0;
        }
        angle = newAngle;
        omega *= BaGeometry.dampingFactor;

        model.step(dt);
        expect(model.plank.tiltAngle, closeTo(angle, 1e-9));
        expect(model.plank.angularVelocity, closeTo(omega, 1e-9));
      }
    });

    test('DOUBLE_COLUMNS zeros torque and holds level', () {
      final model = BalanceModel();
      final m = BaMass.generic(40, const BaVector2(0, 0));
      model.plank.addMassToSurfaceAt(m, 1.5);
      expect(model.columnState, ColumnState.doubleColumns);
      model.plank.updateNetTorque();
      expect(model.plank.currentNetTorque, 0);
      model.step(1 / 60);
      expect(model.plank.tiltAngle, 0);
      expect(model.plank.angularVelocity, 0);
    });

    test('maxTiltAngle matches asin(1/3)', () {
      final model = BalanceModel();
      expect(model.plank.maxTiltAngle, closeTo(math.asin(1 / 3), 1e-12));
    });
  });
}
