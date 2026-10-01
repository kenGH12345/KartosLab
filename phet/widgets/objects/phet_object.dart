/// PhET Object — a base class for interactive simulation objects.
///
/// Provides position, velocity, rotation, scale, visibility, and selection
/// state. Used by magnets, balls, blocks, charges, molecules, etc.
library;

import 'package:flutter/material.dart';

class PhetObject {
  Offset position;
  Offset velocity;
  double rotation;
  double scale;
  bool visible;
  bool enabled;
  bool selected;

  PhetObject({
    this.position = Offset.zero,
    this.velocity = Offset.zero,
    this.rotation = 0,
    this.scale = 1,
    this.visible = true,
    this.enabled = true,
    this.selected = false,
  });

  /// Update position by velocity × dt.
  void update(double dt) {
    position += velocity * dt;
  }

  /// Reset to default state.
  void reset() {
    position = Offset.zero;
    velocity = Offset.zero;
    rotation = 0;
    scale = 1;
    visible = true;
    enabled = true;
    selected = false;
  }
}

/// An object that also tracks acceleration (for physics simulations).
class PhetPhysicsObject extends PhetObject {
  Offset acceleration;
  double mass;

  PhetPhysicsObject({
    super.position,
    super.velocity,
    super.rotation,
    super.scale,
    super.visible,
    super.enabled,
    super.selected,
    this.acceleration = Offset.zero,
    this.mass = 1,
  });

  /// Apply Newton's equations: a = F/m, v += a·dt, x += v·dt
  void applyForce(Offset force, double dt) {
    acceleration = force / mass;
    velocity += acceleration * dt;
    position += velocity * dt;
  }

  @override
  void reset() {
    super.reset();
    acceleration = Offset.zero;
  }
}
