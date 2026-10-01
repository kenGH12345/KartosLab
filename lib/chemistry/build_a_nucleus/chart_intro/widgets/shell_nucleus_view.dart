/// 壳层主核视图。无手势；opacity 由 render-only fade 写入。
library;

import 'package:flutter/material.dart';

import '../model/chart_intro_state.dart';
import '../painters/shell_nucleus_painter.dart';
import '../render/chart_intro_projection.dart';
import '../render/shell_fade.dart';
import '../render/shell_nucleus_render.dart';

class ShellNucleusView extends StatelessWidget {
  const ShellNucleusView({super.key, required this.render});

  factory ShellNucleusView.fromState(
    ChartIntroState state, {
    Key? key,
    ShellFadeAnimator? fades,
  }) =>
      ShellNucleusView(
        key: key,
        render: ShellNucleusRender.from(state, fades: fades),
      );

  final ShellNucleusRender render;

  @override
  Widget build(BuildContext context) {
    final size = render.contentSize;
    final origin = render.contentOrigin;
    return IgnorePointer(
      child: CustomPaint(
        size: size,
        painter: ShellNucleusPainter(
          render: render,
          proj: ChartIntroProjection(origin: origin),
        ),
      ),
    );
  }
}
