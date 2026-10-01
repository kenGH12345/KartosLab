import 'dart:math' as math;
import 'dart:ui';

import 'beaker.dart';
import 'concentration_constants.dart';
import 'concentration_solution.dart';
import 'shaker_model.dart';
import 'solute.dart';
import 'solute_particle.dart';

/// Falling shaker particles — beers-law-lab `ShakerParticles.ts`.
class ShakerParticles {
  ShakerParticles({
    math.Random? random,
  }) : _random = random ?? math.Random();

  final math.Random _random;
  final List<SoluteParticle> particles = <SoluteParticle>[];
  int _nextId = 1;

  int get count => particles.length;

  /// Source spawn count: `round(max(1, dispensingRate * particlesPerMole * dt))`.
  static int expectedSpawnCount({
    required double dispensingRate,
    required int particlesPerMole,
    required double dt,
  }) {
    if (dispensingRate <= 0) return 0;
    return math.max(1, (dispensingRate * particlesPerMole * dt).round());
  }

  void removeAllParticles() {
    particles.clear();
  }

  /// Propagate + create particles; delivers moles into [solution] when particles hit liquid.
  void step({
    required double dt,
    required ConcentrationSolution solution,
    required Beaker beaker,
    required ShakerModel shaker,
  }) {
    for (var i = particles.length - 1; i >= 0; i--) {
      final particle = particles[i];
      _stepParticle(dt, particle, beaker);

      final percentFull = solution.volume / beaker.volume;
      final solutionSurfaceY = beaker.position.dy -
          (percentFull * beaker.size.height) -
          solution.solute.particleSize;

      if (particle.position.dy > solutionSurfaceY) {
        particles.removeAt(i);
        final next =
            solution.soluteMoles + (1.0 / solution.solute.particlesPerMole);
        solution.setSoluteMoles(
          math.min(ConcentrationConstants.soluteAmountMax, next),
        );
      }
    }

    if (shaker.dispensingRate > 0) {
      final numberOfParticles = math.max(
        1,
        (shaker.dispensingRate * solution.solute.particlesPerMole * dt).round(),
      );
      for (var j = 0; j < numberOfParticles; j++) {
        particles.add(
          SoluteParticle(
            id: _nextId++,
            solute: solution.solute,
            position: _randomPosition(shaker.position),
            orientation: _random.nextDouble() * 2 * math.pi,
            velocity: _initialVelocity(shaker.orientation),
            acceleration: const Offset(
              0,
              ConcentrationConstants.gravitationalAcceleration,
            ),
          ),
        );
      }
    }
  }

  void _stepParticle(double dt, SoluteParticle particle, Beaker beaker) {
    particle.velocity = Offset(
      particle.velocity.dx + particle.acceleration.dx * dt,
      particle.velocity.dy + particle.acceleration.dy * dt,
    );
    var newX = particle.position.dx + particle.velocity.dx * dt;
    var newY = particle.position.dy + particle.velocity.dy * dt;

    // Bounce off left wall (source `ShakerParticles.stepParticle`).
    final minX = beaker.left + particle.solute.particleSize;
    if (newX <= minX) {
      newX = minX;
      particle.velocity =
          Offset(particle.velocity.dx.abs(), particle.velocity.dy);
    }
    particle.position = Offset(newX, newY);
  }

  Offset _initialVelocity(double orientation) {
    final speed = ConcentrationConstants.shakerInitialSpeed;
    return Offset(
      speed * math.cos(orientation),
      speed * math.sin(orientation),
    );
  }

  Offset _randomPosition(Offset origin) {
    final xOffset = _random.nextInt(
          ConcentrationConstants.shakerMaxXOffset.toInt() * 2 + 1,
        ) -
        ConcentrationConstants.shakerMaxXOffset.toInt();
    final yOffset = _random.nextInt(
      ConcentrationConstants.shakerMaxYOffset.toInt() + 1,
    );
    return Offset(origin.dx + xOffset, origin.dy + yOffset);
  }

  void reset() => removeAllParticles();
}

/// Precipitate particle count management — `PrecipitateParticles.ts`.
///
/// Add/remove from the **end** of [particles] (source issue #48) so remaining
/// particles keep stable identity / positions across syncs.
class PrecipitateParticles {
  PrecipitateParticles({math.Random? random})
      : _random = random ?? math.Random();

  final math.Random _random;
  final List<SoluteParticle> particles = <SoluteParticle>[];
  int _nextId = 1;

  int get count => particles.length;

  void removeAllParticles() => particles.clear();

  void syncToSolution(ConcentrationSolution solution, Beaker beaker) {
    final target = solution.numberOfPrecipitateParticles;
    if (target == particles.length) return;

    if (target < particles.length) {
      particles.removeRange(target, particles.length);
      return;
    }

    final toAdd = target - particles.length;
    for (var i = 0; i < toAdd; i++) {
      particles.add(
        SoluteParticle(
          id: _nextId++,
          solute: solution.solute,
          position: _randomBottomPosition(solution.solute, beaker),
          orientation: _random.nextDouble() * 2 * math.pi,
        ),
      );
    }
  }

  Offset _randomBottomPosition(Solute solute, Beaker beaker) {
    final particleSize = solute.particleSize;
    final margin = math.sqrt(particleSize * particleSize);
    final x = beaker.position.dx -
        (beaker.size.width / 2) +
        margin +
        (_random.nextDouble() * (beaker.size.width - 2 * margin));
    final y = beaker.position.dy - margin;
    return Offset(x, y);
  }

  void reset() => removeAllParticles();
}
