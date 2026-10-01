import '../model/ball.dart';
import '../model/ball_system.dart';
import '../model/cl_vec.dart';
import '../model/collision.dart';
import '../model/play_area.dart';
import 'ball_utils.dart';

/// Full collision detection/response — `js/common/model/CollisionEngine.js`
class CollisionEngine {
  CollisionEngine(this.playArea, this.ballSystem);

  final PlayArea playArea;
  final BallSystem ballSystem;

  final List<Collision> collisions = [];
  final List<Collision> nextCollisions = [];

  /// 1 = forward time-step, -1 = backward.
  int timeStepDirection = 1;

  void reset() {
    collisions.clear();
  }

  void step(double dt, double elapsedTime, {int maxIterations = 2000}) {
    var remainingDt = dt;
    var time = elapsedTime;
    var iterations = 0;

    while (iterations++ < maxIterations) {
      timeStepDirection = remainingDt.sign == 0 ? 1 : remainingDt.sign.toInt();
      detectAllCollisions(time);

      nextCollisions.clear();
      var bestPotentialCollisionTime = time + remainingDt * (1 + 1e-7);

      for (var i = collisions.length - 1; i >= 0; i--) {
        final collision = collisions[i];
        if (collision.inRange(time, bestPotentialCollisionTime)) {
          if (collision.time != bestPotentialCollisionTime) {
            bestPotentialCollisionTime = collision.time!;
            nextCollisions.clear();
          }
          nextCollisions.add(collision);
        }
      }

      if (nextCollisions.isEmpty) {
        progressBalls(remainingDt, time);
        break;
      }

      final collisionTime =
          bestPotentialCollisionTime < 0 ? 0.0 : bestPotentialCollisionTime;
      final timeUntilCollision = collisionTime - time;

      progressBalls(timeUntilCollision, time);

      for (var i = nextCollisions.length - 1; i >= 0; i--) {
        handleCollision(nextCollisions[i], remainingDt);
      }

      remainingDt -= timeUntilCollision;
      time = collisionTime;
    }
  }

  bool hasCollisionBetween(Object body1, Object body2) {
    for (var i = collisions.length - 1; i >= 0; i--) {
      if (collisions[i].includesBodies(body1, body2)) return true;
    }
    return false;
  }

  void progressBalls(double dt, double elapsedTime) {
    ballSystem.stepUniformMotion(dt, elapsedTime + dt);
  }

  void detectAllCollisions(double elapsedTime) {
    detectBallToBallCollisions(elapsedTime);
    detectBallToBorderCollisions(elapsedTime);
  }

  void handleCollision(Collision collision, double dt) {
    if (collision.includes(playArea)) {
      final ball = identical(collision.body2, playArea)
          ? collision.body1 as Ball
          : collision.body2 as Ball;
      handleBallToBorderCollision(ball, dt);
    } else {
      handleBallToBallCollision(
        collision.body1 as Ball,
        collision.body2 as Ball,
        dt,
      );
    }
  }

  void invalidateCollisions(Object body) {
    collisions.removeWhere((c) => c.includes(body));
  }

  void detectBallToBallCollisions(double elapsedTime) {
    final balls = ballSystem.balls;
    for (var i = 1; i < balls.length; i++) {
      final ball1 = balls[i];
      for (var j = 0; j < i; j++) {
        final ball2 = balls[j];
        if (hasCollisionBetween(ball1, ball2)) continue;

        final velocityMultiplier = timeStepDirection.toDouble();
        final deltaR = ball2.position - ball1.position;
        final deltaV = (ball2.velocity - ball1.velocity) * velocityMultiplier;
        final sumOfRadiiSquared = (ball1.radius + ball2.radius) *
            (ball1.radius + ball2.radius);

        final relativeDotProduct = deltaV.dot(deltaR);
        final isEffectivelyParallel = relativeDotProduct.abs() < 1e-11;

        final possibleRoots = CollisionLabUtils.solveQuadraticRootsReal(
          deltaV.magnitudeSquared,
          relativeDotProduct * 2,
          CollisionLabUtils.clampDown(
            deltaR.magnitudeSquared - sumOfRadiiSquared,
          ),
        );

        final root = possibleRoots.isEmpty
            ? null
            : possibleRoots.reduce((a, b) => a < b ? a : b);

        final collisionTime =
            (root != null && root.isFinite && root >= 0 && !isEffectivelyParallel)
                ? elapsedTime + root * velocityMultiplier
                : null;

        collisions.add(Collision(ball1, ball2, collisionTime));
      }
    }
  }

