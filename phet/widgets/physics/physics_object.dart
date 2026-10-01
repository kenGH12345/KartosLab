/// PhET Physics Object — base class for physics bodies with mass, force,
/// velocity, acceleration.
library;

import 'package:flutter/material.dart';
import '../core/phet_types.dart';

class PhysicsObject {
  Offset position;
  Offset velocity;
  Offset acceleration;
  double mass;
  double charge;
  double rotation;
  double angularVelocity;
  double angularAcceleration;
  double momentOfInertia;
  bool alive;

  PhysicsObject({
    this.position = Offset.zero,
    this.velocity = Offset.zero,
    this.acceleration = Offset.zero,
    this.mass = 1,
    this.charge = 0,
    this.rotation = 0,
    this.angularVelocity = 0,
    this.angularAcceleration = 0,
    this.momentOfInertia = 1,
    this.alive = true,
  });

  /// Apply a force to this object (F = ma → a = F/m).
  void applyForce(Offset force) {
    acceleration += force / mass;
  }

  /// Apply a torque (τ = Iα → α = τ/I).
  void applyTorque(double torque) {
    angularAcceleration += torque / momentOfInertia;
  }

  /// Advance physics by dt seconds.
  void integrate(double dt) {
    velocity += acceleration * dt;
    position += velocity * dt;
    angularVelocity += angularAcceleration * dt;
    rotation += angularVelocity * dt;
    // Reset accelerations (forces are re-applied each step)
    acceleration = Offset.zero;
    angularAcceleration = 0;
  }

  /// Get momentum vector (p = mv).
  PhetVector get momentum => PhetVector(velocity.dx * mass, velocity.dy * mass);

  /// Kinetic energy (KE = ½mv²).
  double get kineticEnergy => 0.5 * mass * (velocity.dx * velocity.dx + velocity.dy * velocity.dy);

  void reset() {
    position = Offset.zero;
    velocity = Offset.zero;
    acceleration = Offset.zero;
    rotation = 0;
    angularVelocity = 0;
    angularAcceleration = 0;
    alive = true;
  }
}

/// A rigid body extends [PhysicsObject] with collision shape.
class RigidBody extends PhysicsObject {
  double width;
  double height;
  double radius;

  RigidBody({
    this.width = 0,
    this.height = 0,
    this.radius = 0,
    super.position,
    super.velocity,
    super.mass,
    super.charge,
    super.rotation,
  });
}
