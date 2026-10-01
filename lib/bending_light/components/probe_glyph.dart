import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// `ProbeNode` (`scenery-phet/js/ProbeNode.ts`).
///
/// Origin of the unscaled shape is the sensor center. The outer path is the
/// kite outline (round head, neck, handle). The inner arc is a hole.
/// Intensity uses the defaults and scale 0.6. Wave probes pass their own
/// radius and `crosshairs: true` at scale 0.35.
class ProbeGlyph extends StatelessWidget {
  const ProbeGlyph({
    super.key,
    required this.color,
    this.radius = 50,
    this.innerRadius = 35,
    this.handleWidth = 50,
    this.handleHeight = 30,
    this.handleCornerRadius = 10,
    this.scale = 0.6,
    this.crosshairs = false,
  });

  final Color color;
  final double radius;
  final double innerRadius;
  final double handleWidth;
  final double handleHeight;
  final double handleCornerRadius;
  final double scale;
  final bool crosshairs;

  ProbeNodeGeometry get geometry => ProbeNodeGeometry(
        radius: radius,
        innerRadius: innerRadius,
        handleWidth: handleWidth,
        handleHeight: handleHeight,
        handleCornerRadius: handleCornerRadius,
      );

  /// Sensor center inside this widget, after [scale].
  Offset get sensorOrigin => geometry.sensorOrigin * scale;

  /// `bounds.centerBottom` relative to the sensor center, after [scale].
  double get centerBottomDy => geometry.handleBottom * scale;

  double get width => geometry.bounds.width * scale;
  double get height => geometry.bounds.height * scale;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _ProbePainter(
        color: color,
        geometry: geometry,
        scale: scale,
        crosshairs: crosshairs,
      ),
    );
  }
}

/// Unscaled `ProbeNode` paths. Shared by the intensity meter and both wave probes.
class ProbeNodeGeometry {
  ProbeNodeGeometry({
    required this.radius,
    required this.innerRadius,
    required this.handleWidth,
    required this.handleHeight,
    required this.handleCornerRadius,
  })  : outline = buildProbeOutline(
          radius: radius,
          handleWidth: handleWidth,
          handleHeight: handleHeight,
          handleCornerRadius: handleCornerRadius,
        ),
        shape = buildProbeShape(
          radius: radius,
          innerRadius: innerRadius,
          handleWidth: handleWidth,
          handleHeight: handleHeight,
          handleCornerRadius: handleCornerRadius,
        );

  final double radius;
  final double innerRadius;
  final double handleWidth;
  final double handleHeight;
  final double handleCornerRadius;
  final Path outline;
  final Path shape;

  double get handleBottom => radius + handleHeight;

  Rect get bounds => outline.getBounds();

  /// Sensor center in a box whose top-left is [bounds.topLeft].
  Offset get sensorOrigin => Offset(-bounds.left, -bounds.top);

  bool containsLocal(Offset point) => shape.contains(point);
}

Path buildProbeOutline({
  required double radius,
  required double handleWidth,
  required double handleHeight,
  double handleCornerRadius = 10,
}) {
  const arcExtent = 0.8;
  const neck = 10.0;
  final handleBottom = radius + handleHeight;
  final corner = handleCornerRadius;
  final arcStart = Offset(
    radius * math.cos(math.pi * arcExtent),
    radius * math.sin(math.pi * arcExtent),
  );
  return Path()
    ..moveTo(0, handleBottom)
    ..arcTo(
      Rect.fromCircle(
        center: Offset(-handleWidth / 2 + corner, handleBottom - corner),
        radius: corner,
      ),
      math.pi / 2,
      math.pi / 2,
      false,
    )
    ..lineTo(-handleWidth / 2, radius + neck)
    ..quadraticBezierTo(-handleWidth / 2, radius, arcStart.dx, arcStart.dy)
    ..arcTo(
      Rect.fromCircle(center: Offset.zero, radius: radius),
      math.pi * arcExtent,
      math.pi * 1.4,
      false,
    )
    ..quadraticBezierTo(
      handleWidth / 2,
      radius,
      handleWidth / 2,
      radius + neck,
    )
    ..arcTo(
      Rect.fromCircle(
        center: Offset(handleWidth / 2 - corner, handleBottom - corner),
        radius: corner,
      ),
      0,
      math.pi / 2,
      false,
    )
    ..close();
}