  void handleBallToBallCollision(Ball ball1, Ball ball2, double dt) {
    final m1 = ball1.mass;
    final m2 = ball2.mass;
    var elasticity = playArea.getElasticity();

    assert(dt >= 0 || elasticity > 0, 'Cannot step backwards with zero elasticity');

    if (dt < 0) {
      elasticity = 1 / elasticity;
    }

    final normal = (ball2.position - ball1.position).normalized();
    final tangent = ClVec(-normal.y, normal.x);

    final v1n = ball1.velocity.dot(normal);
    final v2n = ball2.velocity.dot(normal);
    final v1t = ball1.velocity.dot(tangent);
    final v2t = ball2.velocity.dot(tangent);

    var v1nP =
        ((m1 - m2 * elasticity) * v1n + m2 * (1 + elasticity) * v2n) / (m1 + m2);
    var v2nP =
        ((m2 - m1 * elasticity) * v2n + m1 * (1 + elasticity) * v1n) / (m1 + m2);

    if (v1nP.abs() < 1e-8) v1nP = 0;
    if (v2nP.abs() < 1e-8) v2nP = 0;

    // Coordinate frame restore matching CollisionEngine.js tangent.dotXY / normal.dotXY
    final v1xP = tangent.x * v1t + tangent.y * v1nP;
    final v2xP = tangent.x * v2t + tangent.y * v2nP;
    final v1yP = normal.x * v1t + normal.y * v1nP;
    final v2yP = normal.x * v2t + normal.y * v2nP;

    ball1.velocity = ClVec(v1xP, v1yP);
    ball2.velocity = ClVec(v2xP, v2yP);

    invalidateCollisions(ball1);
    invalidateCollisions(ball2);
  }

  void detectBallToBorderCollisions(double elapsedTime) {
    if (!playArea.reflectingBorder) return;

    for (var i = ballSystem.balls.length - 1; i >= 0; i--) {
      final ball = ballSystem.balls[i];
      if (hasCollisionBetween(ball, playArea)) continue;

      final collisionTime = getBorderCollisionTime(
        ball.position,
        ball.velocity,
        ball.radius,
        elapsedTime,
      );
      collisions.add(Collision(ball, playArea, collisionTime));
    }
  }

  double? getBorderCollisionTime(
    ClVec position,
    ClVec velocity,
    double radius,
    double elapsedTime,
  ) {
    final velocityMultiplier = timeStepDirection.toDouble();

    final left = position.x - radius;
    final right = position.x + radius;
    final top = position.y + radius;
    final bottom = position.y - radius;
    final xVelocity = velocity.x * velocityMultiplier;
    final yVelocity = velocity.y * velocityMultiplier;

    final leftCollisionTime =
        CollisionLabUtils.clampDown(playArea.left - left) / xVelocity;
    final rightCollisionTime =
        CollisionLabUtils.clampDown(playArea.right - right) / xVelocity;
    final bottomCollisionTime =
        CollisionLabUtils.clampDown(playArea.bottom - bottom) / yVelocity;
    final topCollisionTime =
        CollisionLabUtils.clampDown(playArea.top - top) / yVelocity;

    final horizontalCollisionTime =
        leftCollisionTime > rightCollisionTime
            ? leftCollisionTime
            : rightCollisionTime;
    final verticalCollisionTime =
        bottomCollisionTime > topCollisionTime
            ? bottomCollisionTime
            : topCollisionTime;

    final possible = <double>[
      if (horizontalCollisionTime.isFinite) horizontalCollisionTime,
      if (verticalCollisionTime.isFinite) verticalCollisionTime,
    ];

    if (possible.isEmpty) return null;

    final timeUntilCollision =
        possible.reduce((a, b) => a < b ? a : b) * velocityMultiplier;
    return elapsedTime + timeUntilCollision;
  }

  void handleBallToBorderCollision(Ball ball, double dt) {
    final velocityMultiplier = timeStepDirection.toDouble();
    var elasticity = playArea.getElasticity();

    assert(dt >= 0 || elasticity > 0, 'Cannot step backwards with zero elasticity');

    if (dt < 0) {
      elasticity = 1 / elasticity;
    }

    if ((playArea.isBallTouchingLeft(ball) &&
            ball.velocity.x * velocityMultiplier < 0) ||
        (playArea.isBallTouchingRight(ball) &&
            ball.velocity.x * velocityMultiplier > 0)) {
      ball.setXVelocity(-ball.velocity.x * elasticity);
    }
    if ((playArea.isBallTouchingBottom(ball) &&
            ball.velocity.y * velocityMultiplier < 0) ||
        (playArea.isBallTouchingTop(ball) &&
            ball.velocity.y * velocityMultiplier > 0)) {
      ball.setYVelocity(-ball.velocity.y * elasticity);
    }

    invalidateCollisions(ball);
  }
}
