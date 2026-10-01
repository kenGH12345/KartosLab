/// Y-up model-view transform.
///
/// [Kepler二次] `createSinglePointScaleInvertedYMapping(ZERO, layoutCenter, zoomScale)`
/// V1 忽略 [MSS] `centerOrbitOffset: (100,100)`。
library;

import 'package:flutter/material.dart';

import '../model/mss_vec.dart';

class MssMvt {
  const MssMvt({required this.center, required this.scale});

  final Offset center;
  final double scale;

  Size get canvasSize => Size(center.dx * 2, center.dy * 2);

  Offset toView(MssVec model) => Offset(
        center.dx + model.x * scale,
        center.dy - model.y * scale,
      );

  double toViewDelta(double model) => model * scale;

  /// Screen (logical px) → world. Flutter `localPosition` 已是逻辑像素，不再乘 DPR。
  MssVec toModel(Offset view) => MssVec(
        (view.dx - center.dx) / scale,
        (center.dy - view.dy) / scale,
      );

  double toModelDelta(double view) => view / scale;
}
