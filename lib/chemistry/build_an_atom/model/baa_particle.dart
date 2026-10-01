/// Subatomic particle identity — shred `Particle` / BAA `BAAParticle` subset.
library;

import 'dart:math' as math;

/// Particle species used by Build an Atom.
enum BaaParticleType { proton, neutron, electron }

/// Exclusive ownership of a particle at rest (not mid-drag).
enum BaaParticleContainer { bucket, atom }

/// One physical particle instance. At most one container at a time.
class BaaParticle {
  BaaParticle({
    required this.id,
    required this.type,
    double x = 0,
    double y = 0,
  })  : _x = x,
        _y = y,
        _destX = x,
        _destY = y;

  final int id;
  final BaaParticleType type;

  double _x;
  double _y;
  double _destX;
  double _destY;

  /// shred `zLayerProperty`.
  int zLayer = 0;

  /// Mid-drag flag (`isDraggingProperty`).
  bool isDragging = false;

  /// `null` while dragging; otherwise bucket or atom.
  BaaParticleContainer? container = BaaParticleContainer.bucket;

  /// Electron shell slot index when in atom (0..9); null for nucleons / free.
  int? electronShellIndex;

  double get x => _x;
  double get y => _y;
  double get destX => _destX;
  double get destY => _destY;

  bool get isProton => type == BaaParticleType.proton;
  bool get isNeutron => type == BaaParticleType.neutron;
  bool get isElectron => type == BaaParticleType.electron;
  bool get isNucleon => isProton || isNeutron;

  void setPosition(double x, double y) {
    _x = x;
    _y = y;
  }

  void setDestination(double x, double y) {
    _destX = x;
    _destY = y;
  }

  void placeAt(double x, double y) {
    _x = x;
    _y = y;
    _destX = x;
    _destY = y;
  }

  void moveImmediatelyToDestination() {
    _x = _destX;
    _y = _destY;
  }

  double distanceTo(double ox, double oy) {
    final dx = _x - ox;
    final dy = _y - oy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Move toward destination at [speed] model-units/second (shred `Particle.step`).
  void stepTowardDestination(double dt, double speed) {
    final dx = _destX - _x;
    final dy = _destY - _y;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 1e-6) {
      moveImmediatelyToDestination();
      return;
    }
    final step = speed * dt;
    if (step >= dist) {
      moveImmediatelyToDestination();
    } else {
      setPosition(_x + dx / dist * step, _y + dy / dist * step);
    }
  }
}
