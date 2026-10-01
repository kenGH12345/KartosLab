/// 稀疏核素图静态 Painter。不是 `lib/common/chart` 折线图。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ban_constants.dart';
import '../../data/decay_type.dart';
import '../chart_intro_visuals.dart';
import '../render/chart_intro_projection.dart';
import '../render/chart_viewport.dart';
import '../render/nuclide_chart_render.dart';

class NuclideChartPainter extends CustomPainter {
  NuclideChartPainter({
    required this.render,
    required this.proj,
    this.axisInset = const EdgeInsets.fromLTRB(44, 16, 12, 36),
  });

  final NuclideChartRender render;
  final ChartIntroProjection proj;
  final EdgeInsets axisInset;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = render.showAxes ? axisInset : EdgeInsets.zero;
    var gridOrigin = Offset(inset.left, inset.top);
    final cell = render.cellSize;
    final clip = render.presentation == NuclideChartPresentation.zoomIn
        ? render.viewport?.clipLocal
        : null;
    if (clip != null) {
      gridOrigin -= Offset(clip.left, clip.top);
    }

    canvas.save();
    if (clip != null) {
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    for (final c in render.cells) {
      final local = render.cellTopLeft(c.protonNumber, c.neutronNumber);
      final topLeft = proj.toScreen(gridOrigin + local);
      final side = proj.toScreenLength(cell);
      final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, side, side);
      canvas.drawRect(
        rect,
        Paint()..color = c.color.withValues(alpha: c.opacity),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = proj.toScreenLength(
            ChartIntroVisuals.cellLineWidthModel * cell,
          )
          ..color = ChartIntroVisuals.cellBorder.withValues(alpha: c.opacity),
      );
    }

    if (render.presentation == NuclideChartPresentation.focused) {
      final hl = render.viewport?.highlightLocal;
      if (hl != null) {
        final topLeft = proj.toScreen(gridOrigin + hl.topLeft);
        canvas.drawRect(
          Rect.fromLTWH(
            topLeft.dx,
            topLeft.dy,
            proj.toScreenLength(hl.width),
            proj.toScreenLength(hl.height),
          ),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = ChartIntroVisuals.focusedHighlightStrokeWidth
            ..color = Colors.black,
        );
      }
    }

    if (render.showAxes) {
      _paintAxes(canvas, gridOrigin, cell);
    }

    if (render.currentExists) {
      _paintDecayDirectionArrow(canvas, gridOrigin);
      _paintCurrentLabel(canvas, gridOrigin);
    }

    canvas.restore();

