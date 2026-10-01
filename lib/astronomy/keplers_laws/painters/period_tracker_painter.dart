import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../keplers_laws_colors.dart';
import '../model/kl_vec.dart';
import '../model/period_tracker.dart';
import '../render/orbit_render_data.dart';

/// Third-law period trace (cyan).
///
/// [已确认] PeriodTrackerNode.ts updateShape / updateFade
class PeriodTrackerPainter extends CustomPainter {
  PeriodTrackerPainter({required this.data, required this.visible});

  final OrbitRenderData data;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible || !data.allowed) return;
    if (data.periodTracking == TrackingState.idle) return;

    final mvt = data.mvt;
    final scale = mvt.scale;
    final geoCenter = mvt.toView(KlVec(-data.c, 0));
    canvas.save();
    canvas.translate(geoCenter.dx, geoCenter.dy);
    canvas.rotate(-data.w);

    final radiusX = scale * data.a;
    final radiusY = scale * data.b;
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: radiusX * 2,
      height: radiusY * 2,
    );

    var opacity = 1.0;
    if (data.periodTracking == TrackingState.fading) {
      opacity = data.periodFadeOpacity.clamp(0.0, 1.0);
    }

    final paint = Paint()
      ..color = KeplersLawsColors.timeDisplayBackground.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final startPos = _polar(-data.periodTraceStart).times(scale) -
        KlVec(-data.c * scale, 0);
    final endPos = _polar(-data.periodTraceEnd).times(scale) -
        KlVec(-data.c * scale, 0);
    final startAngle = math.atan2(startPos.y / radiusY, startPos.x / radiusX);
    final endAngle = math.atan2(endPos.y / radiusY, endPos.x / radiusX);

    final angleDiff = data.periodTraceEnd - data.periodTraceStart;
    const angleThreshold = math.pi / 10;
    final closeRing = data.afterPeriodThreshold &&
        ((data.retrograde && angleDiff <= angleThreshold) ||
            (!data.retrograde && angleDiff >= 2 * math.pi - angleThreshold));

    if (data.periodTracking == TrackingState.fading || closeRing) {
      canvas.drawOval(rect, paint);
    } else {
      canvas.drawArc(
        rect,
        startAngle,
        _sweep(startAngle, endAngle, data.retrograde),
        false,
        paint,
      );
    }

    if (startAngle != endAngle ||
        data.periodTracking == TrackingState.running) {
      canvas.drawCircle(
        Offset(startPos.x, startPos.y),
        6,
        Paint()
          ..color =
              KeplersLawsColors.timeDisplayBackground.withValues(alpha: opacity),
      );
    }
    canvas.restore();
  }

  KlVec _polar(double nu) {
    final r = data.a * (1 - data.e * data.e) / (1 + data.e * math.cos(nu));
    return KlVec.polar(r, nu);
  }

  /// kite ellipticalArc(..., anticlockwise = retrograde)
  double _sweep(double start, double end, bool anticlockwise) {
    var d = end - start;
    if (anticlockwise) {
      while (d <= 0) {
        d += 2 * math.pi;
      }
      while (d > 2 * math.pi) {
        d -= 2 * math.pi;
      }
      return -d;
    }
    while (d >= 0) {
      d -= 2 * math.pi;
    }
    while (d < -2 * math.pi) {
      d += 2 * math.pi;
    }
    return -d;
  }

  @override
  bool shouldRepaint(covariant PeriodTrackerPainter old) =>
      old.data != data || old.visible != visible;
}
