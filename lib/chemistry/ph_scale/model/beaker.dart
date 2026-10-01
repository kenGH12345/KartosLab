import 'dart:ui';

import 'ph_scale_constants.dart';

/// Simple beaker geometry — PhET `Beaker.ts`.
class Beaker {
  Beaker({
    Offset? position,
    this.volume = PhScaleConstants.beakerVolume,
    Size? size,
  })  : position = position ?? PhScaleConstants.beakerPosition,
        size = size ?? PhScaleConstants.beakerSize;

  final Offset position;
  final double volume; // L
  final Size size;

  double get left => position.dx - size.width / 2;
  double get right => position.dx + size.width / 2;

  /// Model bounds: left..right, top = y−height, bottom = y.
  Rect get bounds => Rect.fromLTRB(
        left,
        position.dy - size.height,
        right,
        position.dy,
      );
}
