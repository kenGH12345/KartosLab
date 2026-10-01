import 'package:flutter/material.dart';

import '../../data/graph_data.dart';
import '../../render/common/screen_brightness_utils.dart';
import '../../render_data/high_intensity/wave_field_render_data.dart';

/// Single Particles graph: instantaneous PDF curve + 100-bin hit histogram.
class SpGraphPainter extends CustomPainter {
  SpGraphPainter({
    required this.detector,
    required this.histogram,
    required this.graphRect,
    required this.zoomLevel,
  });

  final HiDetectorRenderData detector;
  final HitsHistogramData histogram;
  final Rect graphRect;
  final int zoomLevel;

  @override
  void paint(Canvas canvas, Size size) {
    final color = ScreenBrightnessUtils.getSceneColor(detector.sourceType, detector.wavelengthNm);
    canvas.drawRect(graphRect, Paint()..color = const Color(0xFF1A1A1A));

    final visibleFraction = (7 - zoomLevel.clamp(1, 6)) / 6.0;

    // Hit histogram bars (display-only accumulation).
    var maxBin = 1;
    for (final b in histogram.bins) {
      if (b > maxBin) {
        maxBin = b;
      }
    }
    final nBins = histogram.binCount;
    final startBin = ((1 - visibleFraction) / 2 * nBins).floor();
    final endBin = (nBins - startBin).clamp(startBin + 1, nBins);
    final sliceBins = endBin - startBin;
    final barH = graphRect.height / sliceBins;
    for (var i = 0; i < sliceBins; i++) {
      final binIndex = startBin + (sliceBins - 1 - i);
      final w = (histogram.bins[binIndex] / maxBin) * graphRect.width * 0.95;
      if (w <= 0) {
        continue;
      }
      canvas.drawRect(
        Rect.fromLTWH(graphRect.left, graphRect.top + i * barH, w, barH * 0.9),
        Paint()..color = color.withValues(alpha: 0.45),
      );
    }

    // Instantaneous PDF curve (not derived from histogram).
    final pdf = detector.pdf;
    if (pdf.isEmpty || !pdf.any((v) => v > 0)) {
      return;
    }
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
      final pdfI = slice.length - 1 - i;
      final x = graphRect.left + (slice[pdfI] / maxV) * graphRect.width * 0.95;
      final y = graphRect.top + (i / (slice.length - 1).clamp(1, slice.length)) * graphRect.height;
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

  @override
  bool shouldRepaint(covariant SpGraphPainter oldDelegate) {
    return oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.detector.isEmitting != detector.isEmitting ||
        oldDelegate.detector.pdf != detector.pdf ||
        oldDelegate.histogram.bins != histogram.bins;
  }
}
