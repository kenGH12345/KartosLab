import 'dart:math' as math;

import '../gases_intro_constants.dart';
import 'container_model.dart';
import 'particle.dart';
import 'random_source.dart';

/// Port of ParticleSystem.ts @ 10c7c08.
class ParticleSystem {
  ParticleSystem({
    required this.getInitialTemperature,
    required this.container,
    RandomSource? random,
  }) : random = random ?? RandomSource();

  final double Function() getInitialTemperature;
  final ContainerModel container;
  final RandomSource random;

  final List<GasParticle> heavyParticles = [];
  final List<GasParticle> lightParticles = [];

  bool collisionsEnabled = true;

  int get numberOfHeavy => heavyParticles.length;
  int get numberOfLight => lightParticles.length;
  int get numberOfParticles => numberOfHeavy + numberOfLight;

  List<List<GasParticle>> get insideParticleArrays =>
      [heavyParticles, lightParticles];

  void setNumberHeavy(int n) => _updateCount(
        n.clamp(GasesIntroConstants.particleMin, GasesIntroConstants.particleMax),
        heavyParticles,
        ParticleKind.heavy,
      );

  void setNumberLight(int n) => _updateCount(
        n.clamp(GasesIntroConstants.particleMin, GasesIntroConstants.particleMax),
        lightParticles,
        ParticleKind.light,
      );

  void addHeavy(int delta) => setNumberHeavy(numberOfHeavy + delta);
  void addLight(int delta) => setNumberLight(numberOfLight + delta);

  void _updateCount(int newValue, List<GasParticle> particles, ParticleKind kind) {
    final delta = newValue - particles.length;
    if (delta > 0) {
      addParticles(delta, particles, kind);
    } else if (delta < 0) {
      particles.removeRange(particles.length + delta, particles.length);
    }
  }

  /// Inject angle π−π/4+U·(π/2); |v|=√(3kT/m).
  void addParticles(int n, List<GasParticle> particles, ParticleKind kind) {
    assert(n > 0);
    final meanT = getInitialTemperature();
    final temperatures = (n == 1 || !collisionsEnabled)
        ? List<double>.filled(n, meanT)
        : random.getGaussianValues(n, meanT, 0.2 * meanT);

    final dispersion = GasesIntroConstants.particleDispersionAngle;
    for (var i = 0; i < n; i++) {
      final particle =
          kind == ParticleKind.heavy ? GasParticle.heavy() : GasParticle.light();
      particle.setPosition(
        container.particleEntryX - particle.radius,
        container.particleEntryY,
      );
      particle.prevX = particle.x;
      particle.prevY = particle.y;

      final speed = math.sqrt(
        3 * GasesIntroConstants.boltzmann * temperatures[i] / particle.mass,
      );
      final angle =
          math.pi - dispersion / 2 + random.nextDouble() * dispersion;
      particle.setVelocityPolar(speed, angle);
      particles.add(particle);
    }
  }

  /// v' = v (1 + f/800)
  void heatCool(double heatCoolFactor) {
    if (heatCoolFactor == 0) return;
    final scale = 1 + heatCoolFactor / GasesIntroConstants.heatCoolDivisor;
    for (final p in heavyParticles) {
      p.scaleVelocity(scale);
    }
    for (final p in lightParticles) {
      p.scaleVelocity(scale);
    }
  }

  void step(double dt) {
    for (final p in heavyParticles) {
      p.step(dt);
    }
    for (final p in lightParticles) {
      p.step(dt);
    }
  }

  /// Simplified escape: open + above top in opening → remove.
  void escapeParticles() {
    if (!container.isOpen) return;
    _escape(heavyParticles);
    _escape(lightParticles);
  }

  void _escape(List<GasParticle> particles) {
    final oL = container.getOpeningLeft();
    final oR = container.getOpeningRight();
    for (var i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      if (p.top > container.top && p.left > oL && p.right < oR) {
        particles.removeAt(i);
      }
    }
  }

  void redistributeParticles(double scaleX) {
    assert(scaleX > 0);
    for (final p in heavyParticles) {
      p.x *= scaleX;
    }
    for (final p in lightParticles) {
      p.x *= scaleX;
    }
  }

  void setTemperature(double temperature) {
    if (numberOfParticles == 0) return;
    final desiredAvg =
        (3 / 2) * temperature * GasesIntroConstants.boltzmann;
    final actualAvg = averageKineticEnergy;
    if (actualAvg <= 0) return;
    final ratio = desiredAvg / actualAvg;
    for (final list in insideParticleArrays) {
      for (final p in list) {
        final desiredKe = ratio * p.kineticEnergy;
        p.setSpeed(math.sqrt(2 * desiredKe / p.mass));
      }
    }
  }

  double get averageKineticEnergy {
    final n = numberOfParticles;
    if (n == 0) return 0;
    return totalKineticEnergy / n;
  }

  double getAverageKineticEnergy() => averageKineticEnergy;

  double get totalKineticEnergy {
    var s = 0.0;
    for (final p in heavyParticles) {
      s += p.kineticEnergy;
    }
    for (final p in lightParticles) {
      s += p.kineticEnergy;
    }
    return s;
  }

  void eraseAll() {
    heavyParticles.clear();
    lightParticles.clear();
  }

  void reset() => eraseAll();
}
