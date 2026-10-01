import '../domain/force/force2.dart';
import '../domain/fluid/buoyancy_pool.dart';
import '../domain/mass/buoyancy_mass.dart';
import '../domain/shape/shape_geometry.dart';
import '../domain/world/vec2.dart';
import 'constants.dart';

/// Inelastic walls / floor / mass–mass stacking. Restitution 0 (`p2Restitution`).
class CollisionResolver {
  CollisionResolver({
    this.barrierMinX = -0.875,
    this.barrierMaxX = 0.875,
    this.barrierMinY = -4,
    this.barrierMaxY = 4,
  });

  final double barrierMinX;
  final double barrierMaxX;
  final double barrierMinY;
  final double barrierMaxY;

  void resolve(BuoyancyMass mass, BuoyancyPool pool) {
    if (!mass.visible) {
      return;
    }

    final halfW = halfWidth(mass);
    final halfH = mass.geometry.halfHeight;
    var x = mass.position.x;
    var y = mass.position.y;
    var vx = mass.velocity.x;
    var vy = mass.velocity.y;
    var contactY = 0.0;

    final insidePoolX = x + halfW > pool.minX && x - halfW < pool.maxX;
    final groundY = insidePoolX ? pool.minY : 0.0;
    final minCenterY = groundY + halfH;
    if (y < minCenterY) {
      final penetration = minCenterY - y;
      contactY = penetration * mass.mass /
          (BuoyancyPhysicsConstants.fixedTimeStep *
              BuoyancyPhysicsConstants.fixedTimeStep);
      y = minCenterY;
      if (vy < 0) {
        vy = 0;
      }
    }

    if (y - halfH < 0) {
      final minCenterX = pool.minX + halfW;
      final maxCenterX = pool.maxX - halfW;
      if (x < minCenterX) {
        x = minCenterX;
        if (vx < 0) {
          vx = 0;
        }
      } else if (x > maxCenterX) {
        x = maxCenterX;
        if (vx > 0) {
          vx = 0;
        }
      }
    }

    if (x - halfW < barrierMinX) {
      x = barrierMinX + halfW;
      if (vx < 0) {
        vx = 0;
      }
    } else if (x + halfW > barrierMaxX) {
      x = barrierMaxX - halfW;
      if (vx > 0) {
        vx = 0;
      }
    }
    if (y - halfH < barrierMinY) {
      y = barrierMinY + halfH;
      if (vy < 0) {
        vy = 0;
      }
    } else if (y + halfH > barrierMaxY) {
      y = barrierMaxY - halfH;
      if (vy > 0) {
        vy = 0;
      }
    }

    if (y + halfH < pool.minY) {
      y = pool.minY + halfH + 0.1;
      vy = 0;
    }

    mass.position = BVec2(x, y);
    mass.velocity = BVec2(vx, vy);
    mass.contactForce = Force2(BVec2(0, contactY));
  }

  /// AABB stacking between visible masses (blocks + scales). Inelastic.
  void resolvePairs(List<BuoyancyMass> masses) {
    final list = masses.where((m) => m.visible).toList(growable: false);
    for (var i = 0; i < list.length; i++) {
      for (var j = i + 1; j < list.length; j++) {
        _separatePair(list[i], list[j]);
      }
    }
  }

  void _separatePair(BuoyancyMass a, BuoyancyMass b) {
    final aw = halfWidth(a);
    final bw = halfWidth(b);
    final ah = a.geometry.halfHeight;
    final bh = b.geometry.halfHeight;

    final dx = b.position.x - a.position.x;
    final dy = b.position.y - a.position.y;
    final overlapX = aw + bw - dx.abs();
    final overlapY = ah + bh - dy.abs();
    if (overlapX <= 0 || overlapY <= 0) {
      return;
    }

    if (overlapY <= overlapX) {
      if (dy > 0) {
        _landOn(lower: a, upper: b, overlapY: overlapY);
      } else {
        _landOn(lower: b, upper: a, overlapY: overlapY);
      }
      return;
    }

    final push = overlapX / 2;
    if (a.canMove && b.canMove) {
      final sx = dx >= 0 ? -push : push;
      a.position = BVec2(a.position.x + sx, a.position.y);
      b.position = BVec2(b.position.x - sx, b.position.y);
      a.velocity = BVec2(0, a.velocity.y);
      b.velocity = BVec2(0, b.velocity.y);
    } else if (a.canMove) {
      a.position = BVec2(
        a.position.x + (dx >= 0 ? -overlapX : overlapX),
        a.position.y,
      );
      a.velocity = BVec2(0, a.velocity.y);
    } else if (b.canMove) {
      b.position = BVec2(
        b.position.x + (dx >= 0 ? overlapX : -overlapX),
        b.position.y,
      );
      b.velocity = BVec2(0, b.velocity.y);
    }
  }

  void _landOn({
    required BuoyancyMass lower,
    required BuoyancyMass upper,
    required double overlapY,
  }) {
    if (!upper.canMove && lower.canMove) {
      lower.position = BVec2(lower.position.x, lower.position.y - overlapY);
      if (lower.velocity.y > 0) {
        lower.velocity = BVec2(lower.velocity.x, 0);
      }
      return;
    }
    if (!upper.canMove) {
      return;
    }
    final support =
        lower.position.y + lower.geometry.halfHeight + upper.geometry.halfHeight;
    upper.position = BVec2(upper.position.x, support);
    if (upper.velocity.y < 0) {
      upper.velocity = BVec2(upper.velocity.x, 0);
    }
    if (lower.id.startsWith('scale.')) {
      lower.contactForce = Force2(BVec2(0, upper.mass * 9.8));
    }
  }

  static double halfWidth(BuoyancyMass mass) {
    switch (mass.geometry.kind) {
      case MassShapeKind.verticalCylinder:
      case MassShapeKind.cone:
      case MassShapeKind.invertedCone:
        return mass.geometry.radius;
      case MassShapeKind.horizontalCylinder:
        return mass.geometry.length / 2;
      case MassShapeKind.block:
      case MassShapeKind.ellipsoid:
      case MassShapeKind.duck:
      case MassShapeKind.boat:
      case MassShapeKind.bottle:
        return mass.geometry.width > 0
            ? mass.geometry.width / 2
            : mass.geometry.halfHeight;
    }
  }
}
