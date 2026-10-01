import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bending_light_constants.dart';
import '../model/bl_vec2.dart';
import '../model/intersection.dart';
import '../model/light_ray.dart';
import '../model/prism.dart';
import '../model/prism_geometry.dart';
import '../model/substance.dart';
import '../physics/white_light.dart';
import '../transform/bl_mvt.dart';
import '../view/medium_colors.dart';

Color _argbToColor(int argb) => Color(argb);

/// Intro dual-medium fill + optional dashed normal through origin.
class IntroMediumPainter extends CustomPainter {
  IntroMediumPainter({
    required this.mvt,
    required this.topSubstance,
    required this.bottomSubstance,
    required this.showNormal,
  });

  final BlMvt mvt;
  final Substance topSubstance;
  final Substance bottomSubstance;
  final bool showNormal;

  @override
  void paint(Canvas canvas, Size size) {
    final topColor = MediumColors.forSubstance(topSubstance);
    final bottomColor = MediumColors.forSubstance(bottomSubstance);

    // Horizontal interface at model y=0
    final y0 = mvt.worldToScreen(BlVec2.zero).dy;

    canvas.drawRect(
      Rect.fromLTRB(0, 0, size.width, y0),
      Paint()..color = topColor,
    );
    canvas.drawRect(
      Rect.fromLTRB(0, y0, size.width, size.height),
      Paint()..color = bottomColor,
    );

    // Interface line
    canvas.drawLine(
      Offset(0, y0),
      Offset(size.width, y0),
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 1,
    );

    if (showNormal) {
      final origin = mvt.worldToScreen(BlVec2.zero);
      _drawDashedLine(
        canvas,
        Offset(origin.dx, 0),
        Offset(origin.dx, size.height),
        Paint()
          ..color = Colors.black45
          ..strokeWidth = 1,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 6.0;
    const gap = 4.0;
    final total = (b - a).distance;
    if (total < 1) return;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final start = a + dir * d;
      final end = a + dir * math.min(d + dash, total);
      canvas.drawLine(start, end, paint);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant IntroMediumPainter old) =>
      old.topSubstance != topSubstance ||
      old.bottomSubstance != bottomSubstance ||
      old.showNormal != showNormal ||
      old.mvt.viewOrigin != mvt.viewOrigin;
}

/// `SingleColorLightCanvasNode`: alpha = sqrt(power), omit power <= 1e-6.
Paint? _singleColorRayPaint(Color color, double power, double viewStroke) {
  if (power <= 1e-6) return null;
  return Paint()
    ..color = color.withValues(alpha: math.sqrt(power).clamp(0.0, 1.0))
    ..strokeWidth = viewStroke
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
}

double _rayViewStroke(BlMvt mvt) =>
    (BendingLightConstants.rayWidth * mvt.scale).abs();

/// Draws [LightRay] segments from model (no Snell recompute).
class RaysPainter extends CustomPainter {
  RaysPainter({
    required this.mvt,
    required this.rays,
  });

  final BlMvt mvt;
  final List<LightRay> rays;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = _rayViewStroke(mvt);
    for (final ray in rays) {
      final color = ray.colorArgb != 0
          ? _argbToColor(ray.colorArgb)
          : Colors.red;
      final paint = _singleColorRayPaint(color, ray.powerFraction, stroke);
      if (paint == null) continue;
      canvas.drawLine(
        mvt.worldToScreen(ray.tail),
        mvt.worldToScreen(ray.tip),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RaysPainter old) =>
      old.rays != rays || old.mvt.viewOrigin != mvt.viewOrigin;
}

/// Prisms fill + rays + optional intersection normals.
class PrismScenePainter extends CustomPainter {
  PrismScenePainter({
    required this.mvt,
    required this.prisms,
    required this.rays,
    required this.intersections,
    required this.prismMedium,
    this.prismFill,
    required this.showNormals,
    this.includeRays = true,
    this.paintPrisms = true,
    this.fillBackground = true,
  });

  final BlMvt mvt;
  final List<Prism> prisms;
  final List<LightRay> rays;
  final List<Intersection> intersections;
  final Substance prismMedium;
  final Color? prismFill;
  final bool showNormals;
  final bool includeRays;

  /// Placed prisms sit above the dock (`afterLightLayer` adds `prismLayer` last).
  final bool paintPrisms;

  /// White light fills the environment itself (`WhiteLightCanvasNode`).
  final bool fillBackground;

  @override
  void paint(Canvas canvas, Size size) {
    if (fillBackground) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.white,
      );
    }

    final fill = prismFill ??
        Color(
          MediumColorFactory().getColor(
            prismMedium.indexOfRefractionForRedLight,
          ),
        ).withValues(alpha: BendingLightConstants.prismNodeAlpha);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF808080)
      ..strokeWidth = 1;

    for (final prism in prisms) {
      if (!paintPrisms) break;
      final path = prismViewPath(mvt, prism);
      if (path == null) continue;
      canvas.drawPath(path, Paint()..color = fill);
      canvas.drawPath(path, stroke);
    }

    if (includeRays) {
      final stroke = _rayViewStroke(mvt);
      for (final ray in rays) {
        final color = ray.colorArgb != 0
            ? _argbToColor(ray.colorArgb)
            : Colors.red;
        final paint = _singleColorRayPaint(color, ray.powerFraction, stroke);
        if (paint == null) continue;
        canvas.drawLine(
          mvt.worldToScreen(ray.tail),
          mvt.worldToScreen(ray.tip),
          paint,
        );
      }
    }

    if (showNormals) {
      const halfLen = 12.0; // view px
      for (final hit in intersections) {
        final p = mvt.worldToScreen(hit.point);
        final nView = mvt.modelToViewDelta(hit.unitNormal);
        final len = nView.distance;
        if (len < 1e-9) continue;
        final u = nView / len;
        canvas.drawLine(
          p - u * halfLen,
          p + u * halfLen,
          Paint()
            ..color = Colors.black54
            ..strokeWidth = 1,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PrismScenePainter old) =>
      old.prisms != prisms ||
      old.rays != rays ||
      old.intersections != intersections ||
      old.showNormals != showNormals ||
      old.prismMedium != prismMedium ||
      old.paintPrisms != paintPrisms;
}

/// Screen-space outline of a placed prism. Used to drop it back onto the dock.
Path? prismViewPath(BlMvt mvt, Prism prism) {
  final shape = prism.translatedShape;
  if (shape is PolygonShape) {
    if (shape.points.isEmpty) return null;
    final path = Path();
    final first = mvt.worldToScreen(shape.points.first);
    path.moveTo(first.dx, first.dy);
    for (var i = 1; i < shape.points.length; i++) {
      final p = mvt.worldToScreen(shape.points[i]);
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }
  if (shape is CircleShape) {
    final c = mvt.worldToScreen(shape.center);
    final rx = mvt.modelToViewDelta(BlVec2(shape.radius, 0)).dx.abs();
    final ry = mvt.modelToViewDelta(BlVec2(0, shape.radius)).dy.abs();
    return Path()
      ..addOval(Rect.fromCenter(center: c, width: rx * 2, height: ry * 2));
  }
  if (shape is SemiCircleShape) {
    final c = mvt.worldToScreen(shape.center);
    final r = mvt.modelToViewDelta(BlVec2(shape.radius, 0)).dx.abs();
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..arcToPoint(
        Offset(c.dx, c.dy + r),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..close();
  }
  return null;
}

/// Simple angle arcs at origin for Intro when showAngles.
class AngleArcsPainter extends CustomPainter {
  AngleArcsPainter({
    required this.mvt,
    required this.laserAngle,
    required this.showAngles,
  });

  final BlMvt mvt;
  final double laserAngle;
  final bool showAngles;

  @override
  void paint(Canvas canvas, Size size) {
    if (!showAngles) return;
    final origin = mvt.worldToScreen(BlVec2.zero);
    const radius = 36.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black54
      ..strokeWidth = 1.5;

    // Incident angle from normal (−π/2 axis in model → up in view is tricky).
    // Draw small arc from vertical normal toward incident beam.
    final beamDir = BlVec2(math.cos(laserAngle + math.pi), math.sin(laserAngle + math.pi));
    final beamView = mvt.modelToViewDelta(beamDir);
    final beamA = math.atan2(beamView.dy, beamView.dx);
    final normalA = -math.pi / 2; // upward in screen? normal is +y model → -y screen = -π/2 from +x

    canvas.drawArc(
      Rect.fromCircle(center: origin, radius: radius),
      math.min(beamA, normalA),
      (beamA - normalA).abs().clamp(0.05, math.pi),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant AngleArcsPainter old) =>
      old.laserAngle != laserAngle || old.showAngles != showAngles;
}

/// `WhiteLightCanvasNode.paintCanvas`: lineWidth 3, composite `lighter`.
class WhiteLightPainter extends CustomPainter {
  WhiteLightPainter({required this.mvt, required this.rays});

  final BlMvt mvt;
  final List<LightRay> rays;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF000000));
    for (final ray in rays) {
      final rgb = whiteLightStrokeRgb(
        wavelengthNm: ray.wavelengthInVacuum,
        powerFraction: ray.powerFraction,
      );
      if (rgb == null) continue;
      canvas.drawLine(
        mvt.worldToScreen(ray.tail),
        mvt.worldToScreen(ray.tip),
        Paint()
          ..color = Color.fromARGB(255, rgb.$1.clamp(0, 255), rgb.$2.clamp(0, 255), rgb.$3.clamp(0, 255))
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..blendMode = BlendMode.plus,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WhiteLightPainter oldDelegate) => true;
}
