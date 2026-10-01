/// 壳层主核静态 Painter：3 条能级线 + 座位上的核子。
///
/// 不使用 Decay [NucleusPainter] / [NucleusLayout]。
library;

import 'package:flutter/material.dart';

import '../chart_intro_visuals.dart';
import '../render/chart_intro_projection.dart';
import '../render/shell_nucleus_render.dart';
import 'nucleon_ball.dart';

class ShellNucleusPainter extends CustomPainter {
  ShellNucleusPainter({
    required this.render,
    required this.proj,
  });

  final ShellNucleusRender render;
  final ChartIntroProjection proj;

  @override
  void paint(Canvas canvas, Size size) {
    for (final column in render.columns) {
      for (final level in column.levels) {
        canvas.drawLine(
          proj.toScreen(level.start),
          proj.toScreen(level.end),
          Paint()
            ..color = level.stroke
            ..strokeWidth = proj.toScreenLength(level.strokeWidth)
            ..strokeCap = StrokeCap.round,
        );
      }
    }
    for (final column in render.columns) {
      for (final nucleon in column.nucleons) {
        NucleonBall.paint(
          canvas,
          proj.toScreen(nucleon.center),
          proj.toScreenLength(ChartIntroVisuals.nucleonRadius),
          NucleonBall.colorFor(nucleon.type),
          opacity: nucleon.opacity,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ShellNucleusPainter old) =>
      old.render != render || old.proj.origin != proj.origin || old.proj.scale != proj.scale;
}
