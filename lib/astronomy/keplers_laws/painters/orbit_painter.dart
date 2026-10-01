import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../keplers_laws_colors.dart';
import '../keplers_laws_constants.dart';
import '../model/kl_vec.dart';
import '../render/orbit_render_data.dart';

/// Ellipse, axes, foci, strings, peri/apo.
///
/// Geometry from [已确认] `EllipticalOrbitNode.ts` `updatedOrbit`.
class OrbitPainter extends CustomPainter {
  OrbitPainter({
    required this.data,
    required this.showAxes,
    required this.showSemiaxes,
    required this.showFoci,
    required this.showString,
    required this.showEccentricity,
    required this.showSemiMajor,
    required this.showPeriapsis,
    required this.showApoapsis,
    required this.isFirstLaw,
    required this.isSecondLaw,
    required this.isThirdLaw,
  });

  final OrbitRenderData data;
  final bool showAxes;
  final bool showSemiaxes;
  final bool showFoci;
  final bool showString;
  final bool showEccentricity;
  final bool showSemiMajor;
  final bool showPeriapsis;
  final bool showApoapsis;
  final bool isFirstLaw;
  final bool isSecondLaw;
  final bool isThirdLaw;

  @override
  void paint(Canvas canvas, Size size) {
    final mvt = data.mvt;
    final scale = mvt.scale;
    final a = data.a;
    final b = data.b;
    final c = data.c;
    final e = data.e;

    final radiusX = scale * a;
    final radiusY = scale * b;
    final radiusC = scale * c;

    // Ellipse is translated to geometric center (-c, 0) then rotated by -w.
    final geoCenterModel = KlVec(-c, 0);
    final geoCenterView = mvt.toView(geoCenterModel);

    canvas.save();
    canvas.translate(geoCenterView.dx, geoCenterView.dy);
    canvas.rotate(-data.w);

    final orbitPaint = Paint()
      ..color = KeplersLawsColors.orbit
      ..style = PaintingStyle.stroke
      ..strokeWidth = KeplersLawsConstants.orbitLineWidth;
    if (!data.allowed) {
      orbitPaint.strokeCap = StrokeCap.round;
    }
    final path = Path()
      ..addOval(Rect.fromCenter(
        center: Offset.zero,
        width: radiusX * 2,
        height: radiusY * 2,
      ));
    if (!data.allowed) {
      _drawDashed(canvas, path, orbitPaint);
    } else {
      canvas.drawPath(path, orbitPaint);
    }

    final axisVisible = showAxes || (showSemiMajor && isThirdLaw);
    if (axisVisible) {
      final p = Paint()
        ..color = KeplersLawsColors.foreground
        ..strokeWidth = 2;
      canvas.drawLine(Offset(-radiusX, 0), Offset(radiusX, 0), p);
      canvas.drawLine(Offset(0, -radiusY), Offset(0, radiusY), p);
    }

    final semiMajorVisible =
        (isThirdLaw && showSemiMajor) || showSemiaxes || showEccentricity;
    if (semiMajorVisible) {
      canvas.drawLine(
        Offset.zero,
        Offset(-radiusX, 0),
        Paint()
          ..color = KeplersLawsColors.semiMajorAxis
          ..strokeWidth = 3,
      );
    }

    if (isFirstLaw && showSemiaxes) {
      canvas.drawLine(
        Offset.zero,
        Offset(0, radiusY),
        Paint()
          ..color = KeplersLawsColors.semiMinorAxis
          ..strokeWidth = 3,
      );
    }

    if (isFirstLaw && showEccentricity) {
      canvas.drawLine(
        Offset.zero,
        Offset(e * radiusX, 0),
        Paint()
          ..color = KeplersLawsColors.focalDistance
          ..strokeWidth = 3,
      );
    }

    if (isFirstLaw && showString) {
      final body = _createPolar(-data.nu, a, e).times(scale);
      final string = Path()
        ..moveTo(-radiusC, 0)
        ..lineTo(body.x + radiusC, -body.y)
        ..lineTo(radiusC, 0);
      canvas.drawPath(
        string,
        Paint()
          ..color = KeplersLawsColors.distances
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
    }

    if (isFirstLaw && showFoci) {
      _drawX(canvas, Offset(-radiusC, 0), KeplersLawsColors.foci);
      _drawX(canvas, Offset(radiusC, 0), KeplersLawsColors.foci);
    }

    if (semiMajorVisible) {
      _label(canvas, 'a', Offset(-radiusX / 2, -15), KeplersLawsColors.semiMajorAxis);
    }
    if (isFirstLaw && showSemiaxes) {
      _label(canvas, 'b', Offset(-15, radiusY / 2), KeplersLawsColors.semiMinorAxis);
    }
    if (isFirstLaw && showEccentricity) {
      _label(
        canvas,
        'c',
        Offset(e * radiusX / 2, 15),
        KeplersLawsColors.focalDistance,
      );
    }

    if (isSecondLaw && showPeriapsis && e > 0) {
      _drawX(
        canvas,
        Offset(scale * (a * (1 - e) + c), 0),
        KeplersLawsColors.periapsis,
      );
    }
    if (isSecondLaw && showApoapsis && e > 0) {
      _drawX(
        canvas,
        Offset(-scale * (a * (1 + e) - c), 0),
        KeplersLawsColors.apoapsis,
      );
    }

    canvas.restore();
  }

  void _label(Canvas canvas, String text, Offset at, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: KeplersLawsConstants.axisLabelFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  KlVec _createPolar(double nu, double a, double e) {
    final r = a * (1 - e * e) / (1 + e * math.cos(nu));
    return KlVec.polar(r, nu);
  }

  void _drawX(Canvas canvas, Offset c, Color color) {
    const s = 7.0;
    final p = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(math.pi / 4);
    canvas.drawLine(const Offset(-s, 0), const Offset(s, 0), p);
    canvas.drawLine(const Offset(0, -s), const Offset(0, s), p);
    canvas.restore();
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    // [已确认] EllipticalOrbitNode lineDash = allowed ? [0] : [5]
    final dashed = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = paint.strokeWidth;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      var draw = true;
      while (d < metric.length) {
        final next = math.min(d + 5, metric.length);
        if (draw) {
          canvas.drawPath(metric.extractPath(d, next), dashed);
        }
        d = next;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant OrbitPainter old) =>
      old.data != data ||
      old.showAxes != showAxes ||
      old.showSemiaxes != showSemiaxes ||
      old.showFoci != showFoci ||
      old.showString != showString ||
      old.showEccentricity != showEccentricity ||
      old.showSemiMajor != showSemiMajor ||
      old.showPeriapsis != showPeriapsis ||
      old.showApoapsis != showApoapsis ||
      old.isFirstLaw != isFirstLaw ||
      old.isSecondLaw != isSecondLaw ||
      old.isThirdLaw != isThirdLaw;
}
