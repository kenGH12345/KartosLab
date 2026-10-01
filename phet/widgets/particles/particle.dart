/// PhET Particle — a single particle (electron, atom, molecule, gas
/// molecule, photon, etc.) with position, velocity, acceleration, mass,
/// charge, radius, and lifetime.
library;

import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  Offset acceleration;
  double mass;
  double charge;
  double radius;
  double lifetime;
  double age;
  bool alive;
  Color color;

  Particle({
    required this.position,
    this.velocity = Offset.zero,
    this.acceleration = Offset.zero,
    this.mass = 1,
    this.charge = 0,
    this.radius = 3,
    this.lifetime = double.infinity,
    this.age = 0,
    this.alive = true,
    this.color = const Color(0xff42a5f5),
  });

  /// Advance this particle by dt seconds.
  void update(double dt) {
    velocity += acceleration * dt;
    position += velocity * dt;
    age += dt;
    if (age >= lifetime) alive = false;
  }

  /// Draw this particle on canvas.
  void draw(Canvas canvas) {
    if (!alive) return;
    // Glow
    canvas.drawCircle(position, radius * 1.5, Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill);
    // Body
    canvas.drawCircle(position, radius, Paint()..color = color);
    // Highlight
    canvas.drawCircle(
      Offset(position.dx - radius * 0.3, position.dy - radius * 0.3),
      radius * 0.3,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );
  }

  Particle copyWith({
    Offset? position,
    Offset? velocity,
    Offset? acceleration,
    double? mass,
    double? charge,
    double? radius,
    double? lifetime,
    double? age,
    bool? alive,
    Color? color,
  }) =>
      Particle(
        position: position ?? this.position,
        velocity: velocity ?? this.velocity,
        acceleration: acceleration ?? this.acceleration,
        mass: mass ?? this.mass,
        charge: charge ?? this.charge,
        radius: radius ?? this.radius,
        lifetime: lifetime ?? this.lifetime,
        age: age ?? this.age,
        alive: alive ?? this.alive,
        color: color ?? this.color,
      );
}
