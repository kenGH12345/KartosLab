import 'dart:math';
import 'dart:ui';

import 'abs_constants.dart';
import 'particle_count.dart';
import 'particle_key.dart';
import 'solutions/aqueous_solution.dart';

/// One particle instance for the magnifying-glass canvas.
class AbsParticleInstance {
  const AbsParticleInstance({
    required this.key,
    required this.position,
  });

  final ParticleKey key;
  final Offset position;
}

/// Builds static particle layouts for a solution.
///
/// Production uses [Random]; tests inject a seeded [Random] so counts/layout
/// are deterministic. Positions are **not** part of PhET-iO state in source.
class AbsParticleField {
  AbsParticleField({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Lens radius used for sampling — matches `ParticlesNode` /
  /// `ParticlesCanvasNode` (`0.465 * beaker.height`, line width 8).
  static double lensRadiusForBeakerHeight(double beakerHeight) =>
      0.465 * beakerHeight;

  /// Position radius after IMAGE_SCALE compensation in source:
  /// `IMAGE_SCALE * (lensRadius - lensLineWidth/2)` with IMAGE_SCALE=2.
  /// For model tests we sample in lens-local coordinates with
  /// `positionRadius = lensRadius - lensLineWidth/2` (pre-scale space).
  List<AbsParticleInstance> buildLayout({
    required AqueousSolution solution,
    required double lensRadius,
    double lensLineWidth = 8,
  }) {
    final positionRadius = lensRadius - (lensLineWidth / 2);
    final result = <AbsParticleInstance>[];

    for (final particle in solution.particles) {
      // Skip H2O — shown via solvent.png when preferences allow.
      if (particle.key == ParticleKey.h2o) continue;

      final count = absParticleCount(particle.getConcentration());
      for (var i = 0; i < count; i++) {
        final distance = positionRadius * sqrt(_random.nextDouble());
        final angle = _random.nextDouble() * 2 * pi;
        result.add(
          AbsParticleInstance(
            key: particle.key,
            position: Offset(
              distance * cos(angle),
              distance * sin(angle),
            ),
          ),
        );
      }
    }
    return result;
  }

  /// Counts per particle key (excluding H2O), for oracle tests.
  Map<ParticleKey, int> countsFor(AqueousSolution solution) {
    final map = <ParticleKey, int>{};
    for (final particle in solution.particles) {
      if (particle.key == ParticleKey.h2o) continue;
      map[particle.key] = absParticleCount(particle.getConcentration());
    }
    return map;
  }

  /// Max particles constant exposed for tests.
  static int get maxParticles => AbsConstants.particleMaxCount;
}
