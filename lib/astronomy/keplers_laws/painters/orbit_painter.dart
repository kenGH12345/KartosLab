import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../keplers_laws_colors.dart';
import '../keplers_laws_constants.dart';
import '../keplers_laws_strings.dart';
import '../model/kl_vec.dart';
import '../render/orbit_render_data.dart';
import '../render/orbit_view.dart';

/// Orbit ellipse + first-law overlays.
///
/// Ellipse is sampled in true anomaly and mapped through the MVT so the
/// planet (same polar formula) always sits on the stroke. Canvas-rotate of
/// an axis-aligned oval around unrotated `(-c,0)` left the path behind the
/// planet whenever ω ≠ 0.
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
    final sunView = mvt.toView(data.sunPos);
    final orbitPaint = Paint()
      ..color = KeplersLawsColors.orbit
      ..style = PaintingStyle.stroke
      ..strokeWidth = isThirdLaw
          ? 2
          : KeplersLawsConstants.orbitLineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (_canDrawEllipse) {
      var path = orbitEllipsePath(data);
      if (!data.allowed) {
        path = dashPath(
          path,
          dashArray: const [
            KeplersLawsConstants.orbitInvalidDash,
            KeplersLawsConstants.orbitInvalidDash,
          ],
        );
      }
      canvas.drawPath(path, orbitPaint);
    } else if (!data.allowed) {
      // Degenerate / hyperbolic: still connect planet to sun, dashed.
      canvas.drawPath(
        dashPath(
          Path()
            ..moveTo(sunView.dx, sunView.dy)
            ..lineTo(
              mvt.toView(data.planetPos).dx,
              mvt.toView(data.planetPos).dy,
            ),
          dashArray: const [
            KeplersLawsConstants.orbitInvalidDash,
            KeplersLawsConstants.orbitInvalidDash,
          ],
        ),
        orbitPaint,
      );
    }

    if (!data.allowed) return;

    final b = data.b;
    final c = data.c;
    final w = data.w;

    final periView = orbitViewPoint(data, 0);
    final apoView = orbitViewPoint(data, math.pi);
    final geoView = mvt.toView(orbitGeoCenter(data));
    final otherFocus = mvt.toView(KlVec(-2 * c, 0).rotated(w));
    final minorDir = KlVec(0, b).rotated(w);
    final minorPos = mvt.toView(orbitGeoCenter(data) + minorDir);
    final minorNeg = mvt.toView(orbitGeoCenter(data) - minorDir);

    if (showAxes) {
      final axis = Paint()
        ..color = KeplersLawsColors.semiMajorAxis
        ..strokeWidth = 2;
      canvas.drawLine(apoView, periView, axis);
      canvas.drawLine(minorNeg, minorPos, axis);
    }

    if (showSemiaxes) {
      final p = Paint()
        ..color = KeplersLawsColors.semiMajorAxis
        ..strokeWidth = 3;
      canvas.drawLine(geoView, periView, p);
      canvas.drawLine(geoView, minorPos, p);
      _label(
        canvas,
        KeplersLawsStrings.symbolA,
        Offset.lerp(geoView, periView, 0.5)!,
      );
      _label(
        canvas,
        KeplersLawsStrings.symbolB,
        Offset.lerp(geoView, minorPos, 0.5)!,
      );
    }

    if (showFoci) {
      canvas.drawCircle(sunView, 5, Paint()..color = Colors.white);
      canvas.drawCircle(otherFocus, 5, Paint()..color = Colors.white);
      canvas.drawCircle(
        sunView,
        5,
        Paint()
          ..color = KeplersLawsColors.foci
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        otherFocus,
        5,
        Paint()
          ..color = KeplersLawsColors.foci
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (showString) {
      final planetView = mvt.toView(data.planetPos);
      final p = Paint()
        ..color = Colors.white
        ..strokeWidth = 1;
      canvas.drawLine(sunView, planetView, p);
      canvas.drawLine(otherFocus, planetView, p);
    }

    if (isFirstLaw && showEccentricity) {
      _dashed(canvas, sunView, otherFocus, KeplersLawsColors.focalDistance);
      _label(
        canvas,
        KeplersLawsStrings.symbolC,
        Offset.lerp(sunView, otherFocus, 0.5)!,
      );
      _dashed(canvas, geoView, periView, KeplersLawsColors.semiMajorAxis);
      _label(
        canvas,
        KeplersLawsStrings.symbolA,
        Offset.lerp(geoView, periView, 0.5)!,
      );
    }

    if (isFirstLaw && showSemiMajor) {
      _dashed(canvas, geoView, periView, KeplersLawsColors.semiMajorAxis);
      _label(
        canvas,
        KeplersLawsStrings.symbolA,
        Offset.lerp(geoView, periView, 0.5)!,
      );
    }

    if (isFirstLaw && showPeriapsis) {
      _dashed(canvas, sunView, periView, KeplersLawsColors.periapsis);
      _label(
        canvas,
        '${KeplersLawsStrings.symbolR}p',
        Offset.lerp(sunView, periView, 0.5)!,
      );
    }

    if (isFirstLaw && showApoapsis) {
      _dashed(canvas, sunView, apoView, KeplersLawsColors.apoapsis);
      _label(
        canvas,
        '${KeplersLawsStrings.symbolR}a',
        Offset.lerp(sunView, apoView, 0.5)!,
      );
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy);
    canvas.drawPath(
      Path()
        ..addPath(
          dashPath(path, dashArray: <double>[6, 4]),
          Offset.zero,
        ),
      paint,
    );
  }

  void _label(Canvas canvas, String text, Offset at) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  bool get _canDrawEllipse =>
      data.a.isFinite &&
      data.a > 0 &&
      data.b.isFinite &&
      data.b >= 0 &&
      data.e.isFinite &&
      data.e < 1;

  Path dashPath(Path source, {required List<double> dashArray}) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      var dist = 0.0;
      var draw = true;
      var i = 0;
      while (dist < metric.length) {
        final len = dashArray[i % dashArray.length];
        if (draw) {
          dest.addPath(metric.extractPath(dist, dist + len), Offset.zero);
        }
        dist += len;
        draw = !draw;
        i++;
      }
    }
    return dest;
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
