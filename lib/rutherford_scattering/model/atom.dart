import 'dart:math' as math;

import 'alpha_particle.dart';
import 'rs_geometry.dart';

/// Base atom — port of PhET Atom.ts
abstract class Atom {
  Atom(this.position, this.boundingWidth)
      : boundingRect = RsRect(position, boundingWidth),
        boundingCircle = RsCircle(
          position,
          math.sqrt(2) * (boundingWidth / 2),
        );

  final RsVec2 position;
  final double boundingWidth;
  final RsRect boundingRect;
  final RsCircle boundingCircle;
  final List<AlphaParticle> particles = <AlphaParticle>[];

  void addParticle(AlphaParticle alphaParticle) {
    particles.add(alphaParticle);
    alphaParticle.initialPosition = alphaParticle.position;
  }

  void removeParticle(AlphaParticle alphaParticle) {
    particles.remove(alphaParticle);
  }

  void removeAllParticles() {
    particles.clear();
  }

  void moveParticles(double dt) {
    // Copy to avoid concurrent modification if remove during move.
    final snapshot = List<AlphaParticle>.from(particles);
    for (final p in snapshot) {
      moveParticle(p, dt);
    }
  }

  void moveParticle(AlphaParticle alphaParticle, double dt);
}
