/// Model-view transform.
///
/// [已确认] `ModelViewTransform2.createSinglePointScaleInvertedYMapping(
///   ZERO, layoutCenter, zoomScale)`
library;

import 'package:flutter/material.dart';

import '../model/kl_vec.dart';

class KeplersMvt {
  const KeplersMvt({
    required this.center,
    required this.scale,
  });

  /// View-space location of model origin (the sun).
  final Offset center;

  /// View pixels per model unit. Default 100.
  final double scale;

  Offset toView(KlVec model) => Offset(
        center.dx + model.x * scale,
        center.dy - model.y * scale,
      );

  double toViewDelta(double model) => model * scale;

  KlVec toModel(Offset view) => KlVec(
        (view.dx - center.dx) / scale,
        (center.dy - view.dy) / scale,
      );
}
