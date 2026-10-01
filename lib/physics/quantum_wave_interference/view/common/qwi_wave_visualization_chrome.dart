import 'dart:math' as math;

import 'package:flutter/material.dart';

/// PhET `WaveVisualizationNode` distance / time chrome helpers.
abstract final class QwiWaveScale {
  static const double scaleMargin = 8;
  static const double targetBarPx = 50;
  static const double minBarPx = 25;
  static const double maxBarPx = 100;
  static const List<double> niceMultipliers = [1, 2, 5];
  static const double tickHeight = 6;

  /// Finds a "nice" round physical distance whose bar is near [targetBarPx].
  static ({double distanceMeters, double barPixels}) computeNiceScale({
    required double regionWidthMeters,
    required double regionWidthPixels,
  }) {
    if (regionWidthMeters <= 0 || regionWidthPixels <= 0) {
      return (distanceMeters: 1e-6, barPixels: targetBarPx);
    }
    final metersPerPixel = regionWidthMeters / regionWidthPixels;
    final targetMeters = targetBarPx * metersPerPixel;
    final exponent = math.log(targetMeters) / math.ln10;
    final expFloor = exponent.floor();

    var bestDistance = targetMeters;
    var bestPixels = targetBarPx;
    var bestError = double.infinity;

    for (var e = expFloor - 1; e <= expFloor + 1; e++) {
      for (final m in niceMultipliers) {
        final candidate = m * math.pow(10.0, e).toDouble();
        final pixels = candidate / metersPerPixel;
        if (pixels >= minBarPx && pixels <= maxBarPx) {
          final error = (pixels - targetBarPx).abs();
          if (error < bestError) {
            bestError = error;
            bestDistance = candidate;
            bestPixels = pixels;
          }
        }
      }
    }
    return (distanceMeters: bestDistance, barPixels: bestPixels);
  }

  /// Formats meters as mm / µm / nm (PhET `formatDistance`).
  static String formatDistance(double meters) {
    if (meters >= 1e-3) {
      final mm = meters * 1e3;
      return '${_formatValue(mm)} mm';
    }
    if (meters >= 1e-6) {
      final um = meters * 1e6;
      return '${_formatValue(um)} µm';
    }
    final nm = meters * 1e9;
    return '${_formatValue(nm)} nm';
  }

  /// PhET: `>= 10` → roundSymmetric; else `parseFloat(toPrecision(2))`.
  static String _formatValue(double v) {
    if (v >= 10) return '${v.round()}';
    final n = num.parse(v.toStringAsPrecision(2));
    return n == n.roundToDouble() ? '${n.round()}' : '$n';
  }

  /// Fixed PhET timescale caption (English MVP).
  static const String timeScaleLabel = '1 fs = 1 × 10⁻¹⁵ s';
}

/// Overlay: white border + distance bar (top-left) + time scale (bottom-left).
///
/// Place as a sibling on top of [WaveFieldPixelPainter] inside the wave region box.
class QwiWaveVisualizationChrome extends StatelessWidget {
  const QwiWaveVisualizationChrome({
    super.key,
    required this.width,
    required this.height,
    required this.regionWidthMeters,
  });

  final double width;
  final double height;
  final double regionWidthMeters;

  @override
  Widget build(BuildContext context) {
    final scale = QwiWaveScale.computeNiceScale(
      regionWidthMeters: regionWidthMeters,
      regionWidthPixels: width,
    );
    return IgnorePointer(
      child: CustomPaint(
        key: const Key('qwi_wave_chrome'),
        size: Size(width, height),
        painter: _WaveChromePainter(
          barPixels: scale.barPixels,
          distanceLabel: QwiWaveScale.formatDistance(scale.distanceMeters),
          timeLabel: QwiWaveScale.timeScaleLabel,
        ),
      ),
    );
  }
}

class _WaveChromePainter extends CustomPainter {
  _WaveChromePainter({
    required this.barPixels,
    required this.distanceLabel,
    required this.timeLabel,
  });

  final double barPixels;
  final String distanceLabel;
  final String timeLabel;

  static const _white = Colors.white;
  static const _font = TextStyle(
    fontFamily: 'Arial',
    fontSize: 11,
    color: _white,
    height: 1.0,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // 1px white border (PhET backgroundRect stroke).
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = _white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    const margin = QwiWaveScale.scaleMargin;
    const tickH = QwiWaveScale.tickHeight;
    final stroke = Paint()
      ..color = _white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final barY = margin + tickH / 2;
    final barLeft = margin;
    final barRight = margin + barPixels;

    // Left / right ticks + bar.
    canvas.drawLine(Offset(barLeft, margin), Offset(barLeft, margin + tickH), stroke);
    canvas.drawLine(Offset(barRight, margin), Offset(barRight, margin + tickH), stroke);
    canvas.drawLine(Offset(barLeft, barY), Offset(barRight, barY), stroke);

    final distTp = TextPainter(
      text: TextSpan(text: distanceLabel, style: _font),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: 80);
    distTp.paint(canvas, Offset(barRight + 4, margin + (tickH - distTp.height) / 2));

    final timeTp = TextPainter(
      text: TextSpan(text: timeLabel, style: _font),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: 160);
    timeTp.paint(
      canvas,
      Offset(margin, size.height - margin - timeTp.height),
    );
  }

  @override
  bool shouldRepaint(covariant _WaveChromePainter old) =>
      old.barPixels != barPixels ||
      old.distanceLabel != distanceLabel ||
      old.timeLabel != timeLabel;
}
