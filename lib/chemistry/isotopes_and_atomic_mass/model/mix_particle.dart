/// Mix isotope atom — shred/IAAM `PositionableAtom` spatial subset.
library;

import 'iaam_vec2.dart';

enum MixParticleContainer { bucket, chamber }

class MixParticle {
  MixParticle({
    required this.id,
    required this.massNumber,
    required this.radius,
    double x = 0,
    double y = 0,
    this.container = MixParticleContainer.bucket,
  })  : _x = x,
        _y = y,
        _destX = x,
        _destY = y;

  final int id;
  final int massNumber;
  final double radius;

  double _x;
  double _y;
  double _destX;
  double _destY;

  MixParticleContainer? container; // null while dragging
  bool isDragging = false;

  double get x => _x;
  double get y => _y;
  IaamVec2 get position => IaamVec2(_x, _y);

  double get destX => _destX;
  double get destY => _destY;
  IaamVec2 get destination => IaamVec2(_destX, _destY);

  void placeAt(double x, double y) {
    _x = x;
    _y = y;
    _destX = x;
    _destY = y;
  }

  void setPosition(double x, double y) {
    _x = x;
    _y = y;
  }

  void setDestination(double x, double y) {
    _destX = x;
    _destY = y;
  }
}

/// Saved chamber particle for Z+mode restore (PhET saves PositionableAtom refs).
class SavedMixParticle {
  const SavedMixParticle({
    required this.massNumber,
    required this.x,
    required this.y,
    required this.radius,
  });

  final int massNumber;
  final double x;
  final double y;
  final double radius;
}