    if (clip != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.black,
      );
    }
  }

  void _paintAxes(Canvas canvas, Offset gridOrigin, double cell) {
    final grid = render.gridSize;
    final origin = proj.toScreen(gridOrigin + Offset(0, grid.height));
    final right = proj.toScreen(gridOrigin + Offset(grid.width, grid.height));
    final top = proj.toScreen(gridOrigin + Offset(0, 0));

    final axis = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    canvas.drawLine(origin, right, axis);
    canvas.drawLine(origin, top, axis);
    _arrow(canvas, right, const Offset(1, 0));
    _arrow(canvas, top, const Offset(0, -1));

    for (var n = 0; n <= BanConstants.chartMaxNeutrons; n++) {
      final cx = proj.toScreen(
        gridOrigin + render.cellCenter(0, n) + Offset(0, grid.height / 2),
      );
      final selected = n == render.currentNeutron;
      _tickLabel(
        canvas,
        Offset(cx.dx, origin.dy + 4),
        '$n',
        selected: selected,
        highlight: ChartIntroVisuals.neutron,
        above: false,
      );
    }

    for (var p = 0; p <= BanConstants.chartMaxProtons; p++) {
      final cy = proj.toScreen(gridOrigin + render.cellCenter(p, 0));
      final selected = p == render.currentProton;
      _tickLabel(
        canvas,
        Offset(origin.dx - 4, cy.dy),
        '$p',
        selected: selected,
        highlight: ChartIntroVisuals.proton,
        above: true,
      );
    }

    _axisTitle(
      canvas,
      Offset((origin.dx + right.dx) / 2, origin.dy + 22),
      ChartIntroVisuals.neutronAxisLabel,
      rotate: 0,
    );
    _axisTitle(
      canvas,
      Offset(origin.dx - 32, (origin.dy + top.dy) / 2),
      ChartIntroVisuals.protonAxisLabel,
      rotate: -math.pi / 2,
    );
  }

  /// Zoom-in 当前格衰变方向箭。[已确认] `ZoomInNuclideChartNode` `arrowSymbol: true`
  /// Partial / Focused 为 false，不画。八角标签盖住箭尾。
  void _paintDecayDirectionArrow(Canvas canvas, Offset gridOrigin) {
    if (render.presentation != NuclideChartPresentation.zoomIn) return;
    final cell = render.currentCellVisual;
    if (cell == null || cell.kind != ChartCellKind.unstable) return;
    final decay = cell.decayType;
    if (decay == null) return;

    final tail = proj.toScreen(
      gridOrigin +
          render.cellCenter(render.currentProton, render.currentNeutron),
    );
    final delta = _decayDelta(decay);
    final tip = proj.toScreen(
      gridOrigin +
          render.cellCenter(
            render.currentProton + delta.$2,
            render.currentNeutron + delta.$1,
          ),
    );
    _decayArrow(canvas, tail, tip);
  }

  /// [已确认] `NuclideChartNode` 方向：n/p 发射、β±、α。
  (int, int) _decayDelta(NucleusDecayType type) {
    switch (type) {
      case NucleusDecayType.neutronEmission:
        return (-1, 0);
      case NucleusDecayType.protonEmission:
        return (0, -1);
      case NucleusDecayType.betaPlusDecay:
        return (1, -1);
      case NucleusDecayType.betaMinusDecay:
        return (-1, 1);
      case NucleusDecayType.alphaDecay:
        return (
          -ChartIntroVisuals.alphaNeutronCount,
          -ChartIntroVisuals.alphaProtonCount,
        );
    }
  }

  /// [已确认] `BANConstants.DECAY_ARROW_OPTIONS` + ArrowNode 默认头 10×10。
  void _decayArrow(Canvas canvas, Offset tail, Offset tip) {
    final d = tip - tail;
    final len = d.distance;
    if (len < 1) return;
    final ux = d.dx / len;
    final uy = d.dy / len;
    final nx = -uy;
    final ny = ux;
    const headH = ChartIntroVisuals.decayEquationArrowHeadHeight;
    const headW = ChartIntroVisuals.decayEquationArrowHeadWidth;
    const tailW = ChartIntroVisuals.decayEquationArrowTailWidth;
    final headLen = math.min(headH, len * 0.5);
    final neck = Offset(tip.dx - ux * headLen, tip.dy - uy * headLen);
    final path = Path()
      ..moveTo(tail.dx + nx * tailW / 2, tail.dy + ny * tailW / 2)
      ..lineTo(neck.dx + nx * tailW / 2, neck.dy + ny * tailW / 2)
      ..lineTo(neck.dx + nx * headW / 2, neck.dy + ny * headW / 2)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(neck.dx - nx * headW / 2, neck.dy - ny * headW / 2)
      ..lineTo(neck.dx - nx * tailW / 2, neck.dy - ny * tailW / 2)
      ..lineTo(tail.dx - nx * tailW / 2, tail.dy - ny * tailW / 2)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = ChartIntroVisuals.decayEquationArrowFill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ChartIntroVisuals.decayEquationArrowStrokeWidth
        ..color = ChartIntroVisuals.decayEquationArrowStroke,
    );
  }

  void _paintCurrentLabel(Canvas canvas, Offset gridOrigin) {
    final center = proj.toScreen(
      gridOrigin +
          render.cellCenter(render.currentProton, render.currentNeutron),
    );
    final dim = proj.toScreenLength(render.cellSize * 0.75);
    final r = dim * 0.6;
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = (2 * i * math.pi) / 8 + math.pi / 8;
      final p = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    final fill = render.currentCellVisual?.color ?? ChartIntroVisuals.unknown;
    canvas.drawPath(path, Paint()..color = fill);

    final tp = TextPainter(
      text: TextSpan(
        text: render.currentSymbol,
        style: TextStyle(
          fontSize: _cellLabelFontSize,
          color: render.currentLabelFill,
          fontWeight: FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: dim);
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  void _tickLabel(
    Canvas canvas,
    Offset anchor,
    String text, {
    required bool selected,
    required Color highlight,
    required bool above,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: ChartIntroVisuals.legendFontSize,
          fontWeight: FontWeight.normal,
          color: selected ? Colors.white : Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final pos = above
        ? Offset(anchor.dx - tp.width - 2, anchor.dy - tp.height / 2)
        : Offset(anchor.dx - tp.width / 2, anchor.dy);
    if (selected) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(pos.dx - 1.5, pos.dy - 1.5, tp.width + 3, tp.height + 3),
          const Radius.circular(2),
        ),
        Paint()..color = highlight,
      );
    }
    tp.paint(canvas, pos);
  }

  void _axisTitle(
    Canvas canvas,
    Offset center,
    String text, {
    required double rotate,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: ChartIntroVisuals.legendFontSize,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotate);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  /// [已确认] Partial 11 / Zoom 18 / Focused 6；scenery Text 未设 weight → normal
  double get _cellLabelFontSize {
    switch (render.presentation) {
      case NuclideChartPresentation.zoomIn:
        return ChartIntroVisuals.zoomCellLabelFontSize;
      case NuclideChartPresentation.focused:
        return ChartIntroVisuals.focusedCellLabelFontSize;
      case NuclideChartPresentation.partial:
        return ChartIntroVisuals.cellLabelFontSize;
    }
  }

  void _arrow(Canvas canvas, Offset tip, Offset dir) {
    const head = 7.0;
    final n = Offset(-dir.dy, dir.dx);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - dir.dx * head + n.dx * 3, tip.dy - dir.dy * head + n.dy * 3)
      ..lineTo(tip.dx - dir.dx * head - n.dx * 3, tip.dy - dir.dy * head - n.dy * 3)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant NuclideChartPainter old) =>
      old.render != render ||
      old.proj.origin != proj.origin ||
      old.proj.scale != proj.scale ||
      old.axisInset != axisInset;
}
