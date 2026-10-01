import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../keplers_laws_colors.dart';
import '../keplers_laws_strings.dart';
import '../model/kl_vec.dart';
import '../render/orbit_render_data.dart';

/// Velocity and gravity vectors.
///
/// [已确认] VectorNode.ts + DraggableVelocityVectorNode.ts
/// Arrow: tailWidth 5, head 15, stroke #404040
/// Grab: circle r=18, lineWidth 3, lightGray; label "v" font 22 bold gray
class VectorsPainter extends CustomPainter {
  VectorsPainter({
    required this.data,
    required this.showVelocity,
    required this.showGravity,
    required this.showVelocityHandle,
  });

  final OrbitRenderData data;
  final bool showVelocity;
  final bool showGravity;
  final bool showVelocityHandle;

  static const double grabRadius = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final planetOrigin = data.mvt.toView(data.planetPos);
    final sunOrigin = data.mvt.toView(data.sunPos);
    if (showVelocity) {
      final end = _arrow(
        canvas,
        planetOrigin,
        data.velocity,
        KeplersLawsColors.velocity,
        data.velocityArrowScale,
      );
      if (showVelocityHandle && end != null) {
        canvas.drawCircle(
          end,
          grabRadius,
          Paint()
            ..color = const Color(0xFFD3D3D3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
        final tp = TextPainter(
          text: const TextSpan(
            text: KeplersLawsStrings.symbolV,
            style: TextStyle(
              color: Color(0xFF808080),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, end - Offset(tp.width / 2, tp.height / 2));
      }
    }
    if (showGravity) {
      _arrow(
        canvas,
        planetOrigin,
        data.planetGravity,
        KeplersLawsColors.gravity,
        data.gravityArrowScale,
      );
      _arrow(
        canvas,
        sunOrigin,
        data.sunGravity,
        KeplersLawsColors.gravity,
        data.gravityArrowScale,
      );
    }
  }

  Offset? _arrow(
    Canvas canvas,
    Offset origin,
    KlVec vec,
    Color color,
    double modelScale,
  ) {
    var tip = vec.times(modelScale);
    if (tip.magnitude == 0) return origin;
    if (tip.magnitude > 1e4) {
      tip = tip.normalized().times(1e4);
    }
    final viewDelta = data.mvt.toView(tip) - data.mvt.toView(KlVec.zero);
    final end = origin + viewDelta;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final outline = Paint()
      ..color = const Color(0xFF404040)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(origin, end, outline);
    canvas.drawLine(origin, end, paint);
    final ang = math.atan2(end.dy - origin.dy, end.dx - origin.dx);
    const head = 15.0;
    canvas.drawLine(
      end,
      end + Offset(math.cos(ang + 2.6) * head, math.sin(ang + 2.6) * head),
      paint,
    );
    canvas.drawLine(
      end,
      end + Offset(math.cos(ang - 2.6) * head, math.sin(ang - 2.6) * head),
      paint,
    );
    return end;
  }

  @override
  bool shouldRepaint(covariant VectorsPainter old) =>
      old.data != data ||
      old.showVelocity != showVelocity ||
      old.showGravity != showGravity ||
      old.showVelocityHandle != showVelocityHandle;
}
