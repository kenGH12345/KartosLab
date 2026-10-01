/// Bucket holding idle particles — phetcommon `SphereBucket` semantics subset.
library;

import 'baa_particle.dart';

/// Typed particle bucket with exclusive ownership vs the atom.
class ParticleBucket {
  ParticleBucket({
    required this.type,
    required this.maxCount,
  });

  final BaaParticleType type;
  final int maxCount;

  final List<BaaParticle> _particles = <BaaParticle>[];

  List<BaaParticle> get particles => List.unmodifiable(_particles);

  int get count => _particles.length;

  int get availableCount => count;

  bool get isEmpty => _particles.isEmpty;

  bool get isFull => _particles.length >= maxCount;

  bool contains(BaaParticle p) => _particles.contains(p);

  /// Add to first open slot (append). Marks container = bucket.
  void addParticleFirstOpen(BaaParticle particle, {bool animate = false}) {
    assert(particle.type == type, 'Particle type mismatch');
    assert(!_particles.contains(particle), 'Particle already in bucket');
    particle.container = BaaParticleContainer.bucket;
    particle.electronShellIndex = null;
    particle.isDragging = false;
    _particles.add(particle);
    // animate reserved for View; model snaps.
    if (!animate) {
      // destination left for View layout; identity ownership is what matters.
    }
  }

  /// Nearest-open placement (same ownership semantics as first-open for Phase 1).
  void addParticleNearestOpen(BaaParticle particle, {bool animate = true}) {
    addParticleFirstOpen(particle, animate: animate);
  }

  /// Remove without disposing. Clears container.
  void removeParticle(BaaParticle particle) {
    final ok = _particles.remove(particle);
    assert(ok, 'Particle not in this bucket');
    if (particle.container == BaaParticleContainer.bucket) {
      particle.container = null;
    }
  }

  /// Extract particle closest to [atomX],[atomY] (for setAtomConfiguration).
  BaaParticle? extractClosestParticle(double atomX, double atomY) {
    if (_particles.isEmpty) return null;
    BaaParticle? best;
    var bestD = double.infinity;
    for (final p in _particles) {
      final d = p.distanceTo(atomX, atomY);
      if (d < bestD) {
        bestD = d;
        best = p;
      }
    }
    if (best != null) {
      removeParticle(best);
    }
    return best;
  }

  void reset() {
    _particles.clear();
  }
}
