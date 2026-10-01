import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/intro_controller.dart';
import '../model/histogram.dart';
import '../plinko_colors.dart';
import '../plinko_strings.dart';
import '../transform/plinko_mvt.dart';
import 'histogram_layout.dart';

/// Histogram matching `HistogramNode.js` (background, banner, bars, axes).
class HistogramPainter extends CustomPainter {
  HistogramPainter({
    required this.histogram,
    required this.mvt,
    required this.mode,
    this.idealNormalized,
    this.showIdeal = false,
  });

  final Histogram histogram;
  final PlinkoMvt mvt;
  final HistogramDisplayMode mode;
  final List<double>? idealNormalized;
  final bool showIdeal;

  static const _bannerColor = Color.fromRGBO(46, 49, 146, 1);

  @override
  void paint(Canvas canvas, Size size) {
    final layout = HistogramLayout(mvt);
    final nBins = histogram.binCount;
    final area = layout.area;
    final banner = layout.banner;
    final plot = layout.plot;
    final maxBarH = layout.maxBarHeight;
    final xSpacing = layout.binWidthFor(nBins);
    final s = mvt.layoutScale;

    // BackgroundNode
    canvas.drawRect(area, Paint()..color = Colors.white);
    canvas.drawRect(
      area,
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // XBannerNode background
    canvas.drawRect(banner, Paint()..color = _bannerColor);

    // Banner vertical separators (bins 1..n-1)
    for (var i = 1; i < nBins; i++) {
      final x = layout.binLeft(i, nBins);
      canvas.drawLine(
        Offset(x, banner.top),
        Offset(x, banner.bottom),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1,
      );
    }

    // Bars always use normalized sample distribution (HistogramBarNode).
    final normalized = histogram.getNormalizedSampleDistribution();
    for (var i = 0; i < nBins; i++) {
      final left = layout.binLeft(i, nBins);
      final barH = maxBarH * (i < normalized.length ? normalized[i] : 0);
      if (barH > 0) {
        final rect = Rect.fromLTWH(left, plot.bottom - barH, xSpacing, barH);
        canvas.drawRect(rect, Paint()..color = PlinkoColors.histogramBarFill);
        canvas.drawRect(
          rect,
          Paint()
            ..color = PlinkoColors.histogramBarStroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      if (showIdeal &&
          idealNormalized != null &&
          i < idealNormalized!.length) {
        final idealH = idealNormalized![i] * maxBarH;
        if (idealH > 0) {
          final idealRect =
              Rect.fromLTWH(left, plot.bottom - idealH, xSpacing, idealH);
          canvas.drawRect(
            idealRect,
            Paint()
              ..color = PlinkoColors.binomialBarStroke
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
    }

    // Banner values (XBannerNode)
    final maxBinCount = histogram.getMaximumBinCount();
    final bannerFont = _bannerFontSize(nBins, maxBinCount, mode) * s;
    for (var i = 0; i < nBins; i++) {
      final String label;
      if (mode == HistogramDisplayMode.fraction) {
        final v = histogram.getFractionalBinCount(i);
        label = nBins > 16 ? v.toStringAsFixed(2) : v.toStringAsFixed(3);
      } else {
        label = '${histogram.getBinCount(i)}';
      }
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.white,
            fontSize: bannerFont,
            fontFamily: 'Arial',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: xSpacing);
      tp.paint(
        canvas,
        Offset(
          layout.binCenterX(i, nBins) - tp.width / 2,
          banner.center.dy - tp.height / 2,
        ),
      );
    }

    // XAxisNode — tick labels + Bin
    double tickBottom = layout.tickLabelTop;
    for (var i = 0; i < nBins; i++) {
      final tick = TextPainter(
        text: TextSpan(
          text: '$i',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16 * s,
            fontFamily: 'Arial',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final top = layout.tickLabelTop;
      tick.paint(
        canvas,
        Offset(layout.binCenterX(i, nBins) - tick.width / 2, top),
      );
      tickBottom = math.max(tickBottom, top + tick.height);
    }

    final binLabel = TextPainter(
      text: TextSpan(
        text: PlinkoStrings.bin,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16 * s,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    binLabel.paint(
      canvas,
      Offset(
        area.center.dx - binLabel.width / 2,
        tickBottom + mvt.layoutToViewDelta(HistogramLayout.binLabelGapLayout),
      ),
    );

    // YAxisNode — Count / Fraction (outside bounds)
    final yText = mode == HistogramDisplayMode.fraction
        ? PlinkoStrings.fraction
        : PlinkoStrings.count;
    final yLabel = TextPainter(
      text: TextSpan(
        text: yText,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20 * s,
          fontWeight: FontWeight.w800,
          fontFamily: 'Arial',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // YAxisNode: left = axisLeft-30 (AABB of rotated text), centerY = hist center.
    // After −π/2, text height maps to +X → shift by height/2 so AABB.left hits yLabelLeft.
    canvas.save();
    canvas.translate(
      layout.yLabelLeft + yLabel.height / 2,
      layout.histogramCenterY,
    );
    canvas.rotate(-math.pi / 2);
    yLabel.paint(canvas, Offset(-yLabel.width / 2, -yLabel.height / 2));
    canvas.restore();

    // Average triangles (HistogramBarNode) — sample + ideal
    if (histogram.landedBallsNumber > 0) {
      _paintTriangle(
        canvas,
        layout,
        layout.binCenterX(
          // continuous average position via linear interpolation of bin centers
          0,
          nBins,
        ),
        // use value position: (average+0.5)/nBins * width + minX ≈ center of mean
        sample: true,
        centerX: _valueCenterX(layout, histogram.average, nBins),
      );
    }
    if (showIdeal && idealNormalized != null) {
      // theoretical average from bin expectation ≈ sum i*p_i; caller passes
      // via probability model — approximate from ideal peak if needed.
      // Lab screen passes showIdeal; use μ from numberOfRows*p when available.
      // Triangle for ideal: only when visible — position from ideal mean index.
      final mu = _idealMeanIndex(idealNormalized!);
      _paintTriangle(
        canvas,
        layout,
        0,
        sample: false,
        centerX: _valueCenterX(layout, mu, nBins),
      );
    }
  }

  double _valueCenterX(HistogramLayout layout, double value, int nBins) {
    // Histogram.getValuePosition ≈ getBinCenterX(value) with continuous value
    final a = layout.area;
    return a.left + ((value + 0.5) / nBins) * a.width;
  }

  double _idealMeanIndex(List<double> ideal) {
    var sum = 0.0;
    var w = 0.0;
    for (var i = 0; i < ideal.length; i++) {
      sum += i * ideal[i];
      w += ideal[i];
    }
    return w > 0 ? sum / w : 0;
  }

  void _paintTriangle(
    Canvas canvas,
    HistogramLayout layout,
    double _, {
    required bool sample,
    required double centerX,
  }) {
    final maxY = layout.area.bottom;
    final hw = layout.triangleW / 2;
    final th = layout.triangleH;
    final path = Path()
      ..moveTo(centerX, maxY)
      ..lineTo(centerX - hw, maxY + th)
      ..lineTo(centerX + hw, maxY + th)
      ..close();
    if (sample) {
      canvas.drawPath(path, Paint()..color = PlinkoColors.histogramBarFill);
      canvas.drawPath(
        path,
        Paint()
          ..color = PlinkoColors.histogramBarStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..color = PlinkoColors.binomialBarStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  /// Banner font sizing — mirrors XBannerNode.js thresholds.
  double _bannerFontSize(
    int nBins,
    int maxBinCount,
    HistogramDisplayMode mode,
  ) {
    if (mode == HistogramDisplayMode.fraction) {
      if (nBins > 23) return 8;
      if (nBins > 20) return 10;
      if (nBins > 16) return 12;
      if (nBins > 9) return 14;
      return 16;
    }
    if (maxBinCount > 999 && nBins > 23) return 8;
    if (maxBinCount > 999 && nBins > 20) return 10;
    if (maxBinCount > 999 && nBins > 16) return 12;
    if (maxBinCount > 99 && nBins > 23) return 10;
    if (maxBinCount > 99 && nBins > 20) return 12;
    if (maxBinCount > 99 && nBins > 15) return 14;
    if (maxBinCount > 9 && nBins > 23) return 12;
    if (maxBinCount > 9 && nBins > 18) return 14;
    if (nBins > 9) return 14;
    return 16;
  }

  @override
  bool shouldRepaint(covariant HistogramPainter oldDelegate) => true;
}