Path buildProbeShape({
  required double radius,
  required double innerRadius,
  required double handleWidth,
  required double handleHeight,
  double handleCornerRadius = 10,
}) {
  final hole = math.min(innerRadius, radius);
  final path = buildProbeOutline(
    radius: radius,
    handleWidth: handleWidth,
    handleHeight: handleHeight,
    handleCornerRadius: handleCornerRadius,
  )..addOval(Rect.fromCircle(center: Offset.zero, radius: hole));
  path.fillType = PathFillType.evenOdd;
  return path;
}

Color probeLuminance(Color base, double factor) {
  final toward = factor >= 0 ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  return Color.lerp(base, toward, factor.abs().clamp(0.0, 1.0))!;
}

class _ProbePainter extends CustomPainter {
  _ProbePainter({
    required this.color,
    required this.geometry,
    required this.scale,
    required this.crosshairs,
  });

  final Color color;
  final ProbeNodeGeometry geometry;
  final double scale;
  final bool crosshairs;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = geometry.sensorOrigin;
    canvas.save();
    canvas.translate(origin.dx * scale, origin.dy * scale);
    canvas.scale(scale);

    final radius = geometry.radius;
    if (crosshairs) {
      _crosshairs(canvas, radius);
    } else {
      _glass(canvas, radius);
    }

    final shape = geometry.shape;
    final bounds = geometry.outline.getBounds();
    final center = bounds.center;
    const light = 1.35 * math.pi;
    final v = Offset(math.cos(light), math.sin(light));
    final reach = radius + geometry.handleHeight;
    final source = center + v * reach;
    final dest = center - v * reach;
    final stops = <double>[0, 0.03, 0.07, 0.11, 0.3, 0.8, 1];
    final fills = <Color>[
      probeLuminance(color, 0.5),
      probeLuminance(color, 0.4),
      probeLuminance(color, 0.4),
      probeLuminance(color, 0.2),
      color,
      probeLuminance(color, -0.2),
      probeLuminance(color, -0.3),
    ];
    canvas.drawPath(
      shape,
      Paint()
        ..shader = ui.Gradient.linear(source, dest, fills, stops)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      shape,
      Paint()
        ..shader = ui.Gradient.linear(
          source,
          dest,
          [probeLuminance(color, 0.2), probeLuminance(color, -0.2)],
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final yScale = 0.93 + 0.01 * (geometry.handleHeight / 30);
    canvas.save();
    canvas.translate(center.dx, 2);
    canvas.scale(0.9, yScale);
    canvas.translate(-center.dx, 0);
    canvas.drawPath(shape, Paint()..color = color);
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = probeLuminance(color, 0.3).withValues(alpha: 0.5),
    );
    canvas.restore();
    canvas.restore();
  }

  void _glass(Canvas canvas, double radius) {
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(-radius * 0.15, -radius * 0.15),
          radius * 0.60,
          const [
            Color(0xFFFFFFFF),
            Color(0xFFE6F5FF),
            Color(0xFFC2E7FF),
          ],
          const [0, 0.4, 1],
        ),
    );
  }

  void _crosshairs(Canvas canvas, double radius) {
    const gap = 8.0;
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-radius, 0), const Offset(-gap, 0), paint);
    canvas.drawLine(const Offset(gap, 0), Offset(radius, 0), paint);
    canvas.drawLine(Offset(0, -radius), const Offset(0, -gap), paint);
    canvas.drawLine(const Offset(0, gap), Offset(0, radius), paint);
  }

  @override
  bool shouldRepaint(covariant _ProbePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.scale != scale;
}
