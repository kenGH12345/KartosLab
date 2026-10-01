/// PhET Force System — force calculators for different physics domains.
///
/// All forces return a [PhetVector] that can be applied to [PhysicsObject].
library;

import 'package:flutter/material.dart';
import '../core/phet_types.dart';

/// Base class for all forces.
abstract class Force {
  /// Compute force at [position] given [object] properties.
  PhetVector compute(Offset position, {double mass = 1, double charge = 0, Offset velocity = Offset.zero});
}

/// Gravity: F = mg (downward).
class GravityForce extends Force {
  final double g;
  GravityForce([this.g = 9.81]);

  @override
  PhetVector compute(Offset position, {double mass = 1, double charge = 0, Offset velocity = Offset.zero}) {
    return PhetVector(0, mass * g);
  }
}

/// Spring: F = -kx.
class SpringForce extends Force {
  final Offset anchor;
  final double restLength;
  final double k;

  SpringForce({required this.anchor, this.restLength = 0, this.k = 10});

  @override
  PhetVector compute(Offset position, {double mass = 1, double charge = 0, Offset velocity = Offset.zero}) {
    final delta = position - anchor;
    final dist = delta.distance;
    if (dist < 1e-9) return PhetVector.zero();
    final extension = dist - restLength;
    return PhetVector(-delta.dx / dist, -delta.dy / dist) * (k * extension);
  }
}

/// Friction: F = -μv (linear drag) or F = -μ|v|v (quadratic).
class FrictionForce extends Force {
  final double coefficient;
  final bool quadratic;

  FrictionForce({this.coefficient = 0.1, this.quadratic = false});

  @override
  PhetVector compute(Offset position, {double mass = 1, double charge = 0, Offset velocity = Offset.zero}) {
    final v = PhetVector(velocity.dx, velocity.dy);
    if (quadratic) {
      final speed = v.magnitude;
      if (speed < 1e-9) return PhetVector.zero();
      return -v.normalized() * (coefficient * speed * speed);
    }
    return -v * coefficient;
  }
}

/// Buoyant force: F = ρVg (upward).
class BuoyantForce extends Force {
  final double fluidDensity;
  final double volume;
  final double g;

  BuoyantForce({this.fluidDensity = 1000, this.volume = 0.001, this.g = 9.81});

  @override
  PhetVector compute(Offset position, {double mass = 1, double charge = 0, Offset velocity = Offset.zero}) {
    return PhetVector(0, -fluidDensity * volume * g);
  }
}

/// Electric force: F = qE.
class ElectricForce extends Force {
  final PhetVector field;

  ElectricForce(this.field);

  @override
  PhetVector compute(Offset position, {double mass = 1, double charge = 0, Offset velocity = Offset.zero}) {
    return field * charge;
  }
}

/// Magnetic force: F = qv × B (in 2D: F = qvB perpendicular to velocity).
class MagneticForce extends Force {
  final double bField; // scalar B (perpendicular to 2D plane)

  MagneticForce(this.bField);

  @override
  PhetVector compute(Offset position, {double mass = 1, double charge = 0, Offset velocity = Offset.zero}) {
    // F = q(v × B), in 2D with B in z: Fx = qVy*B, Fy = -qVx*B
    return PhetVector(velocity.dy * bField * charge, -velocity.dx * bField * charge);
  }
}
