import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../keplers_laws_colors.dart';
import '../model/period_tracker.dart';
import '../render/orbit_render_data.dart';
import '../render/orbit_view.dart';

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

    var opacity = 1.0;
    if (data.periodTracking == TrackingState.fading) {
      opacity = data.periodFadeOpacity.clamp(0.0, 1.0);
    }

    final paint = Paint()
      ..color = KeplersLawsColors.timeDisplayBackground.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final angleDiff = data.periodTraceEnd - data.periodTraceStart;
    const angleThreshold = math.pi / 10;
    final closeRing = data.afterPeriodThreshold &&
        ((data.retrograde && angleDiff <= angleThreshold) ||
            (!data.retrograde && angleDiff >= 2 * math.pi - angleThreshold));

    if (data.periodTracking == TrackingState.fading || closeRing) {
      canvas.drawPath(orbitEllipsePath(data), paint);
    } else {
      final start = orbitViewPoint(data, data.periodTraceStart);
      final path = Path()..moveTo(start.dx, start.dy);
      addTrueAnomalyArc(
        path,
        data,
        data.periodTraceStart,
        data.periodTraceEnd,
        retrograde: data.retrograde,
      );
      canvas.drawPath(path, paint);
    }

    if (data.periodTraceStart != data.periodTraceEnd ||
        data.periodTracking == TrackingState.running) {
      final start = orbitViewPoint(data, data.periodTraceStart);
      canvas.drawCircle(
        start,
        6,
        Paint()
          ..color =
              KeplersLawsColors.timeDisplayBackground.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant PeriodTrackerPainter old) =>
      old.data != data || old.visible != visible;
}
