/// 顶部 mini-atom 静态 Painter：缩小圆形核 + 电子云。
///
/// 不复用 Decay [NucleusPainter]（它绑 [BuildANucleusState] / outgoing）。
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../ban_constants.dart';
import '../chart_intro_visuals.dart';
import '../render/chart_intro_projection.dart';
import '../render/mini_atom_render.dart';
import 'nucleon_ball.dart';

class MiniAtomPainter extends CustomPainter {
  MiniAtomPainter({
    required this.render,
    required this.proj,
  });

  final MiniAtomRender render;
  final ChartIntroProjection proj;

  @override
  void paint(Canvas canvas, Size size) {
    final center = proj.toScreen(Offset.zero);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(render.scale);

    if (render.showEmptyCircle) {
      _paintDashedCircle(
        canvas,
        Offset.zero,
        ChartIntroVisuals.nucleonRadius - 1,
        const Color(0xFF808080),
      );
    }
    if (render.cloudRadius > 0) {
      const electron = Color(BanConstants.electronColorValue);
      canvas.drawCircle(
        Offset.zero,
        render.cloudRadius,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset.zero,
            render.cloudRadius,
            [electron, electron.withValues(alpha: 0)],
            [0.0, 0.9],
          ),
      );
    }
    for (final n in render.nucleons) {
      NucleonBall.paint(
        canvas,
        n.offset,
        ChartIntroVisuals.nucleonRadius,
        NucleonBall.colorFor(n.type),
      );
    }
    canvas.restore();
  }

  void _paintDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    const dash = 2.0;
    const gap = 2.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = (d + dash < metric.length) ? d + dash : metric.length;
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant MiniAtomPainter old) =>
      old.render != render || old.proj.origin != proj.origin || old.proj.scale != proj.scale;
}
