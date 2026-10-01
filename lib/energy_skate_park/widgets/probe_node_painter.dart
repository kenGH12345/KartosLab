import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// ProbeNode.ts @ scale 0.5, rotation π/2, color rgb(103,80,113), crosshairs sensor.
class ProbeNodePainter extends CustomPainter {
  ProbeNodePainter({
    required this.center,
    this.scale = 0.5,
    this.rotation = math.pi / 2,
    this.color = const Color(0xFF675071),
  });

  final Offset center;
  final double scale;
  final double rotation;
  final Color color;

  static const double _radius = 50;
  static const double _innerRadius = 35;
  static const double _handleWidth = 50;
  static const double _handleHeight = 30;
  static const double _handleCornerRadius = 10;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.scale(scale);

    final brighter = Color.lerp(color, Colors.white, 0.35)!;
    final darker = Color.lerp(color, Colors.black, 0.25)!;

    final outer = _buildOuterPath();
    canvas.drawPath(
      outer,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(-_radius, -_radius),
          Offset(_radius, _radius * 2),
          [brighter, color, darker],
          [0.0, 0.45, 1.0],
        ),
    );
    canvas.drawPath(
      outer,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawCircle(
      Offset.zero,
      _innerRadius,
      Paint()..color = const Color(0xFF1A1020).withValues(alpha: 0.15),
    );

    final crossPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const gap = 8.0;
    canvas.drawLine(const Offset(-_radius, 0), const Offset(-gap, 0), crossPaint);
    canvas.drawLine(const Offset(_radius, 0), const Offset(gap, 0), crossPaint);
    canvas.drawLine(const Offset(0, -_radius), const Offset(0, -gap), crossPaint);
    canvas.drawLine(const Offset(0, _radius), const Offset(0, gap), crossPaint);

    canvas.restore();
  }

  Path _buildOuterPath() {
    const arcExtent = 0.8;
    const neckCornerRadius = 10.0;
    final handleBottom = _radius + _handleHeight;
    final hw = _handleWidth / 2;

    final path = Path();
    path.moveTo(0, handleBottom);
    path.lineTo(hw - _handleCornerRadius, handleBottom);
    path.quadraticBezierTo(
      hw,
      handleBottom,
      hw,
      handleBottom - _handleCornerRadius,
    );
    path.lineTo(hw, _radius + neckCornerRadius);
    path.quadraticBezierTo(hw, _radius, hw - neckCornerRadius, _radius);

    final startAngle = math.pi * arcExtent;
    final sweep = math.pi * (1 - arcExtent);
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: _radius),
      startAngle,
      sweep,
      false,
    );

    path.lineTo(-hw + neckCornerRadius, _radius);
    path.quadraticBezierTo(-hw, _radius, -hw, _radius + neckCornerRadius);
    path.lineTo(-hw, handleBottom - _handleCornerRadius);
    path.quadraticBezierTo(
      -hw,
      handleBottom,
      -hw + _handleCornerRadius,
      handleBottom,
    );
    path.close();
    return path;
  }

  /// Hit radius in view px (includes handle).
  static double hitRadius({double scale = 0.5}) => _radius * scale * 1.15;

  @override
  bool shouldRepaint(covariant ProbeNodePainter old) =>
      old.center != center ||
      old.scale != scale ||
      old.rotation != rotation ||
      old.color != color;
}
