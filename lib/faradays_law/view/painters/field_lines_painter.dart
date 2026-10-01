import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../faradays_law_constants.dart';
import '../../model/field_lines.dart';

/// Predefined ellipses from `MagnetFieldLines.js` — not a B-field solver.
class FieldLinesPainter extends CustomPainter {
  FieldLinesPainter({required this.geometry});

  final FieldLineGeometry geometry;

  @override
  void paint(Canvas canvas, Size size) {
    if (!geometry.visible) return;

    final paint = Paint()
      ..color = const Color(FaradaysLawConstants.fieldLineStrokeValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = FaradaysLawConstants.fieldLineStrokeWidth
      ..strokeCap = StrokeCap.round;

    final origin = geometry.magnetPosition;
    canvas.save();
    canvas.translate(origin.dx, origin.dy);

    _paintSide(canvas, paint, scaleY: 1);
    _paintSide(canvas, paint, scaleY: -1);

    canvas.restore();
  }

  void _paintSide(Canvas canvas, Paint paint, {required double scaleY}) {
    canvas.save();
    canvas.scale(1, scaleY);

    for (var i = 0; i < geometry.ellipses.length; i++) {
      final spec = geometry.ellipses[i];
      // Source: arc.bottom = 2 - index * dy; centerX = 0
      final bottomY = 2 - i * kFieldLineEllipseDy;
      final centerY = bottomY - spec.b;

      final rect = Rect.fromCenter(
        center: Offset(0, centerY),
        width: spec.a * 2,
        height: spec.b * 2,
      );
      canvas.drawOval(rect, paint);

      for (final angle in spec.arrowPositions) {
        _drawArrowOnEllipse(
          canvas,
          paint,
          a: spec.a,
          b: spec.b,
          centerY: centerY,
          angle: angle,
          flipped: geometry.arrowDirectionFlipped,
        );
      }
    }

    canvas.restore();
  }

  void _drawArrowOnEllipse(
    Canvas canvas,
    Paint paint, {
    required double a,
    required double b,
    required double centerY,
    required double angle,
    required bool flipped,
  }) {
    final x = a * math.cos(angle);
    final y = centerY + b * math.sin(angle);

    // Tangent of ellipse parametric form
    var tangentAngle = math.atan2(b * math.cos(angle), -a * math.sin(angle));
    if (y > centerY) {
      tangentAngle += math.pi;
    }
    if (flipped) {
      tangentAngle += math.pi;
    }

    final aw = FaradaysLawConstants.fieldLineArrowWidth;
    final ah = FaradaysLawConstants.fieldLineArrowHeight;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(tangentAngle);
    // Arrow tip at origin, shaft along -X (matches source Path)
    final path = Path()
      ..moveTo(-aw, -ah / 2)
      ..lineTo(0, 0)
      ..lineTo(-aw, ah / 2);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FieldLinesPainter oldDelegate) {
    return oldDelegate.geometry.visible != geometry.visible ||
        oldDelegate.geometry.magnetPosition != geometry.magnetPosition ||
        oldDelegate.geometry.orientation != geometry.orientation ||
        oldDelegate.geometry.arrowDirectionFlipped !=
            geometry.arrowDirectionFlipped;
  }
}
