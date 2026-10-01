import 'package:flutter/painting.dart';

import '../bending_light_constants.dart';
import '../model/bl_vec2.dart';
import '../transform/bl_mvt.dart';

/// `MoreToolsScreenView` arrowScale.
const double velocityArrowScale = 1.5e-14;

/// View delta of the velocity arrow. Y is flipped by [BlMvt.modelToViewDelta].
/// The body node then scales by 0.7, matching `bodyNode.setScaleMagnitude(0.7)`.
Offset velocityArrowViewDelta(BlMvt mvt, BlVec2 velocity) {
  final d = mvt.modelToViewDelta(velocity);
  return Offset(d.dx * velocityArrowScale, d.dy * velocityArrowScale);
}

/// `{0} c` or `?` when magnitude is 0 (`VelocitySensorNode`).
String velocityReadout(BlVec2 velocity) {
  if (velocity.magnitude == 0) return '?';
  final fraction = velocity.magnitude / BendingLightConstants.speedOfLight;
  return '${fraction.toStringAsFixed(2)} c';
}
