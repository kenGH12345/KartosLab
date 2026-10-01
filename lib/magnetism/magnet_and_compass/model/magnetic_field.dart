import 'dart:math';
import 'package:flutter/material.dart';

/// Magnetic field calculation for the bar-magnet dipole model.
///
/// Extracted from `simulations/magnet_and_compass.dart:72-128`.
/// Class name unchanged — sim-internal logic.
class MagneticField {
  /// Computes the magnetic field vector [B] at point [p] produced by a
  /// bar magnet (or Earth field) modelled as two opposite poles.
  static Offset compute(
    Offset p,
    Offset magnetPos,
    double angle,
    double halfLen,
    double strength,
    bool flipped,
    bool earthField,
  ) {
    if (earthField) {
      final sign = flipped ? 1.0 : -1.0;
      final earthHalfLen = halfLen * 0.65;
      final nPole = Offset(magnetPos.dx, magnetPos.dy + sign * earthHalfLen);
      final sPole = Offset(magnetPos.dx, magnetPos.dy - sign * earthHalfLen);
      final k = strength * 18000.0;

      final rN = p - nPole;
      final distN2 = (rN.dx * rN.dx + rN.dy * rN.dy).clamp(1.0, double.infinity);
      final distN = sqrt(distN2);
      final bN = Offset(rN.dx / (distN2 * distN), rN.dy / (distN2 * distN));

      final rS = p - sPole;
      final distS2 = (rS.dx * rS.dx + rS.dy * rS.dy).clamp(1.0, double.infinity);
      final distS = sqrt(distS2);
      final bS = Offset(-rS.dx / (distS2 * distS), -rS.dy / (distS2 * distS));

      return Offset((bN.dx + bS.dx) * k, (bN.dy + bS.dy) * k);
    }

    final sign = flipped ? -1.0 : 1.0;
    final nPole = Offset(
      magnetPos.dx + cos(angle) * halfLen * sign,
      magnetPos.dy + sin(angle) * halfLen * sign,
    );
    final sPole = Offset(
      magnetPos.dx - cos(angle) * halfLen * sign,
      magnetPos.dy - sin(angle) * halfLen * sign,
    );
    final k = strength * 18000.0;

    final rN = p - nPole;
    final distN2 = (rN.dx * rN.dx + rN.dy * rN.dy).clamp(1.0, double.infinity);
    final distN = sqrt(distN2);
    final bN = Offset(rN.dx / (distN2 * distN), rN.dy / (distN2 * distN));

    final rS = p - sPole;
    final distS2 = (rS.dx * rS.dx + rS.dy * rS.dy).clamp(1.0, double.infinity);
    final distS = sqrt(distS2);
    final bS = Offset(-rS.dx / (distS2 * distS), -rS.dy / (distS2 * distS));

    return Offset((bN.dx + bS.dx) * k, (bN.dy + bS.dy) * k);
  }

  static double magnitude(Offset b) => sqrt(b.dx * b.dx + b.dy * b.dy);
  static double fieldAngle(Offset b) => atan2(b.dy, b.dx);
}
