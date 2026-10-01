import 'dart:math' as math;

import 'ball.dart';
import 'ball_state.dart';
import 'center_of_mass.dart';
import 'cl_vec.dart';

/// Stuck cluster rotating about COM — `js/inelastic/model/RotatingBallCluster.js`
class RotatingBallCluster {
  RotatingBallCluster({
    required this.balls,
    required this.angularVelocity,
    required this.centerOfMass,
  });

  final List<Ball> balls;
  final double angularVelocity;
  final CenterOfMass centerOfMass;

  double getBoundingCircleRadius() {
    var maxR = 0.0;
    final com = centerOfMass.position;
    for (final ball in balls) {
      final r = (ball.position - com).magnitude + ball.radius;
      if (r > maxR) maxR = r;
    }
    return maxR;
  }

  void step(double dt) {
    final changeInAngle = angularVelocity * dt;
    final states = getSteppedRotationStates(dt);
    for (final ball in balls) {
      ball.setState(states[ball]!);
      ball.rotation += changeInAngle;
    }
  }

  /// Ball → state after rotating for [dt] seconds about the COM.
  Map<Ball, BallState> getSteppedRotationStates(double dt) {
    final changeInAngle = angularVelocity * dt;
    final comPos = centerOfMass.position;
    final comVel = centerOfMass.velocity;
    final centerOfMassPosition = comPos + comVel * dt;

    final result = <Ball, BallState>{};
    for (final ball in balls) {
      var position = ball.position - comPos;
      position = _rotate(position, changeInAngle);
      final velocity = ClVec(
            -angularVelocity * position.y,
            angularVelocity * position.x,
          ) +
          comVel;
      result[ball] = BallState(
        position: position + centerOfMassPosition,
        velocity: velocity,
        mass: ball.mass,
      );
    }
    return result;
  }

  static ClVec _rotate(ClVec v, double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return ClVec(c * v.x - s * v.y, s * v.x + c * v.y);
  }
}
