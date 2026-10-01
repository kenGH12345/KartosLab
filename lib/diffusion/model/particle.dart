import 'dart:math' as math;

import '../diffusion_constants.dart';

enum ParticleSpecies { one, two }

/// Particle — gas-properties `Particle` + DiffusionParticle1/2 @ 7a52c48.
class DiffusionParticle {
  DiffusionParticle({
    required this.species,
    required this.mass,
    required this.radius,
    required double x,
    required double y,
    required this.vx,
    required this.vy,
  })  : x = x,
        y = y,
        prevX = x,
        prevY = y;

  final ParticleSpecies species;
  double mass; // AMU
  double radius; // pm
  double x;
  double y;
  double vx;
  double vy;
  double prevX;
  double prevY;

  double get left => x - radius;
  double get right => x + radius;
  double get bottom => y - radius;
  double get top => y + radius;

  void setPosition(double nx, double ny) {
    x = nx;
    y = ny;
  }

  void setVelocity(double nvx, double nvy) {
    vx = nvx;
    vy = nvy;
  }

  void setVelocityPolar(double speed, double angle) {
    vx = speed * math.cos(angle);
    vy = speed * math.sin(angle);
  }

  void setVelocityMagnitude(double speed) {
    final mag = math.sqrt(vx * vx + vy * vy);
    if (mag < 1e-12) {
      vx = speed;
      vy = 0;
      return;
    }
    final s = speed / mag;
    vx *= s;
    vy *= s;
  }

  /// Step one model dt (ps) — ParticleUtils.stepParticles
  void step(double dtPs) {
    prevX = x;
    prevY = y;
    x += vx * dtPs;
    y += vy * dtPs;
  }

  bool contactsParticle(DiffusionParticle other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final minDist = radius + other.radius;
    return dx * dx + dy * dy <= minDist * minDist;
  }

  bool contactedParticle(DiffusionParticle other) {
    final dx = prevX - other.prevX;
    final dy = prevY - other.prevY;
    final minDist = radius + other.radius;
    return dx * dx + dy * dy <= minDist * minDist;
  }

  bool intersectsBounds(double minX, double minY, double maxX, double maxY) {
    return right >= minX && left <= maxX && top >= minY && bottom <= maxY;
  }

  double getKineticEnergy() => 0.5 * mass * (vx * vx + vy * vy);

  int get colorArgb => species == ParticleSpecies.one
      ? DiffusionConstants.particle1Color
      : DiffusionConstants.particle2Color;

  int get highlightArgb => species == ParticleSpecies.one
      ? DiffusionConstants.particle1Highlight
      : DiffusionConstants.particle2Highlight;
}
