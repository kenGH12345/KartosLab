// Copyright 2024-2026, University of Colorado Boulder
// Flutter port of QuantumMeasurementHistogram.ts

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../quantum_measurement_colors.dart';
import '../quantum_measurement_constants.dart';

// ── Data model ────────────────────────────────────────────────────────────────

/// Immutable snapshot of histogram data for two outcomes.
class HistogramData {
  const HistogramData({
    required this.leftCount,
    required this.rightCount,
    this.leftExpected,
    this.rightExpected,
  });

  final int    leftCount;
  final int    rightCount;
  final double? leftExpected;   // 0..1 ratio
  final double? rightExpected;  // 0..1 ratio

  int get total => leftCount + rightCount;

  double get leftFraction  => total == 0 ? 0 : leftCount  / total;
  double get rightFraction => total == 0 ? 0 : rightCount / total;

  static const HistogramData empty = HistogramData(leftCount: 0, rightCount: 0);
}

// ── Widget ────────────────────────────────────────────────────────────────────

/// Animated histogram used on the Coins, Photons, and Spin screens.
/// Corresponds to `QuantumMeasurementHistogram.ts`.
///
/// Animates bar height each time [data] changes.
class QuantumMeasurementHistogram extends StatefulWidget {
  const QuantumMeasurementHistogram({
    super.key,
    required this.data,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftColor,
    required this.rightColor,
    this.showExpected = false,
    this.expectedColor = QuantumMeasurementColors.expectedPercentageFill,
    this.width  = 220,
    this.height = 160,
  });

  final HistogramData data;
  final String leftLabel;
  final String rightLabel;
  final Color  leftColor;
  final Color  rightColor;
  final bool   showExpected;
  final Color  expectedColor;
  final double width;
  final double height;

  @override
  State<QuantumMeasurementHistogram> createState() => _QuantumMeasurementHistogramState();
}

