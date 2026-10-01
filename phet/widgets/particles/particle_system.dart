/// PhET Particle System — manages a collection of [Particle]s, updating and
/// rendering them.
///
/// Used for electrons, gas molecules, fluid particles, photons, etc.
library;

import 'package:flutter/material.dart';
import 'particle.dart';

class ParticleSystem {
  final List<Particle> particles = [];

  /// Add a particle to the system.
  void add(Particle p) => particles.add(p);

  /// Add n particles with the same template.
  void addAll(int n, Particle Function(int i) factory) {
    for (int i = 0; i < n; i++) {
      particles.add(factory(i));
    }
  }

  /// Advance all particles by dt seconds.
  void update(double dt) {
    for (final p in particles) {
      p.update(dt);
    }
    particles.removeWhere((p) => !p.alive);
  }

  /// Draw all particles on canvas.
  void draw(Canvas canvas) {
    for (final p in particles) {
      p.draw(canvas);
    }
  }

  /// Remove all particles.
  void clear() => particles.clear();

  /// Number of active particles.
  int get count => particles.length;

  /// Reset: remove all particles and reset state.
  void reset() => clear();
}

/// A painter that renders a [ParticleSystem].
class ParticleSystemPainter extends CustomPainter {
  final ParticleSystem system;
  const ParticleSystemPainter(this.system);

  @override
  void paint(Canvas canvas, Size size) {
    system.draw(canvas);
  }

  @override
  bool shouldRepaint(ParticleSystemPainter old) => true;
}
