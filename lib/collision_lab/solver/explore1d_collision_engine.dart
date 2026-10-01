import '../model/ball.dart';
import '../model/cl_vec.dart';
import 'collision_engine.dart';

/// Explore1D e=0 grouping — `js/explore1D/model/Explore1DCollisionEngine.js`
class Explore1dCollisionEngine extends CollisionEngine {
  Explore1dCollisionEngine(super.playArea, super.ballSystem);

  List<Ball> findGroupedBalls(List<Ball> seeds) {
    final result = ballSystem.balls.where((ball) {
      return seeds.any((referenceBall) {
        if (identical(ball, referenceBall)) return true;
        final positionDifference =
            (ball.position.x - referenceBall.position.x).abs();
        final velocityDifference =
            (ball.velocity.x - referenceBall.velocity.x).abs();
        final separation = (positionDifference -
                ball.radius -
                referenceBall.radius)
            .abs();
        return velocityDifference < 1e-10 && separation < 1e-7;
      });
    }).toList();

    if (result.length > seeds.length) {
      return findGroupedBalls(result);
    }
    return result;
  }

  @override
  void handleBallToBallCollision(Ball ball1, Ball ball2, double dt) {
    if (playArea.elasticityPercent == 0) {
      final grouped = findGroupedBalls([ball1, ball2]);
      var totalMomentum = 0.0;
      var totalMass = 0.0;
      for (final ball in grouped) {
        totalMomentum += ball.momentum.x;
        totalMass += ball.mass;
      }
      final vx = totalMomentum / totalMass;
      for (final ball in grouped) {
        ball.velocity = ClVec(vx, 0);
        invalidateCollisions(ball);
      }
    } else {
      super.handleBallToBallCollision(ball1, ball2, dt);
    }
  }

  @override
  void handleBallToBorderCollision(Ball ball, double dt) {
    if (playArea.elasticityPercent == 0) {
      final grouped = findGroupedBalls([ball]);
      for (final b in grouped) {
        b.velocity = ClVec.zero;
        invalidateCollisions(b);
      }
    } else {
      super.handleBallToBorderCollision(ball, dt);
    }
  }
}
