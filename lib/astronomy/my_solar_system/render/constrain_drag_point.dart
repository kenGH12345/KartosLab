/// Isolated drag clamp. Replace when `solar-system-common` is available.
library;

import 'dart:math' as math;
import 'dart:ui';

import '../model/mss_vec.dart';
import 'mss_mvt.dart';

/// Maps a proposed model point into an allowed region.
///
/// [Kepler二次 / BLOCKED 精确算法]
/// 父类 `SolarSystemCommonScreenView.constrainDragPoint` 不在本树。Kepler 笔记描述为：
/// interfaceBounds 按半径侵蚀后，减去各面板扩到边的矩形；点在外则
/// `shape.getClosestPoint`。MSS `getDragBoundsItems` 还包含 topRightVBox / zoom /
/// values / bodies spinner / follow CoM。
///
/// **本函数不实现 closest-point 挖空**（用户要求：无法确认则不编造）。
/// [临时] 只把点夹在画布对应的轴对齐模型矩形内（可选侵蚀视觉半径）。
MssVec constrainDragPoint({
  required MssVec modelPoint,
  required Size canvasSize,
  required MssMvt mvt,
  double bodyRadiusView = 0,
}) {
  final inset = bodyRadiusView.clamp(0.0, math.min(canvasSize.width, canvasSize.height) / 2);
  final minView = Offset(inset, inset);
  final maxView = Offset(
    math.max(inset, canvasSize.width - inset),
    math.max(inset, canvasSize.height - inset),
  );
  final a = mvt.toModel(minView);
  final b = mvt.toModel(maxView);
  final minX = math.min(a.x, b.x);
  final maxX = math.max(a.x, b.x);
  final minY = math.min(a.y, b.y);
  final maxY = math.max(a.y, b.y);
  return MssVec(
    modelPoint.x.clamp(minX, maxX),
    modelPoint.y.clamp(minY, maxY),
  );
}
