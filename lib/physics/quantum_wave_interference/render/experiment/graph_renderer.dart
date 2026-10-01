import 'package:flutter/material.dart';

import '../../data/graph_data.dart';
import '../../domain/detector_mode.dart';
import '../../render_data/experiment/fraunhofer_render_data.dart';
import '../common/screen_brightness_utils.dart';

/// Intensity curve / hits histogram in design coordinates.
class GraphRenderer {
  const GraphRenderer();

  void paintIntensity(
    Canvas canvas,
    Rect graphRect,
    FraunhoferRenderData data, {
    required int graphZoomLevel,
    required int minGraphZoomLevel,
    required int maxGraphZoomLevel,
  }) {
    _paintGraphChrome(canvas, graphRect);
    if (!data.isEmitting || data.intensities.isEmpty) {
      return;
    }

    final zoomScale = _linear(
      minGraphZoomLevel.toDouble(),
      maxGraphZoomLevel.toDouble(),
      0.3,
      2.0,
      graphZoomLevel.toDouble(),
    );
    final color = ScreenBrightnessUtils.getSceneColor(data.sourceType, data.wavelengthNm);
    final n = data.intensities.length;
    final fill = Path()..moveTo(graphRect.left, graphRect.bottom);
    final stroke = Path();

    for (var i = 0; i < n; i++) {
      final x = graphRect.left + (i / (n - 1)) * graphRect.width;
      final y = (graphRect.bottom - data.intensities[i] * data.sourceStrength * graphRect.height * zoomScale)
          .clamp(graphRect.top, graphRect.bottom);
      fill.lineTo(x, y);
      if (i == 0) {
        stroke.moveTo(x, y);
      } else {
        stroke.lineTo(x, y);
      }
    }
    fill
      ..lineTo(graphRect.right, graphRect.bottom)
      ..close();
    canvas.save();
    canvas.clipRect(graphRect);
    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.3));
    canvas.drawPath(
      stroke,
      Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();
  }

  void paintHitsHistogram(
    Canvas canvas,
    Rect graphRect,
    HitsHistogramData hist,
    Color color, {
    required int graphZoomLevel,
    required int maxGraphZoomLevel,
  }) {
    _paintGraphChrome(canvas, graphRect);
    if (hist.bins.every((b) => b == 0)) {
      return;
    }
    final zoomStepsFromMax = maxGraphZoomLevel - graphZoomLevel;
    final zoomScale = 1.0 / (1 << zoomStepsFromMax.clamp(0, 8));
    final barW = graphRect.width / hist.binCount;
    canvas.save();
    canvas.clipRect(graphRect);
    for (var i = 0; i < hist.binCount; i++) {
      if (hist.bins[i] <= 0) continue;
      final h = (hist.bins[i] * barW * zoomScale).clamp(0.0, graphRect.height);
      canvas.drawRect(
        Rect.fromLTWH(graphRect.left + i * barW, graphRect.bottom - h, barW, h),
        Paint()..color = color.withValues(alpha: 0.7),
      );
    }
    canvas.restore();
  }

  double _linear(double x0, double x1, double y0, double y1, double x) {
    if (x1 == x0) return y0;
    final t = ((x - x0) / (x1 - x0)).clamp(0.0, 1.0);
    return y0 + (y1 - y0) * t;
  }

  void _paintGraphChrome(Canvas canvas, Rect graphRect) {
    canvas.drawRect(graphRect, Paint()..color = Colors.white);
    final grid = Paint()
      ..color = const Color(0xFFC8C8C8)
      ..strokeWidth = 0.5;
    const nx = 10;
    const ny = 4;
    for (var i = 1; i < nx; i++) {
      final x = graphRect.left + graphRect.width * i / nx;
      if (i == nx / 2) {
        canvas.drawLine(
          Offset(x, graphRect.top),
          Offset(x, graphRect.bottom),
          Paint()
            ..color = const Color(0xFFC8C8C8)
            ..strokeWidth = 0.75
            ..style = PaintingStyle.stroke,
        );
      } else {
        canvas.drawLine(Offset(x, graphRect.top), Offset(x, graphRect.bottom), grid);
      }
    }
    for (var j = 1; j < ny; j++) {
      final y = graphRect.top + graphRect.height * j / ny;
      canvas.drawLine(Offset(graphRect.left, y), Offset(graphRect.right, y), grid);
    }
    canvas.drawRect(
      graphRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}

class ExperimentGraphPainter extends CustomPainter {
  ExperimentGraphPainter({
    required this.mode,
    required this.fraunhofer,
    required this.histogram,
    required this.graphRect,
    required this.graphZoomLevel,
    required this.maxGraphZoomLevel,
    required this.minGraphZoomLevel,
  });

  final DetectorMode mode;
  final FraunhoferRenderData fraunhofer;
  final HitsHistogramData histogram;
  final Rect graphRect;
  final int graphZoomLevel;
  final int maxGraphZoomLevel;
  final int minGraphZoomLevel;

  @override
  void paint(Canvas canvas, Size size) {
    const renderer = GraphRenderer();
    if (mode == DetectorMode.intensity) {
      renderer.paintIntensity(
        canvas,
        graphRect,
        fraunhofer,
        graphZoomLevel: graphZoomLevel,
        minGraphZoomLevel: minGraphZoomLevel,
        maxGraphZoomLevel: maxGraphZoomLevel,
      );
    } else {
      final color = ScreenBrightnessUtils.getSceneColor(fraunhofer.sourceType, fraunhofer.wavelengthNm);
      renderer.paintHitsHistogram(
        canvas,
        graphRect,
        histogram,
        color,
        graphZoomLevel: graphZoomLevel,
        maxGraphZoomLevel: maxGraphZoomLevel,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ExperimentGraphPainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.fraunhofer != fraunhofer ||
        oldDelegate.histogram.bins != histogram.bins ||
        oldDelegate.graphZoomLevel != graphZoomLevel ||
        oldDelegate.graphRect != graphRect;
  }
}
