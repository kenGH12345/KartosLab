/// Runtime nucleon particle — shred `Particle` subset for Make Isotopes.
///
/// Identity is stable across bucket ↔ nucleus transfers.
/// Position / destination are in model coordinates (layoutBounds space).
library;

import 'iaam_vec2.dart';

enum NucleonKind { proton, neutron }

/// Where a neutron currently "belongs" when not mid-drag.
enum NeutronContainer { bucket, nucleus }

class NucleonParticle {
  NucleonParticle({
    required this.id,
    required this.kind,
    double x = 0,
    double y = 0,
  })  : _x = x,
        _y = y,
        _destX = x,
        _destY = y;

  final int id;
  final NucleonKind kind;

  double _x;
  double _y;
  double _destX;
  double _destY;

  /// shred `Particle.zLayerProperty` — higher = further back; drag uses 0.
  int zLayer = 0;

  /// shred `Particle.isDraggingProperty`.
  bool isDragging = false;

  /// Bucket or nucleus; `null` while mid-drag (PhET `containerProperty = null`).
  NeutronContainer? container = NeutronContainer.nucleus;

  double get x => _x;
  double get y => _y;
  IaamVec2 get position => IaamVec2(_x, _y);

  double get destX => _destX;
  double get destY => _destY;
  IaamVec2 get destination => IaamVec2(_destX, _destY);

  void setPosition(double x, double y) {
    _x = x;
    _y = y;
  }

  void setDestination(double x, double y) {
    _destX = x;
    _destY = y;
  }

  /// Snap both position and destination (no animation in Phase 3).
  void placeAt(double x, double y) {
    _x = x;
    _y = y;
    _destX = x;
    _destY = y;
  }
}
