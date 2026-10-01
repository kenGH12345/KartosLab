import 'dart:ui';

import 'abs_constants.dart';

/// Beaker geometry — PhET `Beaker.ts`.
///
/// Origin is bottom-center. Volume is **not** a mutable Property; the beaker
/// is always shown full with a visual 1 L mark (`BeakerNode`).
class AbsBeaker {
  AbsBeaker({
    Size? size,
    Offset? position,
  })  : size = size ?? AbsConstants.beakerSize,
        position = position ?? AbsConstants.beakerPosition;

  /// Dimensions excluding the rim.
  final Size size;

  /// Bottom-center of the beaker (model ≡ view coordinates).
  final Offset position;

  double get left => position.dx - size.width / 2;
  double get right => left + size.width;
  double get bottom => position.dy;
  double get top => bottom - size.height;

  Rect get bounds => Rect.fromLTRB(left, top, right, bottom);

  bool containsPoint(Offset point) => bounds.contains(point);
}
