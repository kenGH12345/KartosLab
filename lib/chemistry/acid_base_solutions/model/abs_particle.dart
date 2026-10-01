import 'dart:ui';

import 'particle_key.dart';

/// Particle descriptor — PhET `Particle` type in `Particle.ts`.
class AbsParticle {
  const AbsParticle({
    required this.key,
    required this.color,
    required this.getConcentration,
  });

  final ParticleKey key;

  /// Color used to render the particle (from `ABSColors`).
  final Color color;

  /// Returns equilibrium concentration (mol/L) for this particle type.
  final double Function() getConcentration;
}
