import 'dart:math' as math;

import 'atom.dart';
import 'rs_geometry.dart';

/// Alpha particle — port of PhET AlphaParticle.ts
class AlphaParticle {
  AlphaParticle({
    required this.speed,
    required this.defaultSpeed,
    required this.position,
    this.orientation = math.pi / 2,
  }) : initialSpeed = speed {
    positions.add(RsVec2(position.x, position.y));
  }

  double speed;
  double defaultSpeed;
  final double initialSpeed;
  RsVec2 position;
  double orientation;

  /// Trace history (every position set appends).
  final List<RsVec2> positions = <RsVec2>[];

  RsVec2 initialPosition = RsVec2.zero;

  Atom? atom;
  Atom? preparedAtom;
  RsRotatedRect? boundingBox;
  double rotationAngle = 0;
  double? preparedRotationAngle;
  bool isInSpace = true;
  RsRotatedRect? preparedBoundingBox;

  void setPosition(RsVec2 p) {
    position = p;
    positions.add(RsVec2(p.x, p.y));
  }

  /// Unit direction from latest positions (or orientation).
  RsVec2 getDirection() {
    if (positions.length < 2) {
      return RsVec2(math.cos(orientation), math.sin(orientation)).normalized;
    }
    final p1 = positions[positions.length - 2];
    final p2 = positions[positions.length - 1];
    return RsVec2(p2.x - p1.x, p2.y - p1.y).normalized;
  }

  /// Prepare rotated bounding box when entering atom's bounding circle.
  void prepareBoundingBox(Atom atom) {
    final direction = getDirection();
    final perpendicular = direction.perpendicular;
    final rotationAngle = perpendicular.angle;
    preparedRotationAngle = rotationAngle;

    preparedBoundingBox = RsRotatedRect(
      pivot: atom.position,
      halfWidth: atom.boundingWidth / 2,
      angle: rotationAngle,
    );
  }
}
