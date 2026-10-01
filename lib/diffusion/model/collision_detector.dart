import 'dart:math' as math;

import 'container.dart';
import 'particle.dart';

/// Port of gas-properties CollisionDetector + DiffusionCollisionDetector @ 7a52c48.
///
/// Perfectly elastic (e=1). Not Collision Lab.
class DiffusionCollisionDetector {
  DiffusionCollisionDetector({
    required this.container,
    required this.particles1,
    required this.particles2,
  });

  final DiffusionContainer container;
  final List<DiffusionParticle> particles1;
  final List<DiffusionParticle> particles2;

  static const double e = 1.0;

  int numberOfWallCollisions = 0;

  void update() {
    // Flatten for PP within combined list per region approximation:
    // Full region grid omitted for correctness of PP on full lists when N≤200 —
    // PhET regions are an optimization; semantics match pair checks.
    // When divider present, species stay in their halves so cross-species PP
    // cannot occur until divider removed.
    _particleParticle(particles1);
    _particleParticle(particles2);
    if (!container.hasDivider) {
      _particleParticleCross(particles1, particles2);
    }

    numberOfWallCollisions = 0;
    if (container.hasDivider) {
      numberOfWallCollisions += _walls(particles1, container.left, container.bottom,
          container.leftMaxX, container.top);
      numberOfWallCollisions += _walls(particles2, container.rightMinX,
          container.bottom, container.right, container.top);
    } else {
      numberOfWallCollisions += _walls(particles1, container.left, container.bottom,
          container.right, container.top);
      numberOfWallCollisions += _walls(particles2, container.left, container.bottom,
          container.right, container.top);
    }
  }

  void _particleParticle(List<DiffusionParticle> particles) {
    for (var i = particles.length - 1; i >= 1; i--) {
      final p1 = particles[i];
      for (var j = i - 1; j >= 0; j--) {
        final p2 = particles[j];
        if (!p1.contactedParticle(p2) && p1.contactsParticle(p2)) {
          _resolvePair(p1, p2);
        }
      }
    }
  }

  void _particleParticleCross(
    List<DiffusionParticle> a,
    List<DiffusionParticle> b,
  ) {
    for (final p1 in a) {
      for (final p2 in b) {
        if (!p1.contactedParticle(p2) && p1.contactsParticle(p2)) {
          _resolvePair(p1, p2);
        }
      }
    }
  }

  void _resolvePair(DiffusionParticle particle1, DiffusionParticle particle2) {
    final dx = particle1.x - particle2.x;
    final dy = particle1.y - particle2.y;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 1e-12) return;

    final contactRatio = particle1.radius / dist;
    final contactPointX = particle1.x - dx * contactRatio;
    final contactPointY = particle1.y - dy * contactRatio;

    final nx = dx / dist;
    final ny = dy / dist;
    final tx = dy;
    final ty = -dx;
    final lineAngle = math.atan2(ty, tx);

    _adjustPosition(particle1, contactPointX, contactPointY, lineAngle);
    _adjustPosition(particle2, contactPointX, contactPointY, lineAngle);

    final rvx = particle1.vx - particle2.vx;
    final rvy = particle1.vy - particle2.vy;
    final vr = rvx * nx + rvy * ny;
    final numerator = -vr * (1 + e);
    final denominator = (1 / particle1.mass + 1 / particle2.mass);
    final j = numerator / denominator;

    particle1.setVelocity(
      particle1.vx + nx * (j / particle1.mass),
      particle1.vy + ny * (j / particle1.mass),
    );
    particle2.setVelocity(
      particle2.vx - nx * (j / particle2.mass),
      particle2.vy - ny * (j / particle2.mass),
    );
  }

  void _adjustPosition(
    DiffusionParticle particle,
    double contactPointX,
    double contactPointY,
    double lineAngle,
  ) {
    final previousDistance = math.sqrt(
      math.pow(particle.prevX - contactPointX, 2) +
          math.pow(particle.prevY - contactPointY, 2),
    );
    if (previousDistance < 1e-12) return;
    final positionRatio = particle.radius / previousDistance;
    final pointOnLineX =
        contactPointX - (contactPointX - particle.prevX) * positionRatio;
    final pointOnLineY =
        contactPointY - (contactPointY - particle.prevY) * positionRatio;

    // reflect particle.position across line through pointOnLine at lineAngle
    final reflected = _reflectAcrossLine(
      particle.x,
      particle.y,
      pointOnLineX,
      pointOnLineY,
      lineAngle,
    );
    particle.setPosition(reflected.$1, reflected.$2);
  }

  (double, double) _reflectAcrossLine(
    double px,
    double py,
    double lx,
    double ly,
    double lineAngle,
  ) {
    // GasPropertiesUtils.reflectPointAcrossLine
    final cos = math.cos(lineAngle);
    final sin = math.sin(lineAngle);
    final dx = px - lx;
    final dy = py - ly;
    final localX = dx * cos + dy * sin;
    final localY = -dx * sin + dy * cos;
    final rx = localX;
    final ry = -localY;
    return (lx + rx * cos - ry * sin, ly + rx * sin + ry * cos);
  }

  int _walls(
    List<DiffusionParticle> particles,
    double minX,
    double minY,
    double maxX,
    double maxY,
  ) {
    var n = 0;
    for (final particle in particles) {
      var collided = false;
      if (particle.left <= minX) {
        particle.setPosition(minX + particle.radius, particle.y);
        particle.setVelocity(-particle.vx, particle.vy);
        collided = true;
      } else if (particle.right >= maxX) {
        particle.setPosition(maxX - particle.radius, particle.y);
        particle.setVelocity(-particle.vx, particle.vy);
        collided = true;
      }
      if (particle.top >= maxY) {
        particle.setPosition(particle.x, maxY - particle.radius);
        particle.setVelocity(particle.vx, -particle.vy);
        collided = true;
      } else if (particle.bottom <= minY) {
        particle.setPosition(particle.x, minY + particle.radius);
        particle.setVelocity(particle.vx, -particle.vy);
        collided = true;
      }
      if (collided) n++;
    }
    return n;
  }
}
