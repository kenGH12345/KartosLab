import 'package:flutter/material.dart';

import '../fmw_colors.dart';
import '../fmw_constants.dart';
import '../render/fmw_render_data.dart';

/// Vertical bars for harmonic amplitudes A1..An.
class AmplitudesBarsPainter extends CustomPainter {
  AmplitudesBarsPainter({
    required this.bars,
    required this.yMin,
    required this.yMax,
    this.maxHarmonics = FmwConstants.maxHarmonics,
  });

  final List<FmwAmplitudeBarData> bars;
  final double yMin;
  final double yMax;
  final int maxHarmonics;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = FmwColors.chartBackground);

    final ySpan = yMax - yMin;
    if (ySpan <= 0) return;

    // Zero line
    if (yMin < 0 && yMax > 0) {
      final zeroY = size.height - ((0 - yMin) / ySpan) * size.height;
      canvas.drawLine(
        Offset(0, zeroY),
        Offset(size.width, zeroY),
        Paint()
          ..color = FmwColors.axisStroke
          ..strokeWidth = 1.25,
      );
    }

    // Grid at ±0.5 etc.
    final gridPaint = Paint()
      ..color = FmwColors.chartGridLinesStroke
      ..strokeWidth = 1;
    for (var v = yMin; v <= yMax + 1e-9; v += 0.5) {
      final ny = (v - yMin) / ySpan;
      final dy = size.height - ny * size.height;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    final n = bars.isEmpty ? 1 : bars.length;
    final slot = size.width / n;
    final barWidth = slot * 0.55;
    final zeroY = size.height - ((0 - yMin) / ySpan) * size.height;

    for (var i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final cx = (i + 0.5) * slot;
      final topY = size.height - ((bar.value - yMin) / ySpan) * size.height;
      final top = bar.value >= 0 ? topY : zeroY;
      final bottom = bar.value >= 0 ? zeroY : topY;
      final r = Rect.fromLTRB(cx - barWidth / 2, top, cx + barWidth / 2, bottom);
      canvas.drawRect(r, Paint()..color = bar.color);
    }

    canvas.drawRect(
      rect.deflate(0.5),
      Paint()
        ..color = FmwColors.panelStroke
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant AmplitudesBarsPainter oldDelegate) {
    return oldDelegate.bars != bars ||
        oldDelegate.yMin != yMin ||
        oldDelegate.yMax != yMax ||
        oldDelegate.maxHarmonics != maxHarmonics;
  }
}
