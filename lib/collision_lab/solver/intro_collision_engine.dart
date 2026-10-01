import '../model/ball.dart';
import '../model/collision.dart';
import 'collision_engine.dart';

/// Intro engine — registers Δp contact point.
/// `js/intro/model/IntroCollisionEngine.js`
class IntroCollisionEngine extends CollisionEngine {
  IntroCollisionEngine(super.playArea, super.ballSystem);

  /// Last impulse contact (for view / debugging).
  ({Ball ball1, Ball ball2, double? time})? lastImpulseContact;

  @override
  void handleCollision(Collision collision, double dt) {
    assert(collision.body1 is Ball && collision.body2 is Ball);

    final ball1 = collision.body1 as Ball;
    final ball2 = collision.body2 as Ball;
    final prev1 = ball1.momentum;
    final prev2 = ball2.momentum;

    super.handleCollision(collision, dt);

    lastImpulseContact = (ball1: ball1, ball2: ball2, time: collision.time);
    ballSystem.recordMomentumChange(ball1, prev1);
    ballSystem.recordMomentumChange(ball2, prev2);

    if (ballSystem.changeInMomentumVisible) {
      final deltaR = ball2.position - ball1.position;
      final mag = deltaR.magnitude;
      if (mag > 0) {
        final contactPoint = ball1.position + deltaR * (ball1.radius / mag);
        ballSystem.registerChangeInMomentumCollision(
          contactPoint,
          collision.time ?? 0,
        );
      }
    }
  }
}
