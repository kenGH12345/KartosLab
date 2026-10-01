import 'package:flutter/material.dart';

import '../curve_fitting_colors.dart';
import '../curve_fitting_constants.dart';
import '../render/cf_render_data.dart';
import '../transform/math_coordinate_transform.dart';

/// Gray vertical residual lines point → yFit — PhET `ResidualsNode`.
class ResidualPainter extends CustomPainter {
  ResidualPainter({
    required this.render,
    required this.transform,
  });

  final CfRenderData render;
  final MathCoordinateTransform transform;

  @override
  void paint(Canvas canvas, Size size) {
    if (!render.residualsVisible || render.residuals.isEmpty) return;

    final clip = transform
        .modelToViewRect(CurveFittingConstants.graphBackgroundModelBounds);
    canvas.save();
    canvas.clipRect(clip);

    final paint = Paint()
      ..color = CurveFittingColors.gray
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final r in render.residuals) {
      canvas.drawLine(r.fromView, r.toView, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ResidualPainter oldDelegate) =>
      oldDelegate.render != render;
}
