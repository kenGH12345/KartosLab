import '../collision_lab_constants.dart';
import '../model/ball.dart';
import '../model/cl_vec.dart';
import '../model/collision.dart';
import '../model/play_area.dart';
import '../model/rotating_ball_cluster.dart';
import 'ball_utils.dart';
import 'collision_engine.dart';

/// Inelastic stick/slip + cluster-border —
/// `js/inelastic/model/InelasticCollisionEngine.js`
class InelasticCollisionEngine extends CollisionEngine {
  InelasticCollisionEngine(super.playArea, super.ballSystem);

  RotatingBallCluster? rotatingBallCluster;

  @override
  void reset() {
    rotatingBallCluster = null;
    super.reset();
  }

  @override
  void progressBalls(double dt, double elapsedTime) {
    final cluster = rotatingBallCluster;
    if (cluster != null) {
      cluster.step(dt);
      ballSystem.updatePaths(elapsedTime + dt);
    } else {
      super.progressBalls(dt, elapsedTime);
    }
  }

  @override
  void detectAllCollisions(double elapsedTime) {
    if (rotatingBallCluster != null) {
      detectBallClusterToBorderCollision(elapsedTime);
    } else {
      super.detectAllCollisions(elapsedTime);
    }
  }

  @override
  void handleCollision(Collision collision, double dt) {
    final cluster = rotatingBallCluster;
    if (cluster != null && collision.includes(cluster)) {
      handleBallClusterToBorderCollision();
    } else {
      super.handleCollision(collision, dt);
    }
  }

  @override
  void handleBallToBallCollision(Ball ball1, Ball ball2, double dt) {
    super.handleBallToBallCollision(ball1, ball2, dt);

    if (playArea.inelasticCollisionType == InelasticCollisionType.stick) {
      final comPos = ballSystem.centerOfMass.position;
      final i1 =
          (ball1.position - comPos).magnitudeSquared * ball1.mass;
      final i2 =
          (ball2.position - comPos).magnitudeSquared * ball2.mass;
      final angularVelocity =
          ballSystem.getTotalAngularMomentum() / (i1 + i2);

      rotatingBallCluster = RotatingBallCluster(
        balls: List<Ball>.from(ballSystem.balls),
        angularVelocity: angularVelocity,
        centerOfMass: ballSystem.centerOfMass,
      );
    }
  }

  @override
  void handleBallToBorderCollision(Ball ball, double dt) {
    super.handleBallToBorderCollision(ball, dt);

    if (playArea.inelasticCollisionType == InelasticCollisionType.stick) {
      ball.velocity = ClVec.zero;
    }
  }

  void detectBallClusterToBorderCollision(double elapsedTime) {
    final cluster = rotatingBallCluster;
    if (cluster == null) return;
    if (!playArea.reflectingBorder) return;

    for (final c in collisions) {
      if (c.includes(cluster)) return;
    }

    for (final ball in cluster.balls) {
      if (playArea.isBallTouchingSide(ball)) {
        collisions.add(Collision(cluster, playArea, elapsedTime));
        return;
      }
    }

    for (final ball in cluster.balls) {
      if (!playArea.fullyContainsBall(ball)) {
        return;
      }
    }

    final minCollisionTime = getBorderCollisionTime(
      ballSystem.centerOfMass.position,
      ballSystem.centerOfMass.velocity,
      cluster.getBoundingCircleRadius(),
      elapsedTime,
    );
    final maxCollisionTime = getBorderCollisionTime(
      ballSystem.centerOfMass.position,
      ballSystem.centerOfMass.velocity,
      0,
      elapsedTime,
    );

    double? collisionTime;
    if (minCollisionTime != null &&
        maxCollisionTime != null &&
        minCollisionTime.isFinite &&
        maxCollisionTime.isFinite) {
      collisionTime = CollisionLabUtils.bisection(
        (time) => willBallClusterCollideWithBorderIn(time - elapsedTime),
        minCollisionTime,
        maxCollisionTime,
      );
    }

    collisions.add(Collision(cluster, playArea, collisionTime));
  }

  /// -1 underestimate, 0 close enough, 1 overestimate.
  int willBallClusterCollideWithBorderIn(double dt) {
    final cluster = rotatingBallCluster!;
    final rotationStates = cluster.getSteppedRotationStates(dt);

    var overlapping = 0;
    var touching = 0;
    const tol = CollisionLabConstants.zeroThreshold;

    for (final ball in cluster.balls) {
      final radius = ball.radius;
      final position = rotationStates[ball]!.position;
      final left = position.x - radius;
      final right = position.x + radius;
      final top = position.y + radius;
      final bottom = position.y - radius;

      if (left < playArea.left ||
          right > playArea.right ||
          bottom < playArea.bottom ||
          top > playArea.top) {
        overlapping += 1;
      } else if ((left - playArea.left).abs() < tol ||
          (right - playArea.right).abs() < tol ||
          (top - playArea.top).abs() < tol ||
          (bottom - playArea.bottom).abs() < tol) {
        touching += 1;
      }
    }

    if (overlapping > 0) return 1;
    if (touching > 0) return 0;
    return -1;
  }

  void handleBallClusterToBorderCollision() {
    final cluster = rotatingBallCluster;
    if (cluster == null) return;

    for (final ball in cluster.balls) {
      ball.velocity = ClVec.zero;
    }
    invalidateCollisions(cluster);
    rotatingBallCluster = null;
  }
}
