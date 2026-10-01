/// Chart Intro 本地投影。不用 Decay 的 [CanvasProjection]
/// （其 origin 钉在画布中心 0.55，能级原点在左上）。
///
/// 坐标仍一律经 [toScreen]，不在 Painter 里手写 `* zoom + origin`。
library;

import 'package:flutter/material.dart';

class ChartIntroProjection {
  const ChartIntroProjection({
    required this.origin,
    this.scale = 1,
  });

  /// 模型原点落在画布上的位置。
  final Offset origin;
  final double scale;

  Offset toScreen(Offset model) =>
      Offset(origin.dx + model.dx * scale, origin.dy + model.dy * scale);

  double toScreenLength(double world) => world * scale;
}
