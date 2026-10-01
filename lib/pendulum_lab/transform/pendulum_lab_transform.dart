import 'package:flutter/material.dart';

import '../model/pl_vector2.dart';
import '../pl_constants.dart';

/// PhET `ModelViewTransform2.createSinglePointScaleInvertedYMapping`.
class PendulumLabTransform {
  const PendulumLabTransform();

  Offset get origin => PlConstants.mvtOrigin;
  double get scale => PlConstants.mvtScale;

  Offset modelToView(PlVector2 p) => Offset(
        origin.dx + scale * p.x,
        origin.dy - scale * p.y,
      );

  PlVector2 viewToModel(Offset v) => PlVector2(
        (v.dx - origin.dx) / scale,
        (origin.dy - v.dy) / scale,
      );

  double modelToViewDeltaX(double dx) => scale * dx;

  double viewToModelDeltaX(double dx) => dx / scale;
}
