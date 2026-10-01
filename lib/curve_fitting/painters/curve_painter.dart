import 'package:flutter/material.dart';

import '../curve_fitting_constants.dart';
import '../render/cf_render_data.dart';
import '../transform/math_coordinate_transform.dart';

/// Black polynomial stroke from sampled path — PhET `CurveNode`.
class CurvePainter extends CustomPainter {
  CurvePainter({
    required this.render,
    required this.transform,
  });

  final CfRenderData render;
  final MathCoordinateTransform transform;

  @override
  void paint(Canvas canvas, Size size) {
    if (!render.curveVisible ||
        !render.isCurvePresent ||
        render.curveSamplesView.length < 2) {
      return;
    }

    final clip = transform.modelToViewRect(CurveFittingConstants.curveClipBounds);
    canvas.save();
    canvas.clipRect(clip);

    final path = Path()
      ..moveTo(
        render.curveSamplesView.first.dx,
        render.curveSamplesView.first.dy,
      );
    for (var i = 1; i < render.curveSamplesView.length; i++) {
      path.lineTo(
        render.curveSamplesView[i].dx,
        render.curveSamplesView[i].dy,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CurvePainter oldDelegate) =>
      oldDelegate.render != render;
}
