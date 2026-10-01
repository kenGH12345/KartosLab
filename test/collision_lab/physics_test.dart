import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/collision_lab/collision_lab_constants.dart';
import 'package:kratos/collision_lab/model/ball_state.dart';
import 'package:kratos/collision_lab/model/cl_vec.dart';
import 'package:kratos/collision_lab/model/explore1d_model.dart';
import 'package:kratos/collision_lab/model/explore2d_model.dart';
import 'package:kratos/collision_lab/model/inelastic_model.dart';
import 'package:kratos/collision_lab/model/intro_model.dart';
import 'package:kratos/collision_lab/model/play_area.dart';
import 'package:kratos/collision_lab/solver/ball_utils.dart';
import 'package:kratos/collision_lab/solver/inelastic_collision_engine.dart';

void main() {
  group('BallUtils.calculateBallRadius', () {
    test('constant size returns 0.15', () {
      expect(
        BallUtils.calculateBallRadius(2.0, isConstantSize: true),
        CollisionLabConstants.ballConstantRadius,
      );
    });

    test('density sphere: mass/volume ≈ 35', () {
      const mass = 0.5;
      final r = BallUtils.calculateBallRadius(mass);
      final volume = 4 / 3 * math.pi * r * r * r;
      expect(mass / volume, closeTo(CollisionLabConstants.ballDefaultDensity, 1e-6));
    });
  });

  group('elastic ball-ball conservation', () {
    test('equal mass 1D head-on elastic exchanges velocities', () {
      final model = Explore1dModel();
      model.isPlaying = false;
      model.playArea.setElasticityPercent(100);
      model.playArea.reflectingBorder = false;
      final b1 = model.ballSystem.balls[0];
      final b2 = model.ballSystem.balls[1];
      b1.mass = 1.0;
      b2.mass = 1.0;
      final gap = b1.radius + b2.radius + 0.001;
      b1.position = ClVec(-gap / 2, 0);
      b2.position = ClVec(gap / 2, 0);
      b1.velocity = const ClVec(1, 0);
      b2.velocity = const ClVec(-1, 0);

      final pBefore = b1.momentum.x + b2.momentum.x;
      final keBefore = 0.5 * b1.mass * b1.velocity.magnitudeSquared +
          0.5 * b2.mass * b2.velocity.magnitudeSquared;

      for (var i = 0; i < 20; i++) {
        model.stepManual(CollisionLabConstants.timeStepDuration);
      }

      expect(b1.momentum.x + b2.momentum.x, closeTo(pBefore, 1e-8));
      final keAfter = 0.5 * b1.mass * b1.velocity.magnitudeSquared +
          0.5 * b2.mass * b2.velocity.magnitudeSquared;
      expect(keAfter, closeTo(keBefore, 1e-8));
      expect(b1.velocity.x, closeTo(-1, 1e-6));
      expect(b2.velocity.x, closeTo(1, 1e-6));
    });

    test('unequal mass conserves momentum and KE at e=100%', () {
      final model = Explore1dModel();
      model.isPlaying = false;
      model.playArea.setElasticityPercent(100);
      model.playArea.reflectingBorder = false;
      final b1 = model.ballSystem.balls[0];
      final b2 = model.ballSystem.balls[1];
      b1.mass = 0.5;
      b2.mass = 1.5;
      final contact = b1.radius + b2.radius + 0.002;
      b1.position = ClVec(-contact / 2, 0);
      b2.position = ClVec(contact / 2, 0);
      b1.velocity = const ClVec(1.0, 0);
      b2.velocity = const ClVec(-0.5, 0);

      final pBefore = b1.momentum.x + b2.momentum.x;
      final keBefore = 0.5 * b1.mass * b1.velocity.magnitudeSquared +
          0.5 * b2.mass * b2.velocity.magnitudeSquared;

      for (var i = 0; i < 40; i++) {
        model.stepManual(CollisionLabConstants.timeStepDuration);
      }

      expect(b1.momentum.x + b2.momentum.x, closeTo(pBefore, 1e-7));
      final keAfter = 0.5 * b1.mass * b1.velocity.magnitudeSquared +
          0.5 * b2.mass * b2.velocity.magnitudeSquared;
      expect(keAfter, closeTo(keBefore, 1e-7));
    });
  });

  group('ball-border', () {
    test('border flips vx and changes system momentum', () {
      final model = Explore1dModel();
      model.isPlaying = false;
      model.playArea.setElasticityPercent(100);
      model.playArea.reflectingBorder = true;
      model.ballSystem.setNumberOfBalls(1);
      final b = model.ballSystem.balls.first;
      b.mass = 1.0;
      b.position = ClVec(model.playArea.right - b.radius - 0.001, 0);
      b.velocity = const ClVec(2, 0);
      final pBefore = b.momentum.x;

      for (var i = 0; i < 30; i++) {
        model.stepManual(CollisionLabConstants.timeStepDuration);
      }

      expect(b.velocity.x, lessThan(0));
      expect(b.momentum.x, isNot(closeTo(pBefore, 1e-6)));
    });
  });

  group('Explore1D e=0 stick', () {
    test('grouped balls share common velocity', () {
      final model = Explore1dModel();
      model.isPlaying = false;
      model.playArea.setElasticityPercent(0);
      model.playArea.reflectingBorder = false;
      final b1 = model.ballSystem.balls[0];
      final b2 = model.ballSystem.balls[1];
      b1.mass = 1.0;
      b2.mass = 1.0;
      final contact = b1.radius + b2.radius + 0.001;
      b1.position = ClVec(-contact / 2, 0);
      b2.position = ClVec(contact / 2, 0);
      b1.velocity = const ClVec(1, 0);
      b2.velocity = const ClVec(0, 0);
      const expectedV = 0.5;

      for (var i = 0; i < 40; i++) {
        model.stepManual(CollisionLabConstants.timeStepDuration);
      }

      expect(b1.velocity.x, closeTo(expectedV, 1e-6));
      expect(b2.velocity.x, closeTo(expectedV, 1e-6));
    });
  });

  group('Inelastic stick rotation', () {
    test('off-center stick creates rotating cluster', () {
      final model = InelasticModel();
      model.isPlaying = false;
      model.playArea.inelasticCollisionType = InelasticCollisionType.stick;
      final b1 = model.ballSystem.balls[0];
      final b2 = model.ballSystem.balls[1];
      b1.mass = 1.0;
      b2.mass = 1.0;
      b1.position = const ClVec(-0.4, 0.15);
      b2.position = const ClVec(0.4, -0.15);
      b1.velocity = const ClVec(1.0, 0);
      b2.velocity = const ClVec(-1.0, 0);

      for (var i = 0; i < 80; i++) {
        model.stepManual(CollisionLabConstants.timeStepDuration);
      }

      final engine = model.collisionEngine as InelasticCollisionEngine;
      expect(engine.rotatingBallCluster, isNotNull);
      expect(engine.rotatingBallCluster!.angularVelocity.abs(), greaterThan(0));
    });
  });

  group('handleBallToBallCollision formula', () {
    test('matches PhET normal-component formula', () {
      final model = Explore2dModel();
      final engine = model.collisionEngine;
      final b1 = model.ballSystem.balls[0];
      final b2 = model.ballSystem.balls[1];
      model.playArea.setElasticityPercent(100);
      b1.mass = 1;
      b2.mass = 2;
      b1.position = const ClVec(0, 0);
      b2.position = const ClVec(1, 0);
      b1.velocity = const ClVec(1, 0.5);
      b2.velocity = const ClVec(-0.5, -0.25);

      const e = 1.0;
      const m1 = 1.0;
      const m2 = 2.0;
      final n = (b2.position - b1.position).normalized();
      final t = ClVec(-n.y, n.x);
      final v1n = b1.velocity.dot(n);
      final v2n = b2.velocity.dot(n);
      final v1t = b1.velocity.dot(t);
      final v2t = b2.velocity.dot(t);
      final v1nP = ((m1 - m2 * e) * v1n + m2 * (1 + e) * v2n) / (m1 + m2);
      final v2nP = ((m2 - m1 * e) * v2n + m1 * (1 + e) * v1n) / (m1 + m2);

      engine.handleBallToBallCollision(b1, b2, 0.01);

      final expected1 = t * v1t + n * v1nP;
      final expected2 = t * v2t + n * v2nP;

      expect(b1.velocity.x, closeTo(expected1.x, 1e-9));
      expect(b1.velocity.y, closeTo(expected1.y, 1e-9));
      expect(b2.velocity.x, closeTo(expected2.x, 1e-9));
      expect(b2.velocity.y, closeTo(expected2.y, 1e-9));
    });
  });

  group('time control semantics', () {
    test('stepBackwards uses negative dt', () {
      final model = IntroModel();
      model.isPlaying = false;
      model.playArea.setElasticityPercent(100);
      model.stepForwards();
      model.stepForwards();
      expect(model.elapsedTime, closeTo(0.02, 1e-12));
      model.stepBackwards();
      expect(model.elapsedTime, closeTo(0.01, 1e-12));
      model.stepBackwards();
      model.stepBackwards();
      expect(model.elapsedTime, greaterThanOrEqualTo(0));
    });

    test('restart vs reset', () {
      final model = IntroModel();
      final b1 = model.ballSystem.balls[0];
      final initial = BallState(
        position: b1.position,
        velocity: b1.velocity,
        mass: b1.mass,
      );
      b1.position = const ClVec(0.2, 0);
      b1.velocity = const ClVec(0.1, 0);
      b1.saveState();
      model.restart();
      expect(b1.position.x, closeTo(0.2, 1e-12));
      model.reset();
      expect(b1.position.x, closeTo(initial.position.x, 1e-12));
    });
  });

  group('grid snap', () {
    test('drag with grid rounds to 0.1', () {
      final model = Explore2dModel();
      model.playArea.gridVisible = true;
      final b = model.ballSystem.balls[0];
      b.dragToPosition(const ClVec(0.26, -0.14));
      expect(b.position.x, closeTo(0.3, 1e-9));
      expect(b.position.y, closeTo(-0.1, 1e-9));
    });

    test('1D drag forces y=0', () {
      final model = IntroModel();
      final b = model.ballSystem.balls[0];
      b.dragToPosition(const ClVec(0.5, 0.4));
      expect(b.position.y, 0);
    });
  });
}
