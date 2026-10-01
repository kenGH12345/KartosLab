import 'dart:math' as math;

import 'alpha_particle.dart';
import 'atom.dart';
import 'rs_geometry.dart';

/// Atom space — port of PhET AtomSpace.ts
class AtomSpace {
  AtomSpace({
    required this.bounds,
    double? atomWidth,
  }) : atomWidth = atomWidth ?? bounds.width;

  final List<Atom> atoms = <Atom>[];
  final List<AlphaParticle> particles = <AlphaParticle>[];
  final List<AlphaParticle> particlesInEmptySpace = <AlphaParticle>[];
  final RsBounds2 bounds;
  final double atomWidth;

  /// Callback when algorithm fails and particle must leave model entirely.
  void Function(AlphaParticle particle)? onParticleRemovedFromAtom;

  bool isVisible = true;

  void addParticle(AlphaParticle alphaParticle) {
    particles.add(alphaParticle);
    _addParticleToEmptySpace(alphaParticle);
  }

  void _addParticleToEmptySpace(AlphaParticle alphaParticle) {
    alphaParticle.isInSpace = true;
    if (!particlesInEmptySpace.contains(alphaParticle)) {
      particlesInEmptySpace.add(alphaParticle);
    }
  }

  void removeParticle(AlphaParticle alphaParticle) {
    particles.remove(alphaParticle);
    _removeParticleFromEmptySpace(alphaParticle);
  }

  void _removeParticleFromEmptySpace(AlphaParticle alphaParticle) {
    if (particlesInEmptySpace.remove(alphaParticle)) {
      alphaParticle.isInSpace = false;
    }
  }

  void removeAllParticles() {
    particles.clear();
    particlesInEmptySpace.clear();
  }

  void transitionParticlesToAtoms() {
    final emptySnapshot = List<AlphaParticle>.from(particlesInEmptySpace);
    for (final particle in emptySnapshot) {
      for (final atom in atoms) {
        if (particle.preparedAtom != atom &&
            atom.boundingCircle.containsPoint(particle.position)) {
          particle.prepareBoundingBox(atom);
          particle.preparedAtom = atom;
        }

        if (particle.preparedBoundingBox != null) {
          if (particle.preparedBoundingBox!.containsPoint(particle.position) &&
              particle.atom != particle.preparedAtom) {
            particle.atom?.removeParticle(particle);
            particle.atom = particle.preparedAtom;
            particle.preparedAtom!.addParticle(particle);
            particle.boundingBox = particle.preparedBoundingBox;
            particle.rotationAngle = particle.preparedRotationAngle!;
            _removeParticleFromEmptySpace(particle);
          }
        }
      }
    }
  }

  void transitionParticlesToSpace() {
    for (final particle in particles) {
      if (!particle.isInSpace) {
        final atom = particle.atom;
        if (atom != null &&
            !atom.boundingCircle.containsPoint(particle.position)) {
          _addParticleToEmptySpace(particle);
        }
      }
    }
  }

  void moveParticles(double dt) {
    transitionParticlesToAtoms();
    transitionParticlesToSpace();

    for (final alphaParticle in particles) {
      if (alphaParticle.atom == null) {
        final speed = alphaParticle.speed;
        final distance = speed * dt;
        final direction = alphaParticle.orientation;
        final dx = math.cos(direction) * distance;
        final dy = math.sin(direction) * distance;
        final p = alphaParticle.position;
        alphaParticle.setPosition(RsVec2(p.x + dx, p.y + dy));
      }
    }

    for (final atom in atoms) {
      atom.moveParticles(dt);
    }
  }

  /// Notify base model that particle should be fully removed (error path).
  void emitParticleRemovedFromAtom(AlphaParticle particle) {
    onParticleRemovedFromAtom?.call(particle);
  }
}
