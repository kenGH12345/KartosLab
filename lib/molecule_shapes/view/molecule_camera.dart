import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../model/vec3.dart';

/// Perspective projection matching `MoleculeShapesScreenView` camera defaults.
class MoleculeCamera {
  const MoleculeCamera({
    this.position = const Vec3(6, -1.25, 40),
    this.fovDegrees = 50,
    this.near = 1,
    this.far = 100,
  });

  final Vec3 position;
  final double fovDegrees;
  final double near;
  final double far;

  /// Model point → screen pixel. Y is Flutter-down.
  Offset project(Vec3 world, Size size) {
    final view = world.minus(position);
    // Camera looks toward origin: -position direction ≈ -Z in our tuned frame.
    // Build a look-at basis: forward = -position.normalized(), up ≈ Y.
    final forward = position.negated().normalized();
    var up = const Vec3(0, 1, 0);
    if (forward.cross(up).magnitude < 1e-6) {
      up = const Vec3(0, 0, 1);
    }
    final right = forward.cross(up).normalized();
    up = right.cross(forward).normalized();

    final camX = view.dot(right);
    final camY = view.dot(up);
    final camZ = view.dot(forward); // positive in front of camera

    final aspect = size.width / size.height;
    final tanHalf = math.tan(fovDegrees * math.pi / 360);
    final ndcX = camX / (camZ * tanHalf * aspect);
    final ndcY = camY / (camZ * tanHalf);
    return Offset(
      (ndcX + 1) * 0.5 * size.width,
      (1 - ndcY) * 0.5 * size.height,
    );
  }

  /// Camera-space depth (larger = farther from camera / behind). Used for painter order.
  double depth(Vec3 world) {
    final forward = position.negated().normalized();
    return world.minus(position).dot(forward);
  }

  /// Approximate pixels-per-model-unit at [world] for sphere radii.
  double scaleAt(Vec3 world, Size size) {
    final depth = this.depth(world).abs().clamp(near, far);
    final tanHalf = math.tan(fovDegrees * math.pi / 360);
    return size.height / (2 * depth * tanHalf);
  }

  /// Ray from camera through a screen point, in world space.
  ({Vec3 origin, Vec3 direction}) rayThrough(Offset screen, Size size) {
    final aspect = size.width / size.height;
    final tanHalf = math.tan(fovDegrees * math.pi / 360);
    final ndcX = screen.dx / size.width * 2 - 1;
    final ndcY = 1 - screen.dy / size.height * 2;
    final forward = position.negated().normalized();
    var up = const Vec3(0, 1, 0);
    if (forward.cross(up).magnitude < 1e-6) {
      up = const Vec3(0, 0, 1);
    }
    final right = forward.cross(up).normalized();
    up = right.cross(forward).normalized();
    final direction = forward
        .plus(right.times(ndcX * tanHalf * aspect))
        .plus(up.times(ndcY * tanHalf))
        .normalized();
    return (origin: position, direction: direction);
  }

  /// Intersect ray with sphere radius [radius] at origin (model local, before quat).
  /// Returns local-space hit closest to [preferred], or tangent estimate.
  Vec3? hitSphereLocal({
    required Offset screen,
    required Size size,
    required Quat quaternion,
    required double radius,
    required Vec3 preferred,
  }) {
    final ray = rayThrough(screen, size);
    // Transform ray into molecule local space: inverse rotate (conjugate).
    final inv = Quat(-quaternion.x, -quaternion.y, -quaternion.z, quaternion.w);
    final origin = inv.rotate(ray.origin);
    final direction = inv.rotate(ray.direction).normalized();
    final a = direction.dot(direction);
    final b = 2 * origin.dot(direction);
    final c = origin.dot(origin) - radius * radius;
    final disc = b * b - 4 * a * c;
    if (disc < 0) {
      // Tangent fallback from source when the ray misses the sphere.
      final distance = origin.magnitude;
      if (distance <= radius) {
        return preferred.withMagnitude(radius);
      }
      final d = distance / radius;
      final z = 1 / d;
      final height = math.sqrt(d * d - 1) / d;
      final planeNormal = origin.normalized();
      final t = -origin.magnitude / planeNormal.dot(direction);
      final planeHit = origin.plus(direction.times(t));
      if (planeHit.magnitude < 1e-9) {
        return preferred.withMagnitude(radius);
      }
      final planeHitDirection = planeHit.normalized();
      return planeHitDirection.times(height).plus(planeNormal.times(z)).times(radius);
    }
    final sqrtDisc = math.sqrt(disc);
    final t0 = (-b - sqrtDisc) / (2 * a);
    final t1 = (-b + sqrtDisc) / (2 * a);
    final p0 = origin.plus(direction.times(t0));
    final p1 = origin.plus(direction.times(t1));
    return p0.distance(preferred) < p1.distance(preferred) ? p0 : p1;
  }
}
