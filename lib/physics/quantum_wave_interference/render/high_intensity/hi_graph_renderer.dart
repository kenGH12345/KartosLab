import 'package:flutter/material.dart';

import '../../data/graph_data.dart';
import '../../domain/detector_mode.dart';
import '../../render_data/high_intensity/wave_field_render_data.dart';
import '../common/screen_brightness_utils.dart';

/// HI graph: PDF curve or 100-bin hits; y-axis aligned with detector (top = high).
class HiGraphRenderer {
  const HiGraphRenderer();

  void paintPdf(Canvas canvas, Rect graphRect, List<double> pdf, Color color, int zoomLevel) {
    canvas.drawRect(graphRect, Paint()..color = const Color(0xFF1A1A1A));
    if (pdf.isEmpty) {
      return;
    }
    // Zoom level 1..6 maps to visible fraction of PDF centered.
    final visibleFraction = (7 - zoomLevel.clamp(1, 6)) / 6.0;
    final n = pdf.length;
    final start = ((1 - visibleFraction) / 2 * n).floor();
    final end = (n - start).clamp(start + 1, n);
    final slice = pdf.sublist(start, end);
    var maxV = 1e-12;
    for (final v in slice) {
      if (v > maxV) {
        maxV = v;
      }
    }
    final path = Path();
    for (var i = 0; i < slice.length; i++) {
      // Flip: PDF index 0 at bottom of wave → plot from top with reversed i
      final pdfI = slice.length - 1 - i;
      final x = graphRect.left + (slice[pdfI] / maxV) * graphRect.width * 0.95;
      final y = graphRect.top + (i / (slice.length - 1)) * graphRect.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void paintHits(Canvas canvas, Rect graphRect, HitsHistogramData hist, Color color, int zoomLevel) {
    canvas.drawRect(graphRect, Paint()..color = const Color(0xFF1A1A1A));
    var maxBin = 1;
    for (final b in hist.bins) {
      if (b > maxBin) {
        maxBin = b;
      }
    }
    // Hits histogram for HI uses x along detector; bins left→right.
    // Vertical plot: map bins to y with same orientation as detector y∈[0,1].
    final barH = graphRect.height / hist.binCount;
    for (var i = 0; i < hist.binCount; i++) {
      final w = (hist.bins[i] / maxBin) * graphRect.width * 0.95;
      final y = graphRect.top + i * barH;
      canvas.drawRect(
        Rect.fromLTWH(graphRect.left, y, w, barH * 0.9),
        Paint()..color = color.withValues(alpha: 0.85),
      );
    }
  }
}

class HiGraphPainter extends CustomPainter {
  HiGraphPainter({
    required this.mode,
    required this.detector,
    required this.histogram,
    required this.graphRect,
    required this.zoomLevel,
  });

  final DetectorMode mode;
  final HiDetectorRenderData detector;
  final HitsHistogramData histogram;
  final Rect graphRect;
  final int zoomLevel;

  @override
  void paint(Canvas canvas, Size size) {
    final color = ScreenBrightnessUtils.getSceneColor(detector.sourceType, detector.wavelengthNm);
    const r = HiGraphRenderer();
    if (mode == DetectorMode.intensity) {
      r.paintPdf(canvas, graphRect, detector.pdf, color, zoomLevel);
    } else {
      r.paintHits(canvas, graphRect, histogram, color, zoomLevel);
    }
  }

  @override
  bool shouldRepaint(covariant HiGraphPainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.detector.formationFactor != detector.formationFactor ||
        oldDelegate.histogram.bins != histogram.bins;
  }
}
