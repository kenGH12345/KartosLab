import 'package:flutter/material.dart';

import '../model/mp_vector2.dart';
import '../mp_constants.dart';

/// Model coords already use +y down (same as Flutter).
/// Identity mapping with optional origin offset for layout embedding.
class MpTransform {
  const MpTransform({
    this.origin = Offset.zero,
    this.scale = 1,
  });

  final Offset origin;
  final double scale;

  /// Full-screen layout transform (model space = layout space).
  static const MpTransform identity = MpTransform();

  Offset modelToView(MpVector2 p) =>
      Offset(origin.dx + scale * p.x, origin.dy + scale * p.y);

  MpVector2 viewToModel(Offset o) => MpVector2(
        (o.dx - origin.dx) / scale,
        (o.dy - origin.dy) / scale,
      );

  double modelLengthToView(double length) => length * scale;

  static Size get layoutSize =>
      const Size(MpConstants.layoutWidth, MpConstants.layoutHeight);
}
