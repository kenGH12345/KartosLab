import 'dart:math' as math;

import 'particle_type.dart';

/// Port of gas-properties `Particle.ts`.
///
/// Mutable fields match PhET (performance with large N). Top-level simulation
/// API still follows state → solver → state at the model step boundary.
class Particle {
  Particle({
    required this.id,
    required this.type,
    required this.mass,
    required this.radius,
    this.x = 0,
    this.y = 0,
    this.vx = 0,
    this.vy = 0,
  })  : prevX = x,
        prevY = y;

  factory Particle.create({
    required int id,
    required ParticleType type,
    double x = 0,
    double y = 0,
  }) =>
      Particle(
        id: id,
        type: type,
        mass: type.mass,
        radius: type.radius,
        x: x,
        y: y,
      );

  final int id;
  final ParticleType type;
  double mass; // AMU (mutable in Diffusion)
  double radius; // pm
  double x;
  double y;
  double prevX;
  double prevY;
  double vx;
  double vy;

  double get left => x - radius;
  set left(double v) => setPosition(v + radius, y);

  double get right => x + radius;
  set right(double v) => setPosition(v - radius, y);

  double get top => y + radius;
  set top(double v) => setPosition(x, v - radius);

  double get bottom => y - radius;
  set bottom(double v) => setPosition(x, v + radius);

  double get speed => math.sqrt(vx * vx + vy * vy);

  /// KE = ½ m |v|²
  double get kineticEnergy => 0.5 * mass * (vx * vx + vy * vy);

  void setPosition(double nx, double ny) {
    prevX = x;
    prevY = y;
    x = nx;
    y = ny;
  }

  void setVelocity(double nvx, double nvy) {
    vx = nvx;
    vy = nvy;
  }

  void setVelocityPolar(double magnitude, double angle) {
    vx = magnitude * math.cos(angle);
    vy = magnitude * math.sin(angle);
  }

  void setSpeed(double magnitude) {
    final s = speed;
    if (s < 1e-12) {
      vx = magnitude;
      vy = 0;
    } else {
      final scale = magnitude / s;
      vx *= scale;
      vy *= scale;
    }
  }

  void scaleVelocity(double scale) {
    vx *= scale;
    vy *= scale;
  }

  void step(double dt) {
    assert(dt > 0 && dt.isFinite);
    setPosition(x + dt * vx, y + dt * vy);
  }

  bool contactsParticle(Particle other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final minDist = radius + other.radius;
    return dx * dx + dy * dy <= minDist * minDist;
  }

  bool contactedParticle(Particle other) {
    final dx = prevX - other.prevX;
    final dy = prevY - other.prevY;
    final minDist = radius + other.radius;
    return dx * dx + dy * dy <= minDist * minDist;
  }

  bool intersectsBounds(double minX, double minY, double maxX, double maxY) {
    final iMinX = left > minX ? left : minX;
    final iMinY = bottom > minY ? bottom : minY;
    final iMaxX = right < maxX ? right : maxX;
    final iMaxY = top < maxY ? top : maxY;
    return (iMaxX - iMinX) >= 0 && (iMaxY - iMinY) >= 0;
  }

  void assertFinite() {
    assert(x.isFinite && y.isFinite && vx.isFinite && vy.isFinite);
    assert(mass > 0 && radius > 0);
  }
}
