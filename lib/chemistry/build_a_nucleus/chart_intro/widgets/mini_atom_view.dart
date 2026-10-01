/// 顶部 mini-atom 静态视图。不可交互，无第二套粒子模型。
library;

import 'package:flutter/material.dart';

import '../../data/nuclide_repository.dart';
import '../model/chart_intro_state.dart';
import '../painters/mini_atom_painter.dart';
import '../render/chart_intro_projection.dart';
import '../render/mini_atom_render.dart';

class MiniAtomView extends StatelessWidget {
  const MiniAtomView({
    super.key,
    required this.render,
    this.size = const Size(180, 180),
  });

  factory MiniAtomView.fromState(
    ChartIntroState state,
    NuclideRepository repository, {
    Key? key,
    Size size = const Size(180, 180),
  }) =>
      MiniAtomView(
        key: key,
        render: MiniAtomRender.from(state, repository),
        size: size,
      );

  final MiniAtomRender render;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: size,
        painter: MiniAtomPainter(
          render: render,
          proj: ChartIntroProjection(
            origin: Offset(size.width / 2, size.height / 2),
          ),
        ),
      ),
    );
  }
}
