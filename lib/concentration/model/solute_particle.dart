import 'dart:math' as math;
import 'dart:ui';

import 'solute.dart';

/// Single solute particle — beers-law-lab `SoluteParticle.ts`.
///
/// [id] is stable for View identity. Orientation is fixed at creation
/// (source precomputes cos/sin; no per-frame spin).
class SoluteParticle {
  SoluteParticle({
    required this.id,
    required this.solute,
    required this.position,
    required this.orientation,
    Offset? velocity,
    Offset? acceleration,
  })  : velocity = velocity ?? Offset.zero,
        acceleration = acceleration ?? Offset.zero,
        cos = math.cos(orientation),
        sin = math.sin(orientation);

  final int id;
  final Solute solute;
  Offset position;
  final double orientation; // radians
  Offset velocity;
  final Offset acceleration;

  /// Precomputed for painter performance (source `SoluteParticle.cos/sin`).
  final double cos;
  final double sin;

  double get size => solute.particleSize;
}
