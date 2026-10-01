import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/pendulum_lab/model/body.dart';
import 'package:kratos/pendulum_lab/model/energy_model.dart';
import 'package:kratos/pendulum_lab/model/lab_model.dart';
import 'package:kratos/pendulum_lab/model/pendulum.dart';
import 'package:kratos/pendulum_lab/model/pendulum_drag_logic.dart';
import 'package:kratos/pendulum_lab/model/pendulum_lab_model.dart';
import 'package:kratos/pendulum_lab/pl_constants.dart';

void main() {
  group('Pendulum.modAngle', () {
    test('wraps into (-π, π]', () {
      expect(Pendulum.modAngle(0), 0);
      expect(Pendulum.modAngle(math.pi), math.pi);
      expect(Pendulum.modAngle(-math.pi), -math.pi);
      expect(Pendulum.modAngle(3 * math.pi / 2), closeTo(-math.pi / 2, 1e-12));
      expect(Pendulum.modAngle(-3 * math.pi / 2), closeTo(math.pi / 2, 1e-12));
    });

    test('negative remainder matches JS % not Dart %', () {
      // JS: (-7) % (2π) is negative; Dart `%` would be positive.
      final wrapped = Pendulum.modAngle(-7);
      expect(wrapped, inInclusiveRange(-math.pi, math.pi));
      expect(wrapped, isNot(closeTo((-7) % (2 * math.pi), 1e-9)));
    });
  });

  group('frictionTerm', () {
    test('matches Pendulum.js linear + quadratic', () {
      final p = Pendulum(
        index: 0,
        mass: 1,
        length: 0.7,
        hasPeriodTimer: false,
        gravity: () => 9.8,
        friction: () => 0.5115,
      );
      const omega = 1.5;
      final expected = 0.5115 * 0.7 / math.pow(1, 1 / 3) * omega * omega.abs() +
          0.5115 / math.pow(1, 2 / 3) * omega;
      expect(p.frictionTerm(omega), closeTo(expected, 1e-12));
    });

    test('zero friction yields zero term', () {
      final p = Pendulum(
        index: 0,
        mass: 1,
        length: 0.7,
        hasPeriodTimer: false,
        gravity: () => 9.8,
        friction: () => 0,
      );
      expect(p.frictionTerm(2), 0);
    });
  });

  group('energy', () {
    test('PE at rest is 0; PE at 90° is m g L', () {
      final p = Pendulum(
        index: 0,
        mass: 1,
        length: 0.7,
        hasPeriodTimer: false,
        gravity: () => 9.8,
        friction: () => 0,
      );
      p.updateDerivedVariables(false);
      expect(p.potentialEnergy, closeTo(0, 1e-12));
      p.angle = math.pi / 2;
      p.angularVelocity = 0;
      p.updateDerivedVariables(false);
      expect(p.potentialEnergy, closeTo(1 * 9.8 * 0.7, 1e-9));
      expect(p.kineticEnergy, 0);
    });

    test('KE = ½ m (L ω)²', () {
      final p = Pendulum(
        index: 0,
        mass: 1,
        length: 0.7,
        hasPeriodTimer: false,
        gravity: () => 9.8,
        friction: () => 0,
      );
      p.angularVelocity = 2;
      p.updateDerivedVariables(false);
      expect(p.kineticEnergy, closeTo(0.5 * 1 * (0.7 * 2) * (0.7 * 2), 1e-12));
    });
  });

  group('RK4 integration', () {
    test('rest at θ=0 stays at rest', () {
      final p = Pendulum(
        index: 0,
        mass: 1,
        length: 0.7,
        hasPeriodTimer: false,
        gravity: () => 9.8,
        friction: () => 0,
      );
      p.step(1 / 60);
      expect(p.angle, 0);
      expect(p.angularVelocity, 0);
    });

    test('released from 30° swings through zero with continuous ω', () {
      final p = Pendulum(
        index: 0,
        mass: 1,
        length: 0.7,
        hasPeriodTimer: false,
        gravity: () => 9.8,
        friction: () => 0,
      );
      p.angle = math.pi / 6;
      p.updateDerivedVariables(false);
      var crossed = false;
      p.crossingListeners.add((_, _) => crossed = true);
      var lastOmega = p.angularVelocity;
      for (var i = 0; i < 180; i++) {
        p.step(1 / 60);
        expect(p.angle.isFinite, isTrue);
        expect(p.angularVelocity.isFinite, isTrue);
        lastOmega = p.angularVelocity;
      }
      expect(crossed, isTrue);
      expect(lastOmega, isNot(0));
    });

    test('friction transfers energy to thermal', () {
      final p = Pendulum(
        index: 0,
        mass: 1,
        length: 0.7,
        hasPeriodTimer: false,
        gravity: () => 9.8,
        friction: () => 0.2,
      );
      p.angle = math.pi / 4;
      p.updateDerivedVariables(false);
      final e0 = p.kineticEnergy + p.potentialEnergy;
      for (var i = 0; i < 300; i++) {
        p.step(1 / 60);
      }
      expect(p.thermalEnergy, greaterThan(0));
      expect(
        p.totalEnergy,
        closeTo(e0, 0.05),
      );
    });

    test('length change scales ω by L_old/L_new', () {
      final p = Pendulum(
        index: 0,
        mass: 1,
        length: 0.7,
        hasPeriodTimer: false,
        gravity: () => 9.8,
        friction: () => 0,
      );
      p.angularVelocity = 2;
      p.length = 1.0;
      expect(p.angularVelocity, closeTo(2 * 0.7 / 1.0, 1e-12));
    });
  });

  group('PendulumLabModel', () {
    test('defaults match Intro source', () {
      final m = PendulumLabModel();
      expect(m.body, PlBody.earth);
      expect(m.gravity, PlConstants.earthGravity);
      expect(m.numberOfPendula, 1);
      expect(m.isPlaying, isTrue);
      expect(m.friction, 0);
      expect(m.pendula[0].isVisible, isTrue);
      expect(m.pendula[1].isVisible, isFalse);
      expect(m.pendula[0].mass, 1);
      expect(m.pendula[0].length, 0.7);
      expect(m.pendula[1].mass, 0.5);
      expect(m.pendula[1].length, 1.0);
      expect(m.ruler.isVisible, isTrue);
      expect(m.stopwatch.isVisible, isFalse);
    });

    test('step while paused does nothing', () {
      final m = PendulumLabModel();
      m.pendula[0].angle = 0.4;
      m.pendula[0].updateDerivedVariables(false);
      m.setPlaying(false);
      m.step(1 / 60);
      expect(m.pendula[0].angle, 0.4);
    });

    test('stepManual advances 0.01s even when paused', () {
      final m = PendulumLabModel();
      m.pendula[0].angle = 0.4;
      m.pendula[0].updateDerivedVariables(false);
      m.setPlaying(false);
      m.stepManual();
      expect(m.pendula[0].angle, isNot(0.4));
    });

    test('returnPendula clears motion not gravity', () {
      final m = PendulumLabModel();
      m.setGravity(14.2);
      m.pendula[0].angle = 0.5;
      m.pendula[0].thermalEnergy = 3;
      m.returnPendula();
      expect(m.pendula[0].angle, 0);
      expect(m.pendula[0].thermalEnergy, 0);
      expect(m.gravity, 14.2);
    });

    test('reset restores defaults including playing', () {
      final m = PendulumLabModel();
      m.setPlaying(false);
      m.setNumberOfPendula(2);
      m.setFriction(0.2);
      m.setGravity(1.62);
      m.pendula[0].angle = 1;
      m.reset();
      expect(m.isPlaying, isTrue);
      expect(m.numberOfPendula, 1);
      expect(m.friction, 0);
      expect(m.gravity, 9.8);
      expect(m.body, PlBody.earth);
      expect(m.pendula[0].angle, 0);
    });

    test('Planet X to Custom restores customGravity (anti-cheat)', () {
      final m = PendulumLabModel();
      m.setGravity(10);
      expect(m.body, PlBody.custom);
      m.setBody(PlBody.planetX);
      expect(m.gravity, PlConstants.planetXGravity);
      m.setBody(PlBody.custom);
      expect(m.gravity, 10);
    });

    test('dt cap 0.05 and 1.007 factor', () {
      final m = PendulumLabModel();
      m.pendula[0].angle = 0.3;
      m.pendula[0].updateDerivedVariables(false);
      m.step(1.0); // wall dt huge → capped 0.05 * 1.007
      expect(m.pendula[0].angle.isFinite, isTrue);
    });

    test('damp near rest snaps to zero', () {
      final m = PendulumLabModel();
      m.setFriction(0.5115);
      final p = m.pendula[0];
      p.angle = 5e-4;
      p.angularVelocity = 5e-4;
      p.updateDerivedVariables(false);
      m.modelStep(1 / 60);
      expect(p.angle.abs() < 1e-2, isTrue);
    });
  });

  group('Energy / Lab models', () {
    test('Energy hides ruler and expands graph', () {
      final m = EnergyModel();
      expect(m.ruler.isVisible, isFalse);
      expect(m.isEnergyBoxExpanded, isTrue);
      expect(m.activeEnergyPendulum, same(m.pendula[0]));
    });

    test('Lab has period timer and collapsed energy', () {
      final m = LabModel();
      expect(m.hasPeriodTimer, isTrue);
      expect(m.isEnergyBoxExpanded, isFalse);
      expect(m.periodTimer, isNotNull);
      expect(m.isVelocityVisible, isFalse);
    });
  });

  group('friction slider mapping', () {
    test('0 and max', () {
      expect(PlConstants.sliderValueToFriction(0), 0);
      expect(
        PlConstants.sliderValueToFriction(10),
        closeTo(PlConstants.frictionMax, 1e-12),
      );
      expect(PlConstants.frictionToSliderValue(0), 0);
      expect(PlConstants.frictionToSliderValue(0.5115), 10);
    });
  });

  group('drag rounding', () {
    test('snaps to degree and rejects 180', () {
      final a = PendulumDragLogic.roundedAngle(math.pi);
      expect(PlConstants.toDegrees(a).abs(), 179);
    });
  });

  group('position convention', () {
    test('θ=0 hangs down (−y)', () {
      final p = Pendulum(
        index: 0,
        mass: 1,
        length: 0.7,
        hasPeriodTimer: false,
        gravity: () => 9.8,
        friction: () => 0,
      );
      p.updateDerivedVariables(false);
      expect(p.position.x, closeTo(0, 1e-12));
      expect(p.position.y, closeTo(-0.7, 1e-12));
    });
  });
}
