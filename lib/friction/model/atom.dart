import 'dart:math' as math;
import 'dart:ui' show Offset;

import '../friction_constants.dart';
import 'friction_model.dart';

/// Port of PhET `Atom.js`.
class FrictionAtom {
  FrictionAtom({
    required this.initialPosition,
    required this.model,
    required this.isTopAtom,
  })  : centerPosition = Offset(initialPosition.dx, initialPosition.dy),
        position = Offset(initialPosition.dx, initialPosition.dy);

  final Offset initialPosition;
  final FrictionModel model;
  final bool isTopAtom;

  bool isShearedOff = false;
  Offset centerPosition;
  Offset position;
  Offset shearingVelocity = Offset.zero;

  void onTopBookMoved(Offset delta) {
    if (!isShearedOff && isTopAtom) {
      centerPosition = centerPosition + delta;
    }
  }

  void shearOff(math.Random random) {
    assert(!isShearedOff, 'Atom already sheared off');
    isShearedOff = true;
    final shearingDestinationX = model.width * (random.nextBool() ? 1.0 : -1.0);
    final shearingDestinationY =
        position.dy - model.distanceBetweenBooks * random.nextDouble();
    final dest = Offset(shearingDestinationX, shearingDestinationY);
    final delta = dest - position;
    final mag = delta.distance;
    if (mag > 1e-9) {
      shearingVelocity = delta * (FrictionConstants.shearOffSpeed / mag);
    } else {
      shearingVelocity = Offset(FrictionConstants.shearOffSpeed, 0);
    }
  }

  void reset() {
    centerPosition = Offset(initialPosition.dx, initialPosition.dy);
    position = Offset(initialPosition.dx, initialPosition.dy);
    isShearedOff = false;
    shearingVelocity = Offset.zero;
  }

  void step(double dt, math.Random random) {
    final amp = model.vibrationAmplitude;
    position = Offset(
      centerPosition.dx + amp * (random.nextDouble() - 0.5),
      centerPosition.dy + amp * (random.nextDouble() - 0.5),
    );

    if (isShearedOff && centerPosition.dx.abs() < 4 * model.width) {
      centerPosition = Offset(
        centerPosition.dx + shearingVelocity.dx * dt,
        centerPosition.dy + shearingVelocity.dy * dt,
      );
    }
  }
}
