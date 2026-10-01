import 'package:flutter/material.dart';

import '../normal_modes_colors.dart';
import '../normal_modes_constants.dart';
import '../render/nm_render_data.dart';

class ModeGraphPainter extends CustomPainter {
  ModeGraphPainter({required this.graph});

  final ModeGraphRender graph;

  @override
  void paint(Canvas canvas, Size size) {
    final startY = size.height / 2;
    final xStep = size.width / (graph.ys.isEmpty ? 1 : graph.ys.length);

    if (!graph.drawWalls) {
      final ref = Paint()
        ..color = NormalModesColors.modeGraphReference
        ..strokeWidth = 2;
      canvas.drawLine(Offset(0, startY), Offset(size.width, startY), ref);
    } else {
      final wall = Paint()
        ..color = NormalModesColors.modeGraphWall
        ..strokeWidth = 2;
      const h = 8.0;
      canvas.drawLine(Offset(0, startY + h / 2), Offset(0, startY - h / 2), wall);
      canvas.drawLine(
        Offset(size.width, startY + h / 2),
        Offset(size.width, startY - h / 2),
        wall,
      );
    }

    final curve = Paint()
      ..color = NormalModesColors.modeGraphStroke
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(0, startY);
    for (var i = 1; i < graph.ys.length; i++) {
      path.lineTo(i * xStep, graph.ys[i] + startY);
    }
    path.lineTo(size.width, startY);
    canvas.drawPath(path, curve);
  }

  @override
  bool shouldRepaint(covariant ModeGraphPainter oldDelegate) => true;
}

class StaticModeGraph extends StatelessWidget {
  const StaticModeGraph({super.key, required this.graph});

  final ModeGraphRender graph;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: NormalModesConstants.staticGraphWidth,
      height: NormalModesConstants.staticGraphHeight,
      child: CustomPaint(painter: ModeGraphPainter(graph: graph)),
    );
  }
}

class AnimatedModeGraph extends StatelessWidget {
  const AnimatedModeGraph({super.key, required this.graph});

  final ModeGraphRender graph;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: NormalModesConstants.modeGraphWidth,
      height: NormalModesConstants.modeGraphHeight,
      child: CustomPaint(painter: ModeGraphPainter(graph: graph)),
    );
  }
}
