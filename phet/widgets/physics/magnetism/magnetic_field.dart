/// PhET Magnetic Field — dipole-approximation magnetic field model.
///
/// Models a magnetic source as two monopoles (N and S) separated by a
/// distance. The field at any point is the superposition of the fields
/// from both poles.
///
/// This is the same model used by the existing Magnet & Compass and
/// Electromagnet simulations, now generalized.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/phet_types.dart';
import '../../visualization/field.dart';

/// A magnetic dipole source.
class MagneticDipole {
  final Offset center;
  final double axisAngle;
  final double halfLength;
  final double strength;
  final int loops;

  const MagneticDipole({
    required this.center,
    this.axisAngle = 0,
    this.halfLength = 80,
    this.strength = 100000,
    this.loops = 1,
  });

  /// Get the N pole position.
  Offset get northPole => Offset(
        center.dx + cos(axisAngle) * halfLength,
        center.dy + sin(axisAngle) * halfLength,
      );

  /// Get the S pole position.
  Offset get southPole => Offset(
        center.dx - cos(axisAngle) * halfLength,
        center.dy - sin(axisAngle) * halfLength,
      );
}

/// A [Field] backed by one or more [MagneticDipole] sources.
class MagneticField extends Field {
final List<MagneticDipole> dipoles;

MagneticField(this.dipoles);

/// Single-dipole convenience constructor.
MagneticField.single(MagneticDipole d) : dipoles = [d];

  @override
  PhetVector valueAt(Offset point) {
    var bx = 0.0;
    var by = 0.0;
    for (final d in dipoles) {
      final v = _dipoleField(d, point);
      bx += v.dx;
      by += v.dy;
    }
    return PhetVector(bx, by);
  }

  PhetVector _dipoleField(MagneticDipole d, Offset p) {
    final k = d.strength * d.loops;
    if (k.abs() < 1e-9) return PhetVector.zero();

    final nPole = d.northPole;
    final sPole = d.southPole;

    // Field from N pole (outward)
    final rN = p - nPole;
    final distN2 = (rN.dx * rN.dx + rN.dy * rN.dy).clamp(1.0, double.infinity);
    final distN = sqrt(distN2);
    final bNx = rN.dx / (distN2 * distN);
    final bNy = rN.dy / (distN2 * distN);

    // Field from S pole (inward)
    final rS = p - sPole;
    final distS2 = (rS.dx * rS.dx + rS.dy * rS.dy).clamp(1.0, double.infinity);
    final distS = sqrt(distS2);
    final bSx = -rS.dx / (distS2 * distS);
    final bSy = -rS.dy / (distS2 * distS);

    return PhetVector((bNx + bSx) * k, (bNy + bSy) * k);
  }
}
