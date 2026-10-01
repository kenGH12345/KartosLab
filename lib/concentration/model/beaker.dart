import 'dart:ui';

import 'concentration_constants.dart';

/// Beaker geometry — beers-law-lab `Beaker.ts`.
class Beaker {
  Beaker({
    Offset? position,
    Size? size,
    this.volume = ConcentrationConstants.beakerVolume,
  })  : position = position ?? ConcentrationConstants.beakerPosition,
        size = size ?? ConcentrationConstants.beakerSize;

  final Offset position;
  final Size size;
  final double volume; // L capacity

  double get left => position.dx - size.width / 2;
  double get right => position.dx + size.width / 2;
}
