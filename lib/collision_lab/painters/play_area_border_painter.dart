import 'package:flutter/material.dart';

import '../collision_lab_colors.dart';
import '../render/cl_render_data.dart';

/// Play-area border drawn above clipped balls — PlayAreaNode.js dilates by lineWidth/2.
class PlayAreaBorderPainter extends CustomPainter {
  PlayAreaBorderPainter({required this.data});

  final ClRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = data.reflectingBorder ? 3.5 : 1.5;
    final paint = Paint()
      ..color = data.reflectingBorder
          ? CollisionLabColors.reflectingBorder
          : CollisionLabColors.nonReflectingBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    // Dilate so stroke straddles the clip edge (half outside play-area).
    canvas.drawRect(data.playAreaRect.inflate(stroke / 2), paint);
  }

  @override
  bool shouldRepaint(covariant PlayAreaBorderPainter oldDelegate) => true;
}
