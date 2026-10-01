/// Velocity arrows from [BodyRenderDot.velocity]. Painter does not store velocity.
///
/// Offscale (|v| < minMagnitude) hides the arrow and draws an indicator —
/// [KEPLER-SECONDARY] VectorNode behavior; replaceable when common lands.
library;

import 'package:flutter/material.dart';

import '../../../common/controls/arrow_painter.dart';
import '../my_solar_system_colors.dart';
import '../my_solar_system_constants.dart';
import '../my_solar_system_strings.dart';
import '../render/mss_render_data.dart';
import '../render/velocity_vector.dart';

class VelocityVectorsPainter extends CustomPainter {
  VelocityVectorsPainter(this.data);

  final MssRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    if (!data.velocityVisible) return;
    for (final body in data.bodies) {
      final tail = data.mvt.toView(body.position);
      if (body.velocityOffscale) {
        _paintOffscaleIndicator(canvas, tail);
        continue;
      }
      final tip =
          data.mvt.toView(velocityTipModel(body.position, body.velocity));
      ArrowPainter(
        tail: tail,
        tip: tip,
        color: MySolarSystemColors.velocity,
        headHeight: MySolarSystemConstants.vectorHeadHeight,
        headWidth: MySolarSystemConstants.vectorHeadWidth,
        tailWidth: MySolarSystemConstants.vectorTailWidth,
      ).paint(canvas, size);
      canvas.drawCircle(
        tip,
        MySolarSystemConstants.velocityGrabRadius,
        Paint()
          ..color = MySolarSystemConstants.velocityGrabRingColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = MySolarSystemConstants.velocityGrabStrokeWidth,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: MySolarSystemStrings.symbolV,
          style: TextStyle(
            color: MySolarSystemConstants.velocityLabelColor,
            fontSize: MySolarSystemConstants.velocityLabelFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, tip - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _paintOffscaleIndicator(Canvas canvas, Offset at) {
    final paint = Paint()
      ..color = MySolarSystemColors.velocity
      ..style = PaintingStyle.stroke
      ..strokeWidth = MySolarSystemConstants.velocityOffscaleIndicatorStroke;
    final offset = Offset(
      MySolarSystemConstants.velocityOffscaleIndicatorOffsetX,
      MySolarSystemConstants.velocityOffscaleIndicatorOffsetY,
    );
    canvas.drawCircle(
      at + offset,
      MySolarSystemConstants.velocityOffscaleIndicatorRadius,
      paint,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: MySolarSystemStrings.symbolV,
        style: TextStyle(
          color: MySolarSystemConstants.velocityLabelColor,
          fontSize: MySolarSystemConstants.velocityOffscaleLabelFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      at +
          Offset(
            offset.dx - tp.width / 2,
            offset.dy - tp.height / 2,
          ),
    );
  }

  @override
  bool shouldRepaint(VelocityVectorsPainter oldDelegate) =>
      oldDelegate.data != data;
}
