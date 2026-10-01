import 'dart:math' as math;

import '../collision_lab_constants.dart';
import '../model/ball.dart';
import '../model/cl_vec.dart';

/// `js/common/model/BallUtils.js`
class BallUtils {
  BallUtils._();

  /// Radius from mass + constant-size flag.
  static double calculateBallRadius(double mass, {bool isConstantSize = false}) {
    if (isConstantSize) return CollisionLabConstants.ballConstantRadius;
    return math.pow(
      3 / 4 * mass / CollisionLabConstants.ballDefaultDensity / math.pi,
      1 / 3,
    ).toDouble();
  }

  static ClBounds getBallGridSafeConstrainedBounds(
    ClBounds playAreaBounds,
    double radius, {
    double gridLineSpacing = CollisionLabConstants.minorGridlineSpacing,
  }) {
    final constrained = playAreaBounds.eroded(radius);
    return CollisionLabUtils.roundBoundsInToNearest(constrained, gridLineSpacing);
  }

  /// Overlap is strict `<` (tangent does NOT count) — BallUtils.js
  static bool areBallsOverlappingBalls(Ball ball1, Ball ball2) {
    assert(!identical(ball1, ball2));
    return (ball1.position - ball2.position).magnitude <
        ball1.radius + ball2.radius;
  }

  static bool areBallsOverlapping(
    ClVec p1,
    double r1,
    ClVec p2,
    double r2,
  ) {
    return (p1 - p2).magnitude < r1 + r2;
  }

  /// Closest overlapping ball, or null.
  static Ball? getClosestOverlappingBall(Ball ball, List<Ball> balls) {
    Ball? closest;
    var best = double.infinity;
    for (final other in balls) {
      if (identical(other, ball)) continue;
      if (!areBallsOverlappingBalls(ball, other)) continue;
      final d = (ball.position - other.position).magnitude;
      if (d < best) {
        best = d;
        closest = other;
      }
    }
    return closest;
  }

  /// Place [ball1] adjacent to [ball2] along [directionVector] (from ball2 → ball1).
  static void moveBallNextToBall(Ball ball1, Ball ball2, ClVec directionVector) {
    final scaled = directionVector.withMagnitude(
      ball2.radius + ball1.radius + CollisionLabConstants.zeroThreshold,
    );
    ball1.position = ball2.position + scaled;
  }

  static double kineticEnergyOf(Iterable<({double mass, ClVec velocity})> balls) {
    var ke = 0.0;
    for (final b in balls) {
      ke += 0.5 * b.mass * b.velocity.magnitudeSquared;
    }
    return ke;
  }
}

/// `js/common/CollisionLabUtils.js` (subset)
class CollisionLabUtils {
  CollisionLabUtils._();

  /// If `|value| < threshold`, round to 0; otherwise return `value`.
  static double clampDown(
    double value, [
    double threshold = CollisionLabConstants.zeroThreshold,
  ]) {
    return value.abs() < threshold ? 0.0 : value;
  }

  /// Bisection where [f] returns -1 (under), 0 (close enough), 1 (over).
  static double bisection(
    int Function(double value) f,
    double min,
    double max, {
    int maxIterations = 100,
  }) {
    for (var i = 0; i < maxIterations; i++) {
      final midpoint = (min + max) / 2;
      final result = f(midpoint);
      if (result == 1) {
        max = midpoint;
      } else if (result == 0) {
        return midpoint;
      } else {
        min = midpoint;
      }
    }
    return (min + max) / 2;
  }

  static void forEachAdjacentPair<T>(
    List<T> collection,
    void Function(T current, T previous) iterator,
  ) {
    for (var i = 1; i < collection.length; i++) {
      iterator(collection[i], collection[i - 1]);
    }
  }

  static ClBounds roundBoundsInToNearest(ClBounds bounds, double multiple) {
    return ClBounds(
      minX: (bounds.minX / multiple).ceilToDouble() * multiple,
      minY: (bounds.minY / multiple).ceilToDouble() * multiple,
      maxX: (bounds.maxX / multiple).floorToDouble() * multiple,
      maxY: (bounds.maxY / multiple).floorToDouble() * multiple,
    );
  }

  static ClVec roundVectorToNearest(ClVec vector, double multiple) {
    return vector.roundSymmetricScaled(multiple);
  }

  /// Rounds magnitude upward to nearest multiple — CollisionLabUtils.js
  static ClVec roundUpVectorToNearest(ClVec vector, double multiple) {
    final mag = vector.magnitude;
    if (mag == 0) return ClVec.zero;
    final newMag = (mag / multiple).ceilToDouble() * multiple;
    var result = vector.withMagnitude(newMag);
    if (result.y.abs() < CollisionLabConstants.zeroThreshold) {
      result = result.withY(0);
    }
    return result;
  }

  static List<double> solveQuadraticRootsReal(double a, double b, double c) {
    if (a.abs() < 1e-16) {
      if (b.abs() < 1e-16) return const [];
      return [-c / b];
    }
    final disc = b * b - 4 * a * c;
    if (disc < 0) return const [];
    if (disc == 0) return [-b / (2 * a)];
    final s = math.sqrt(disc);
    final r1 = (-b - s) / (2 * a);
    final r2 = (-b + s) / (2 * a);
    return r1 < r2 ? [r1, r2] : [r2, r1];
  }

  static void forEachPossiblePair<T>(
    List<T> collection,
    void Function(T a, T b) iterator,
  ) {
    for (var i = 0; i < collection.length - 1; i++) {
      for (var j = i + 1; j < collection.length; j++) {
        iterator(collection[i], collection[j]);
      }
    }
  }
}
