import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/collision_lab/collision_lab_constants.dart';
import 'package:kratos/collision_lab/controller/explore2d_controller.dart';
import 'package:kratos/collision_lab/controller/intro_controller.dart';
import 'package:kratos/collision_lab/model/cl_vec.dart';
import 'package:kratos/collision_lab/model/explore1d_model.dart';
import 'package:kratos/collision_lab/model/explore2d_model.dart';
import 'package:kratos/collision_lab/model/play_area.dart';
import 'package:kratos/collision_lab/render/cl_mvt.dart';
import 'package:kratos/collision_lab/solver/ball_utils.dart';

void main() {
  group('Velocity tip drag', () {
    test('all screens: tip maps view delta → velocity via MVT', () {
      final controller = Explore2dController();
      controller.model.isPlaying = false;
      controller.setVelocityVectors(true);
      expect(controller.velocityTipsInteractive, isTrue);

      final mvt = ClMvt.forPlayArea(controller.model.playArea);
      // Drag tip to model velocity (1.5, -0.8)
      final desired = const ClVec(1.5, -0.8);
      final viewDelta = mvt.modelToViewDelta(desired);
      final mapped = mvt.viewToModelDelta(viewDelta);
      expect(mapped.x, closeTo(desired.x, 1e-9));
      expect(mapped.y, closeTo(desired.y, 1e-9));

      controller.beginVelocityTipDrag(0);
      controller.dragVelocityTip(0, desired);
      final ball = controller.model.ballSystem.balls[0];
      expect(ball.velocity.x, closeTo(1.5, 1e-9));
      expect(ball.velocity.y, closeTo(-0.8, 1e-9));
      // Position unchanged
      final posBefore = ball.position;
      controller.endVelocityTipDrag();
      expect(ball.position, posBefore);
    });

    test('1D tip drag only updates vx', () {
      final controller = IntroController();
      controller.model.isPlaying = false;
      controller.setVelocityVectors(true);
      controller.beginVelocityTipDrag(0);
      controller.dragVelocityTip(0, const ClVec(2.0, 1.5));
      final ball = controller.model.ballSystem.balls[0];
      expect(ball.velocity.x, closeTo(2.0, 1e-9));
      expect(ball.velocity.y, 0);
      controller.endVelocityTipDrag();
    });

    test('clamps to VELOCITY_RANGE', () {
      final controller = Explore2dController();
      controller.model.isPlaying = false;
      controller.setVelocityVectors(true);
      controller.beginVelocityTipDrag(0);
      controller.dragVelocityTip(0, const ClVec(10, -10));
      final ball = controller.model.ballSystem.balls[0];
      expect(ball.velocity.x, CollisionLabConstants.velocityMax);
      expect(ball.velocity.y, CollisionLabConstants.velocityMin);
      controller.endVelocityTipDrag();
    });

    test('rounds to display decimals on end', () {
      final controller = Explore2dController();
      controller.model.isPlaying = false;
      controller.setVelocityVectors(true);
      controller.beginVelocityTipDrag(0);
      controller.dragVelocityTip(0, const ClVec(1.23456, -0.56789));
      controller.endVelocityTipDrag();
      final ball = controller.model.ballSystem.balls[0];
      expect(ball.velocity.x, closeTo(1.23, 1e-9));
      expect(ball.velocity.y, closeTo(-0.57, 1e-9));
    });

    test('tips not interactive while playing', () {
      final controller = IntroController();
      controller.setVelocityVectors(true);
      controller.model.isPlaying = true;
      expect(controller.velocityTipsInteractive, isFalse);
    });

    test('user control pauses and resets elapsed', () {
      final controller = IntroController();
      controller.model.isPlaying = true;
      controller.model.elapsedTime = 1.5;
      controller.setVelocityVectors(true);
      // Force pause for tip visibility path: beginVelocityTipDrag requires !playing
      controller.model.isPlaying = false;
      controller.model.isPlaying = true;
      // Ball drag triggers pause
      controller.dragBall(0, const ClVec(0, 0));
      expect(controller.model.isPlaying, isFalse);
      expect(controller.model.elapsedTime, 0);
      controller.endDrag();
    });
  });

  group('ScaleBar', () {
    test('length is constant 0.5 m for all dimensions', () {
      expect(CollisionLabConstants.scaleBarLengthMeters, 0.5);
      final mvt1 = ClMvt.forPlayArea(PlayArea.intro());
      final mvt2 = ClMvt.forPlayArea(PlayArea.explore2d());
      expect(
        mvt1.modelToViewDeltaX(0.5),
        closeTo(0.5 * CollisionLabConstants.modelToViewScale, 1e-9),
      );
      expect(
        mvt2.modelToViewDeltaX(0.5),
        closeTo(0.5 * CollisionLabConstants.modelToViewScale, 1e-9),
      );
    });

    test('1D horizontal / 2D vertical orientation rule', () {
      expect(PlayArea.intro().dimension, PlayAreaDimension.one);
      expect(PlayArea.explore1d().dimension, PlayAreaDimension.one);
      expect(PlayArea.explore2d().dimension, PlayAreaDimension.two);
      expect(PlayArea.inelastic().dimension, PlayAreaDimension.two);
    });
  });

  group('bump / repel', () {
    test('bumpBallAwayFromOthers separates overlapping balls', () {
      final model = Explore2dModel();
      final b1 = model.ballSystem.balls[0];
      final b2 = model.ballSystem.balls[1];
      // Force concentric overlap
      b1.position = const ClVec(0, 0);
      b2.position = const ClVec(0.01, 0);
      expect(BallUtils.areBallsOverlappingBalls(b1, b2), isTrue);
      model.ballSystem.bumpBallAwayFromOthers(b1);
      expect(BallUtils.areBallsOverlappingBalls(b1, b2), isFalse);
      // Separation ≈ r1+r2
      final sep = (b1.position - b2.position).magnitude;
      expect(sep, closeTo(b1.radius + b2.radius, 1e-6));
    });

    test('repelBalls separates all pairs', () {
      final model = Explore1dModel();
      model.ballSystem.setNumberOfBalls(3);
      final balls = model.ballSystem.balls;
      for (final b in balls) {
        b.position = const ClVec(0, 0);
      }
      model.ballSystem.repelBalls();
      for (var i = 0; i < balls.length; i++) {
        for (var j = i + 1; j < balls.length; j++) {
          expect(
            BallUtils.areBallsOverlappingBalls(balls[i], balls[j]),
            isFalse,
          );
        }
      }
    });

    test('endDrag bumps after position edit', () {
      final controller = Explore2dController();
      final b0 = controller.model.ballSystem.balls[0];
      final b1 = controller.model.ballSystem.balls[1];
      controller.model.isPlaying = false;
      // Drag ball0 onto ball1
      controller.dragBall(0, b1.position);
      expect(BallUtils.areBallsOverlappingBalls(b0, b1), isTrue);
      controller.endDrag();
      expect(BallUtils.areBallsOverlappingBalls(b0, b1), isFalse);
    });
  });

  group('four-screen lifecycle smoke', () {
    test('Intro default / reset', () {
      final c = IntroController();
      expect(c.model.ballSystem.balls.length, 2);
      expect(c.model.playArea.reflectingBorder, isFalse);
      c.model.ballSystem.balls[0].position = const ClVec(0.3, 0);
      c.reset();
      expect(c.model.ballSystem.balls[0].position.x, closeTo(-1, 1e-12));
    });

    test('Explore1D constraint y=0', () {
      final m = Explore1dModel();
      m.ballSystem.balls[0].dragToPosition(const ClVec(0.5, 0.4));
      expect(m.ballSystem.balls[0].position.y, 0);
    });

    test('Explore2D multi-ball + reflecting', () {
      final m = Explore2dModel();
      expect(m.playArea.reflectingBorder, isTrue);
      m.ballSystem.setNumberOfBalls(4);
      expect(m.ballSystem.balls.length, 4);
      m.reset();
      expect(m.ballSystem.balls.length, 2);
    });
  });
}
