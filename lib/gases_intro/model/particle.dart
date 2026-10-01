import 'dart:math' as math;

import '../gases_intro_constants.dart';

enum ParticleKind { heavy, light }

/// Port of gas-properties Particle.ts @ 10c7c08.
class GasParticle {
  GasParticle({
    required this.kind,
    required this.mass,
    required this.radius,
    this.x = 0,
    this.y = 0,
    this.vx = 0,
    this.vy = 0,
  })  : prevX = x,
        prevY = y;

  factory GasParticle.heavy({double x = 0, double y = 0}) => GasParticle(
        kind: ParticleKind.heavy,
        mass: GasesIntroConstants.heavyMass,
        radius: GasesIntroConstants.heavyRadius,
        x: x,
        y: y,
      );

  factory GasParticle.light({double x = 0, double y = 0}) => GasParticle(
        kind: ParticleKind.light,
        mass: GasesIntroConstants.lightMass,
        radius: GasesIntroConstants.lightRadius,
        x: x,
        y: y,
      );

  final ParticleKind kind;
  double mass; // AMU
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

  void setSpeed(double magnitude) => setVelocityMagnitude(magnitude);

  void setVelocityMagnitude(double newSpeed) {
    final s = speed;
    if (s < 1e-12) {
      vx = newSpeed;
      vy = 0;
    } else {
      final scale = newSpeed / s;
      vx *= scale;
      vy *= scale;
    }
  }

  void scaleVelocity(double scale) {
    vx *= scale;
    vy *= scale;
  }

  void step(double dt) {
    setPosition(x + dt * vx, y + dt * vy);
  }

  bool contactsParticle(GasParticle other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final minDist = radius + other.radius;
    return dx * dx + dy * dy <= minDist * minDist;
  }

  bool contactedParticle(GasParticle other) {
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
}
