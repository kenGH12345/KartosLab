import 'dart:math' as math;

import 'bond.dart';
import 'vec3.dart';

/// One VSEPR pair group: either an atom or a lone pair.
///
/// A double or triple bond is still one group. See `Bond.order`.
class PairGroup {
  PairGroup({
    required Vec3 position,
    required this.isLonePair,
    this.element,
  }) : _position = position {
    _updateOrientation();
  }

  static int _nextId = 0;

  /// `PairGroup.BONDED_PAIR_DISTANCE` on the model screen.
  static const bondedPairDistance = 10.0;

  /// `PairGroup.LONE_PAIR_DISTANCE`.
  static const lonePairDistance = 7.0;

  static const electronPairRepulsionScale = 30000.0;
  static const angleRepulsionScale = 3.0;
  static const dampingFactor = 0.1;

  final int id = _nextId++;
  final bool isLonePair;

  /// Element symbol for real molecules. Null on the generic model screen.
  final String? element;

  bool isCentralAtom = false;
  bool userControlled = false;
  Vec3 velocity = Vec3.zero;
  Vec3 orientation = Vec3.zero;

  Vec3 _position;

  Vec3 get position => _position;

  set position(Vec3 value) {
    _position = value;
    _updateOrientation();
  }

  void _updateOrientation() {
    final m = _position.magnitude;
    orientation = m > 0 ? _position.times(1 / m) : Vec3.zero;
  }

  /// `PairGroup.dragToPosition`: write position and clear velocity.
  void dragToPosition(Vec3 vector) {
    position = vector;
    velocity = Vec3.zero;
  }

  void addPosition(Vec3 change) {
    if (!userControlled && !isCentralAtom) {
      position = position.plus(change);
    }
  }

  void addVelocity(Vec3 change) {
    if (!userControlled && !isCentralAtom) {
      velocity = velocity.plus(change);
    }
  }

  void attractToIdealDistance(double dt, double oldDistance, Bond bond) {
    if (userControlled) {
      return;
    }
    final origin = bond.other(this).position;
    final isTerminalLonePair = !origin.almostEquals(Vec3.zero);
    final ideal = bond.length;
    final currentError = (position.minus(origin).magnitude - ideal).abs();
    final oldError = (oldDistance - ideal).abs();
    if (currentError > oldError) {
      position = orientation.times(oldDistance).plus(origin);
    }
    final toCenter = position.minus(origin);
    final distance = toCenter.magnitude;
    if (distance != 0) {
      final direction = toCenter.normalized();
      final offset = ideal - distance;
      var ratio = math.min(0.1 * dt / 0.016, 1.0);
      if (isTerminalLonePair) {
        ratio = 1;
      }
      position = position.plus(direction.times(ratio * offset));
    }
  }

  Vec3 repulsionImpulse(PairGroup other, double dt, double trueLengthsRatioOverride) {
    if (position.almostEquals(other.position, 1e-6)) {
      return Vec3.zero;
    }
    final adjustedMagnitude = _lerp(
      bondedPairDistance,
      position.magnitude,
      trueLengthsRatioOverride,
    );
    final adjustedOtherMagnitude = _lerp(
      bondedPairDistance,
      other.position.magnitude,
      trueLengthsRatioOverride,
    );
    final adjustedPosition = orientation.times(adjustedMagnitude);
    final adjustedOther = other.position.magnitude == 0
        ? Vec3.zero
        : other.orientation.times(adjustedOtherMagnitude);
    final delta = adjustedPosition.minus(adjustedOther);
    final coulomb = delta.withMagnitude(
      dt * electronPairRepulsionScale / (delta.magnitude * delta.magnitude),
    );
    return coulomb.times(timescaleImpulseFactor(dt));
  }

  void repulseFrom(PairGroup other, double dt, double trueLengthsRatioOverride) {
    addVelocity(repulsionImpulse(other, dt, trueLengthsRatioOverride));
  }

  void stepForward(double dt) {
    if (userControlled) {
      return;
    }
    final outward = velocity.dot(orientation);
    if (position.magnitude > 0) {
      velocity = velocity.minus(orientation.times(outward));
    }
    position = position.plus(velocity.times(dt));
    var damping = 1 - dampingFactor;
    damping = math.pow(damping, dt / 0.017).toDouble();
    velocity = velocity.times(damping);
  }

  static double timescaleImpulseFactor(double dt) =>
      math.sqrt(dt > 0.017 ? 0.017 / dt : 1);

  static double _lerp(double a, double b, double ratio) => a * (1 - ratio) + b * ratio;
}
