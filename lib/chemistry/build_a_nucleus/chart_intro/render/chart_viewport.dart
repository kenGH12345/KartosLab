/// 核素图可见窗：由 [ChartFocusMemory] + 格子边长算出。
///
/// 不是 `Canvas.scale`。[已确认] 三套独立 ChartTransform（18 / 10 / 30）。
/// Painter 只消费本对象，不自己改 focus。
library;

import 'package:flutter/material.dart';

import '../../ban_constants.dart';
import '../chart_intro_visuals.dart';
import 'chart_focus_memory.dart';
import 'nuclide_chart_render.dart';

enum NuclideChartPresentation {
  /// Partial 全图 + 数轴。[已确认] `selected === 'partial'`
  partial,

  /// 全图 + 5×5 高亮 + 窗外变淡。[已确认] `FocusedNuclideChartNode`
  focused,

  /// clip 到 5×5。[已确认] `ZoomInNuclideChartNode`
  zoomIn,
}

class ChartViewport {
  const ChartViewport({
    required this.focusProton,
    required this.focusNeutron,
    required this.zoomCenterProton,
    required this.zoomCenterNeutron,
    required this.highlightLocal,
    required this.clipLocal,
    required this.dimAnchorProton,
    required this.dimAnchorNeutron,
    required this.cellSize,
  });

  factory ChartViewport.from(
    ChartFocusMemory memory, {
    required double cellSize,
  }) {
    final fp = memory.proton;
    final fn = memory.neutron;
    final zoomP = fp.clamp(
      ChartIntroVisuals.zoomClampProtonMin,
      ChartIntroVisuals.zoomClampProtonMax,
    );
    final zoomN = fn.clamp(
      ChartIntroVisuals.zoomClampNeutronMin,
      ChartIntroVisuals.zoomClampNeutronMax,
    );

    final desired = Rect.fromCenter(
      center: _cellCenter(fp, fn, cellSize),
      width: BanConstants.zoomInChartSquareLength * cellSize,
      height: BanConstants.zoomInChartSquareLength * cellSize,
    );
    final highlight = _shiftToFit(desired, cellSize);
    final dimN = highlight.center.dx / cellSize - 0.5;
    final dimP = NuclideChartRender.maxProton + 0.5 - highlight.center.dy / cellSize;

    final clip = Rect.fromLTWH(
      (zoomN - 2) * cellSize,
      (NuclideChartRender.maxProton - (zoomP + 2)) * cellSize,
      BanConstants.zoomInChartSquareLength * cellSize,
      BanConstants.zoomInChartSquareLength * cellSize,
    );

    return ChartViewport(
      focusProton: fp,
      focusNeutron: fn,
      zoomCenterProton: zoomP,
      zoomCenterNeutron: zoomN,
      highlightLocal: highlight,
      clipLocal: clip,
      dimAnchorProton: dimP,
      dimAnchorNeutron: dimN,
      cellSize: cellSize,
    );
  }

  final int focusProton;
  final int focusNeutron;
  final int zoomCenterProton;
  final int zoomCenterNeutron;
  final Rect highlightLocal;
  final Rect clipLocal;
  final double dimAnchorProton;
  final double dimAnchorNeutron;
  final double cellSize;

  bool containsCell(int proton, int neutron) {
    final dP = (proton - dimAnchorProton).abs();
    final dN = (neutron - dimAnchorNeutron).abs();
    return dP <= ChartIntroVisuals.focusedDimDelta &&
        dN <= ChartIntroVisuals.focusedDimDelta;
  }

  double opacityFor(int proton, int neutron) =>
      containsCell(proton, neutron) ? 1 : ChartIntroVisuals.focusedDimOpacity;

  static Offset _cellCenter(int proton, int neutron, double cellSize) =>
      Offset(
        (neutron + 0.5) * cellSize,
        (NuclideChartRender.maxProton - proton + 0.5) * cellSize,
      );

  static Size _gridSize(double cellSize) => Size(
        (NuclideChartRender.maxNeutron + 1) * cellSize,
        (NuclideChartRender.maxProton + 1) * cellSize,
      );

  /// 保持 5×5 正方形，整窗平移贴边。[已确认] 先 left / right / top / bottom
  static Rect _shiftToFit(Rect rect, double cellSize) {
    final bounds = Offset.zero & _gridSize(cellSize);
    var out = rect;
    if (out.left < bounds.left) {
      out = out.shift(Offset(bounds.left - out.left, 0));
    }
    if (out.right > bounds.right) {
      out = out.shift(Offset(bounds.right - out.right, 0));
    }
    if (out.top < bounds.top) {
      out = out.shift(Offset(0, bounds.top - out.top));
    }
    if (out.bottom > bounds.bottom) {
      out = out.shift(Offset(0, bounds.bottom - out.bottom));
    }
    return out;
  }
}
