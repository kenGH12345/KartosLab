import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../fmw_colors.dart';
import '../render/fmw_render_data.dart';

/// Draws λ/T calipers: left jaw at [origin], right jaw at origin+width.
/// Width comes from model→view Δx (not hardcoded pixels).
class CalipersPainter extends CustomPainter {
  CalipersPainter({required this.data});

  final FmwCalipersData data;

  @override
  void paint(Canvas canvas, Size size) {
    final left = data.origin;
    final right = Offset(left.dx + data.measuredWidthView, left.dy);
    final paint = Paint()
      ..color = data.color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Beam
    canvas.drawLine(left, right, paint);

    // Jaws (vertical)
    const jaw = 14.0;
    canvas.drawLine(
      Offset(left.dx, left.dy - jaw),
      Offset(left.dx, left.dy + jaw),
      paint,
    );
    canvas.drawLine(
      Offset(right.dx, right.dy - jaw),
      Offset(right.dx, right.dy + jaw),
      paint,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: data.label,
        style: TextStyle(
          color: data.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((left.dx + right.dx) / 2 - tp.width / 2, left.dy - 22));
  }

  @override
  bool shouldRepaint(covariant CalipersPainter oldDelegate) =>
      oldDelegate.data != data;
}

/// Period clock: filled sector from 12 o'clock by [percentTime].
class PeriodClockPainter extends CustomPainter {
  PeriodClockPainter({required this.data});

  final FmwPeriodClockData data;

  @override
  void paint(Canvas canvas, Size size) {
    final c = data.center;
    final r = data.radius;
    final fill = Paint()..color = data.color.withValues(alpha: 0.35);
    final stroke = Paint()
      ..color = data.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(c, r, stroke);

    final sweep = data.percentTime * 2 * math.pi;
    if (sweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        sweep,
        true,
        fill,
      );
    }

    final tp = TextPainter(
      text: TextSpan(
        text: data.label,
        style: TextStyle(
          color: data.color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy + r + 4));
  }

  @override
  bool shouldRepaint(covariant PeriodClockPainter oldDelegate) =>
      oldDelegate.data != data;
}

/// Horizontal dimensional arrows for width indicators.
class WidthIndicatorPainter extends CustomPainter {
  WidthIndicatorPainter({required this.data});

  final FmwWidthIndicatorData data;

  @override
  void paint(Canvas canvas, Size size) {
    final c = data.centerView;
    final half = data.halfWidthView;
    final left = Offset(c.dx - half, c.dy);
    final right = Offset(c.dx + half, c.dy);
    final paint = Paint()
      ..color = FmwColors.widthIndicatorsColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(left, right, paint);
    // Arrow heads
    const a = 6.0;
    canvas.drawLine(left, Offset(left.dx + a, left.dy - a), paint);
    canvas.drawLine(left, Offset(left.dx + a, left.dy + a), paint);
    canvas.drawLine(right, Offset(right.dx - a, right.dy - a), paint);
    canvas.drawLine(right, Offset(right.dx - a, right.dy + a), paint);

    final tp = TextPainter(
      text: TextSpan(
        text: data.label,
        style: const TextStyle(
          color: FmwColors.widthIndicatorsColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - 16));
  }

  @override
  bool shouldRepaint(covariant WidthIndicatorPainter oldDelegate) =>
      oldDelegate.data != data;
}