class _QuantumMeasurementHistogramState extends State<QuantumMeasurementHistogram>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _animProgress;

  double _prevLeft  = 0;
  double _prevRight = 0;
  double _targetLeft  = 0;
  double _targetRight = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _animProgress = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(QuantumMeasurementHistogram old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) {
      _prevLeft   = _currentLeft;
      _prevRight  = _currentRight;
      _targetLeft  = widget.data.leftFraction;
      _targetRight = widget.data.rightFraction;
      _ctrl.forward(from: 0);
    }
  }

  double get _currentLeft  => _prevLeft  + (_targetLeft  - _prevLeft)  * _animProgress.value;
  double get _currentRight => _prevRight + (_targetRight - _prevRight) * _animProgress.value;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animProgress,
        builder: (_, _) => CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _HistogramPainter(
            leftFraction:  _currentLeft,
            rightFraction: _currentRight,
            leftLabel:  widget.leftLabel,
            rightLabel: widget.rightLabel,
            leftColor:  widget.leftColor,
            rightColor: widget.rightColor,
            showExpected:  widget.showExpected,
            expectedLeft:  widget.data.leftExpected  ?? _targetLeft,
            expectedRight: widget.data.rightExpected ?? _targetRight,
            expectedColor: widget.expectedColor,
            totalCount: widget.data.total,
          ),
        ),
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _HistogramPainter extends CustomPainter {
  const _HistogramPainter({
    required this.leftFraction,
    required this.rightFraction,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftColor,
    required this.rightColor,
    required this.showExpected,
    required this.expectedLeft,
    required this.expectedRight,
    required this.expectedColor,
    required this.totalCount,
  });

  final double leftFraction;
  final double rightFraction;
  final String leftLabel;
  final String rightLabel;
  final Color  leftColor;
  final Color  rightColor;
  final bool   showExpected;
  final double expectedLeft;
  final double expectedRight;
  final Color  expectedColor;
  final int    totalCount;

  // Layout constants
  static const double _leftPad    = 50;
  static const double _rightPad   = 10;
  static const double _topPad     = 12;
  static const double _bottomPad  = 36;
  static const double _barGap     = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = size.width  - _leftPad - _rightPad;
    final chartH = size.height - _topPad  - _bottomPad;
    final bottomY = size.height - _bottomPad;

    _drawAxes(canvas, size, chartW, chartH, bottomY);
    _drawYLabels(canvas, size, chartH, bottomY);

    final barW = (chartW - _barGap * 3) / 2;

    _drawBar(
      canvas: canvas,
      left: _leftPad + _barGap,
      bottom: bottomY,
      width: barW,
      fraction: leftFraction,
      maxH: chartH,
      color: leftColor,
    );
    _drawBar(
      canvas: canvas,
      left: _leftPad + _barGap * 2 + barW,
      bottom: bottomY,
      width: barW,
      fraction: rightFraction,
      maxH: chartH,
      color: rightColor,
    );

    if (showExpected) {
      _drawExpectedLine(canvas, _leftPad + _barGap, barW, bottomY, chartH, expectedLeft);
      _drawExpectedLine(canvas, _leftPad + _barGap * 2 + barW, barW, bottomY, chartH, expectedRight);
    }

    _drawXLabels(canvas, size, barW, bottomY);
    _drawCountLabel(canvas, size);
  }

  void _drawAxes(Canvas canvas, Size size, double chartW, double chartH, double bottomY) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    // Y axis
    canvas.drawLine(Offset(_leftPad, _topPad), Offset(_leftPad, bottomY), paint);
    // X axis
    canvas.drawLine(Offset(_leftPad, bottomY), Offset(size.width - _rightPad, bottomY), paint);
  }

  void _drawYLabels(Canvas canvas, Size size, double chartH, double bottomY) {
    // Tick marks at 0%, 25%, 50%, 75%, 100%
    for (final frac in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      final y = bottomY - frac * chartH;
      final tickPaint = Paint()..color = Colors.black..strokeWidth = 1;
      canvas.drawLine(Offset(_leftPad - 4, y), Offset(_leftPad, y), tickPaint);

      final label = '${(frac * 100).toInt()}%';
      final tp = _makeTextPainter(label, fontSize: 10, color: Colors.black);
      tp.layout();
      tp.paint(canvas, Offset(_leftPad - 6 - tp.width, y - tp.height / 2));
    }
  }

  void _drawBar({
    required Canvas canvas,
    required double left,
    required double bottom,
    required double width,
    required double fraction,
    required double maxH,
    required Color  color,
  }) {
    final barH = fraction * maxH;
    if (barH < 1) return;

    final rect = Rect.fromLTWH(left, bottom - barH, width, barH);
    // Fill
    canvas.drawRect(rect, Paint()..color = color);
    // Border
    canvas.drawRect(
      rect,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Percentage label on top
    final pct = '${(fraction * 100).round()}%';
    final tp = _makeTextPainter(pct, fontSize: 11, color: Colors.black);
    tp.layout();
    tp.paint(canvas, Offset(left + (width - tp.width) / 2, bottom - barH - tp.height - 2));
  }

  void _drawExpectedLine(
    Canvas canvas, double left, double width, double bottomY, double maxH, double fraction,
  ) {
    final y = bottomY - fraction * maxH;
    final paint = Paint()
      ..color = QuantumMeasurementColors.expectedPercentageFill
      ..strokeWidth = QuantumMeasurementConstants.expectedPercentageLineWidth
      ..style = PaintingStyle.stroke;

    // Dashed horizontal line
    double x = left;
    const dash = 5.0, gap = 3.0;
    while (x < left + width) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + dash, left + width), y), paint);
      x += dash + gap;
    }
  }

  void _drawXLabels(Canvas canvas, Size size, double barW, double bottomY) {
    final gap = _barGap;
    final centers = [
      _leftPad + gap + barW / 2,
      _leftPad + gap * 2 + barW + barW / 2,
    ];
    final labels = [leftLabel, rightLabel];

    for (var i = 0; i < 2; i++) {
      final tp = _makeTextPainter(labels[i], fontSize: 12, color: Colors.black, bold: true);
      tp.layout(maxWidth: barW + 10);
      tp.paint(canvas, Offset(centers[i] - tp.width / 2, bottomY + 6));
    }
  }

  void _drawCountLabel(Canvas canvas, Size size) {
    if (totalCount == 0) return;
    final tp = _makeTextPainter('n = $totalCount', fontSize: 11, color: Colors.black54);
    tp.layout();
    tp.paint(canvas, Offset(size.width - _rightPad - tp.width, _topPad));
  }

  TextPainter _makeTextPainter(
    String text, {
    required double fontSize,
    required Color  color,
    bool bold = false,
  }) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize:   fontSize,
          color:      color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
  }

  @override
  bool shouldRepaint(_HistogramPainter old) =>
      old.leftFraction  != leftFraction  ||
      old.rightFraction != rightFraction ||
      old.showExpected  != showExpected  ||
      old.totalCount    != totalCount;
}
