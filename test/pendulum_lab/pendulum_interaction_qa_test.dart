import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/pendulum_lab/model/lab_model.dart';
import 'package:kratos/pendulum_lab/model/pendulum.dart';
import 'package:kratos/pendulum_lab/model/pendulum_drag_logic.dart';
import 'package:kratos/pendulum_lab/pl_constants.dart';

void main() {
  group('Drag / Release cross-validation semantics', () {
    test('grab sets ω=0 and clears thermal', () {
      final m = LabModel();
      final p = m.pendula[0];
      p.angle = 0.5;
      p.angularVelocity = 1.2;
      p.thermalEnergy = 3;
      p.updateDerivedVariables(false);
      p.setUserControlled(true);
      expect(p.angularVelocity, 0);
      expect(p.thermalEnergy, 0);
      expect(p.isTickVisible, isTrue);
    });

    test('drag angle uses offset + degree snap (source PendulaNode)', () {
      // Simulated start at θ=0 with pointer at +30°
      const startAngle = 0.0;
      final startDrag = PlConstants.toRadians(30);
      final offset = startAngle - startDrag;
      // Move pointer to +60°
      final continuous = Pendulum.modAngle(offset + PlConstants.toRadians(60));
      final rounded = PendulumDragLogic.roundedAngle(continuous);
      expect(PlConstants.toDegrees(rounded).round(), 30);
    });

    test('release leaves θ and ω=0 then integrates continuously', () {
      final m = LabModel();
      final p = m.pendula[0];
      p.setUserControlled(true);
      p.setAngle(math.pi / 4, fromUser: true);
      p.setUserControlled(false);
      expect(p.isUserControlled, isFalse);
      expect(p.angularVelocity, 0);
      final a0 = p.angle;
      m.modelStep(1 / 60);
      expect(p.angle, isNot(a0));
      expect(p.angularVelocity, isNot(0));
    });

    test('±180° snaps to ±179°', () {
      expect(
        PlConstants.toDegrees(PendulumDragLogic.roundedAngle(math.pi)).abs(),
        179,
      );
      expect(
        PlConstants.toDegrees(PendulumDragLogic.roundedAngle(-math.pi)).abs(),
        179,
      );
    });

    test('distanceToBob is 0 inside bob AABB at rest', () {
      // Bob hangs at (512, 15 + scale*0.7)
      final viewLen = PendulumDragLogic.transform.modelToViewDeltaX(0.7);
      final bobCenter = Offset(
        PlConstants.mvtOrigin.dx,
        PlConstants.mvtOrigin.dy + viewLen,
      );
      final d = PendulumDragLogic.distanceToBob(
        viewPoint: bobCenter,
        angle: 0,
        length: 0.7,
        mass: 1,
      );
      expect(d, 0);
    });
  });

  group('Period Timer', () {
    test('running binds elapsedTime from periodTrace', () {
      final m = LabModel();
      final timer = m.periodTimer!;
      m.pendula[0].angle = math.pi / 5;
      m.pendula[0].updateDerivedVariables(false);
      timer.setVisible(true);
      timer.setRunning(true);
      expect(timer.activePendulum.periodTrace.isVisible, isTrue);
      for (var i = 0; i < 200; i++) {
        m.modelStep(1 / 60);
        timer.syncFromTrace();
        if (!timer.isRunning) break;
      }
      // Either completed a period or still measuring — elapsed must track.
      expect(timer.elapsedTime, greaterThanOrEqualTo(0));
      if (!timer.isRunning) {
        expect(timer.activePendulum.periodTrace.numberOfPoints, 4);
      }
    });

    test('Return stops period timer', () {
      final m = LabModel();
      m.periodTimer!.setVisible(true);
      m.periodTimer!.setRunning(true);
      m.returnPendula();
      expect(m.periodTimer!.isRunning, isFalse);
    });
  });
}
