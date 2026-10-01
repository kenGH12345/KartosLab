import 'dart:math' as math;

import '../gas_properties_constants.dart';
import '../model/container_state.dart';
import '../model/particle.dart';
import '../model/particle_type.dart';
import '../model/random_source.dart';

/// IdealGasLawParticleSystem — inject / heat / escape / redistribute.
class ParticleSystem {
  ParticleSystem({
    required this.getInitialTemperature,
    required this.container,
    RandomSource? random,
  }) : random = random ?? RandomSource();

  final double Function() getInitialTemperature;
  final ContainerState container;
  final RandomSource random;

  final List<Particle> heavyParticles = [];
  final List<Particle> lightParticles = [];
  final List<Particle> heavyOutside = [];
  final List<Particle> lightOutside = [];

  bool collisionsEnabled = true;
  int _nextId = 1;

  int get numberOfHeavy => heavyParticles.length;
  int get numberOfLight => lightParticles.length;
  int get numberOfParticles => numberOfHeavy + numberOfLight;

  List<List<Particle>> get insideParticleArrays =>
      [heavyParticles, lightParticles];

  void setNumberHeavy(int n) => _updateCount(
        n.clamp(
          GasPropertiesConstants.particleMin,
          GasPropertiesConstants.particleMax,
        ),
        heavyParticles,
        ParticleType.heavy,
      );

  void setNumberLight(int n) => _updateCount(
        n.clamp(
          GasPropertiesConstants.particleMin,
          GasPropertiesConstants.particleMax,
        ),
        lightParticles,
        ParticleType.light,
      );

  void addHeavy(int delta) => setNumberHeavy(numberOfHeavy + delta);
  void addLight(int delta) => setNumberLight(numberOfLight + delta);

  void _updateCount(int newValue, List<Particle> particles, ParticleType type) {
    final delta = newValue - particles.length;
    if (delta > 0) {
      addParticles(delta, particles, type);
    } else if (delta < 0) {
      particles.removeRange(particles.length + delta, particles.length);
    }
  }

  /// |v| = √(3kT/m); angle in pump dispersion cone π/2.
  void addParticles(int n, List<Particle> particles, ParticleType type) {
    assert(n > 0);
    final meanT = getInitialTemperature();
    final temperatures = (n == 1 || !collisionsEnabled)
        ? List<double>.filled(n, meanT)
        : random.getGaussianValues(n, meanT, 0.2 * meanT);

    final dispersion = GasPropertiesConstants.particleDispersionAngle;
    for (var i = 0; i < n; i++) {
      final particle = Particle.create(id: _nextId++, type: type);
      particle.setPosition(
        container.particleEntryX - particle.radius,
        container.particleEntryY,
      );
      particle.prevX = particle.x;
      particle.prevY = particle.y;

      final speed = math.sqrt(
        3 *
            GasPropertiesConstants.boltzmann *
            temperatures[i] /
            particle.mass,
      );
      final angle =
          math.pi - dispersion / 2 + random.nextDouble() * dispersion;
      particle.setVelocityPolar(speed, angle);
      particles.add(particle);
    }
  }

  /// v' = v · (1 + f/800)
  void heatCool(double heatCoolFactor) {
    if (heatCoolFactor == 0) return;
    final scale =
        1 + heatCoolFactor / GasPropertiesConstants.heatCoolDivisor;
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
    for (final p in heavyOutside) {
      p.step(dt);
    }
    for (final p in lightOutside) {
      p.step(dt);
    }
  }

  void escapeParticles() {
    if (!container.isOpen) return;
    _escape(heavyParticles, heavyOutside);
    _escape(lightParticles, lightOutside);
  }

  void _escape(List<Particle> inside, List<Particle> outside) {
    final oL = container.getOpeningLeft();
    final oR = container.getOpeningRight();
    for (var i = inside.length - 1; i >= 0; i--) {
      final p = inside[i];
      if (p.top > container.top && p.left > oL && p.right < oR) {
        inside.removeAt(i);
        outside.add(p);
      }
    }
  }

  void removeParticlesOutOfBounds({
    required double minX,
    required double minY,
    required double maxX,
    required double maxY,
  }) {
    _removeOob(heavyOutside, minX, minY, maxX, maxY);
    _removeOob(lightOutside, minX, minY, maxX, maxY);
  }

  void _removeOob(
    List<Particle> particles,
    double minX,
    double minY,
    double maxX,
    double maxY,
  ) {
    for (var i = particles.length - 1; i >= 0; i--) {
      if (!particles[i].intersectsBounds(minX, minY, maxX, maxY)) {
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
        (3 / 2) * temperature * GasPropertiesConstants.boltzmann;
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
    heavyOutside.clear();
    lightOutside.clear();
  }

  void reset() {
    eraseAll();
    collisionsEnabled = true;
  }
}
