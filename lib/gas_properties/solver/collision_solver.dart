import 'dart:math' as math;

import '../gas_properties_constants.dart';
import '../model/container_state.dart';
import '../model/particle.dart';

/// CollisionDetector.ts — spatial regions + PP impulse (e=1) + walls.
class CollisionSolver {
  CollisionSolver({
    required this.container,
    required this.particleArrays,
  }) : _regions = _createRegions(container);

  final ContainerState container;
  final List<List<Particle>> particleArrays;
  bool particleParticleCollisionsEnabled = true;
  int numberOfParticleContainerCollisions = 0;
  final List<_Region> _regions;

  int update() {
    for (final r in _regions) {
      r.clear();
    }

    final active = _regions
        .where(
          (r) => _intersects(
            r.minX,
            r.minY,
            r.maxX,
            r.maxY,
            container.left,
            container.bottom,
            container.right,
            container.top,
          ),
        )
        .toList();

    for (final particles in particleArrays) {
      for (final p in particles) {
        for (final region in active) {
          if (p.intersectsBounds(
            region.minX,
            region.minY,
            region.maxX,
            region.maxY,
          )) {
            region.particles.add(p);
          }
        }
      }
    }

    if (particleParticleCollisionsEnabled) {
      for (final region in active) {
        doParticleParticleCollisions(region.particles);
      }
    }

    numberOfParticleContainerCollisions = 0;
    for (final particles in particleArrays) {
      numberOfParticleContainerCollisions += doParticleContainerCollisions(
        particles,
        left: container.left,
        right: container.right,
        bottom: container.bottom,
        top: container.top,
        leftWallVelocityX: container.leftWallVelocityX,
      );
    }
    return numberOfParticleContainerCollisions;
  }

  /// Static wall: vx' = -vx; Explore left: vx' = -(vx - wallVx).
  static int doParticleContainerCollisions(
    List<Particle> particles, {
    required double left,
    required double right,
    required double bottom,
    required double top,
    double leftWallVelocityX = 0,
  }) {
    var count = 0;
    for (final particle in particles) {
      var collided = false;
      if (particle.left <= left) {
        particle.left = left;
        particle.setVelocity(-(particle.vx - leftWallVelocityX), particle.vy);
        collided = true;
      } else if (particle.right >= right) {
        particle.right = right;
        particle.setVelocity(-particle.vx, particle.vy);
        collided = true;
      }
      if (particle.top >= top) {
        particle.top = top;
        particle.setVelocity(particle.vx, -particle.vy);
        collided = true;
      } else if (particle.bottom <= bottom) {
        particle.bottom = bottom;
        particle.setVelocity(particle.vx, -particle.vy);
        collided = true;
      }
      if (collided) count++;
    }
    return count;
  }

  static void doParticleParticleCollisions(List<Particle> particles) {
    const e = 1.0;
    for (var i = particles.length - 1; i >= 1; i--) {
      final p1 = particles[i];
      for (var j = i - 1; j >= 0; j--) {
        final p2 = particles[j];
        if (p1.contactedParticle(p2) || !p1.contactsParticle(p2)) continue;

        final dx = p1.x - p2.x;
        final dy = p1.y - p2.y;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist < 1e-12) continue;

        final contactRatio = p1.radius / dist;
        final contactX = p1.x - dx * contactRatio;
        final contactY = p1.y - dy * contactRatio;
        final nx = dx / dist;
        final ny = dy / dist;
        final lineAngle = math.atan2(-dx, dy);

        _adjustPosition(p1, contactX, contactY, lineAngle);
        _adjustPosition(p2, contactX, contactY, lineAngle);

        final rvx = p1.vx - p2.vx;
        final rvy = p1.vy - p2.vy;
        final vr = rvx * nx + rvy * ny;
        final jImpulse = (-vr * (1 + e)) / (1 / p1.mass + 1 / p2.mass);

        p1.setVelocity(
          p1.vx + nx * (jImpulse / p1.mass),
          p1.vy + ny * (jImpulse / p1.mass),
        );
        p2.setVelocity(
          p2.vx - nx * (jImpulse / p2.mass),
          p2.vy - ny * (jImpulse / p2.mass),
        );
      }
    }
  }

  static void _adjustPosition(
    Particle particle,
    double contactX,
    double contactY,
    double lineAngle,
  ) {
    final pdx = contactX - particle.prevX;
    final pdy = contactY - particle.prevY;
    final prevDist = math.sqrt(pdx * pdx + pdy * pdy);
    if (prevDist < 1e-12) return;
    final ratio = particle.radius / prevDist;
    final lineX = contactX - (contactX - particle.prevX) * ratio;
    final lineY = contactY - (contactY - particle.prevY) * ratio;
    final reflected = _reflect(particle.x, particle.y, lineX, lineY, lineAngle);
    particle.setPosition(reflected.$1, reflected.$2);
  }

  static (double, double) _reflect(
    double px,
    double py,
    double lineX,
    double lineY,
    double lineAngle,
  ) {
    final twoPi = math.pi * 2;
    final alpha = lineAngle % twoPi;
    final gamma = math.atan2(py - lineY, px - lineX) % twoPi;
    final theta = (2 * alpha - gamma) % twoPi;
    final d = math.sqrt(
      (px - lineX) * (px - lineX) + (py - lineY) * (py - lineY),
    );
    return (lineX + d * math.cos(theta), lineY + d * math.sin(theta));
  }

  static List<_Region> _createRegions(ContainerState container) {
    final regionLength = container.height / 4;
    final regions = <_Region>[];
    var maxX = container.right;
    while (maxX > container.right - GasPropertiesConstants.widthMax) {
      final minX = maxX - regionLength;
      var minY = container.bottom;
      while (minY < container.top) {
        regions.add(_Region(minX, minY, maxX, minY + regionLength));
        minY += regionLength;
      }
      maxX -= regionLength;
    }
    return regions;
  }

  static bool _intersects(
    double a0,
    double a1,
    double a2,
    double a3,
    double b0,
    double b1,
    double b2,
    double b3,
  ) =>
      a2 >= b0 && a0 <= b2 && a3 >= b1 && a1 <= b3;
}

class _Region {
  _Region(this.minX, this.minY, this.maxX, this.maxY);
  final double minX, minY, maxX, maxY;
  final List<Particle> particles = [];
  void clear() => particles.clear();
}
