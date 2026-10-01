import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../curve_fitting_colors.dart';
import '../curve_fitting_constants.dart';
import '../solver/chi_barometer_color.dart';

/// Vertical barometer — PhET `BarometerNode` (+ χ² / r² tick maps).
///
/// Axis grows upward from a base line; fill rectangle sits to the RIGHT of the
/// axis with height = [fillProportion] * [axisHeight]. Tick labels sit LEFT of
/// the tick marks (axis scale references, not decoration).
class BarometerWidget extends StatelessWidget {
  const BarometerWidget({
    super.key,
    required this.fillProportion,
    required this.fillColor,
    required this.fillVisible,
    required this.tickPositionToLabels,
    required this.axisHeight,
    required this.tickWidth,
    this.showTopArrow = false,
    this.scale = 1.0,
  });

  /// χ² barometer with mapped ticks + optional top arrow.
  factory BarometerWidget.chiSquared({
    Key? key,
    required double chiSquared,
    required int numberOfPoints,
    required bool fillVisible,
    double scale = 1.0,
  }) {
    final ticks = <double, String>{0: '0'};
    for (final v in const [0.5, 1.0, 2.0, 3.0, 10.0, 30.0, 100.0]) {
      ticks[ChiBarometerColor.chiSquaredValueToRatio(v)] = _formatTick(v);
    }
    return BarometerWidget(
      key: key,
      fillProportion: ChiBarometerColor.chiSquaredValueToRatio(chiSquared),
      fillColor: ChiBarometerColor.getFillColorFromChiSquaredValue(
        chiSquared,
        numberOfPoints,
      ),
      fillVisible: fillVisible,
      tickPositionToLabels: ticks,
      axisHeight: CurveFittingConstants.barometerX2AxisHeight,
      tickWidth: CurveFittingConstants.barometerX2TickWidth,
      showTopArrow: true,
      scale: scale,
    );
  }

  /// r² barometer (linear 0…1 ticks).
  factory BarometerWidget.rSquared({
    Key? key,
    required double rSquared,
    required bool fillVisible,
    double scale = 1.0,
  }) {
    final ratio = rSquared.isNaN ? 0.0 : rSquared.clamp(0.0, 1.0);
    return BarometerWidget(
      key: key,
      fillProportion: ratio,
      fillColor: CurveFittingColors.blue,
      fillVisible: fillVisible,
      tickPositionToLabels: {
        0.0: '0',
        0.25: '0.25',
        0.5: '0.5',
        0.75: '0.75',
        1.0: '1',
      },
      axisHeight: CurveFittingConstants.barometerAxisHeight,
      tickWidth: CurveFittingConstants.barometerR2TickWidth,
      showTopArrow: false,
      scale: scale,
    );
  }

  final double fillProportion;
  final Color fillColor;
  final bool fillVisible;
  final Map<double, String> tickPositionToLabels;
  final double axisHeight;
  final double tickWidth;
  final bool showTopArrow;
  final double scale;

  static String _formatTick(double v) {
    if (v == v.roundToDouble()) return '${v.round()}';
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final h = axisHeight * scale;
    final arrowExtra = showTopArrow
        ? (CurveFittingConstants.barometerArrowHeadHeight * 1.5) * scale
        : 0.0;
    // Left room for tick labels (~36) + tick overhang; right for bar width.
    const labelPad = 36.0;
    final w = (labelPad + tickWidth + CurveFittingConstants.barometerBarWidth + 8) *
        scale;

    return SizedBox(
      width: w,
      height: h + arrowExtra + 4 * scale,
      child: CustomPaint(
        painter: _BarometerPainter(
          fillProportion: fillProportion,
          fillColor: fillColor,
          fillVisible: fillVisible,
          tickPositionToLabels: tickPositionToLabels,
          axisHeight: h,
          tickWidth: tickWidth * scale,
          barWidth: CurveFittingConstants.barometerBarWidth * scale,
          showTopArrow: showTopArrow,
          scale: scale,
          labelPad: labelPad * scale,
        ),
      ),
    );
  }
}

class _BarometerPainter extends CustomPainter {
  _BarometerPainter({
    required this.fillProportion,
    required this.fillColor,
    required this.fillVisible,
    required this.tickPositionToLabels,
    required this.axisHeight,
    required this.tickWidth,
    required this.barWidth,
    required this.showTopArrow,
    required this.scale,
    required this.labelPad,
  });

  final double fillProportion;
  final Color fillColor;
  final bool fillVisible;
  final Map<double, String> tickPositionToLabels;
  final double axisHeight;
  final double tickWidth;
  final double barWidth;
  final bool showTopArrow;
  final double scale;
  final double labelPad;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5 * scale
      ..style = PaintingStyle.stroke;

    // Base of axis near bottom; leave room for top arrow above axis tip.
    final arrowHead = CurveFittingConstants.barometerArrowHeadHeight * scale;
    final baseY = size.height -
        (showTopArrow ? 2 * scale : 2 * scale);
    final axisX = labelPad;

    // Axis line upward
    canvas.drawLine(
      Offset(axisX, baseY),
      Offset(axisX, baseY - axisHeight),
      linePaint,
    );

    // Base line
    canvas.drawLine(
      Offset(axisX - 5 * scale, baseY),
      Offset(axisX + barWidth + 5 * scale, baseY),
      linePaint,
    );

    // Fill to the RIGHT of axis, growing upward (PhET rotates rect by π).
    if (fillVisible) {
      final fillH = fillProportion.clamp(0.0, 1.05) * axisHeight;
      canvas.drawRect(
        Rect.fromLTWH(axisX, baseY - fillH, barWidth, fillH),
        Paint()..color = fillColor,
      );
    }

    // Ticks + labels
    for (final entry in tickPositionToLabels.entries) {
      final ty = baseY - entry.key * axisHeight;
      canvas.drawLine(
        Offset(axisX - 5 * scale, ty),
        Offset(axisX - 5 * scale + tickWidth, ty),
        linePaint,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: entry.value,
          style: TextStyle(
            color: Colors.black,
            fontSize: 11 * scale,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(axisX - 5 * scale - 2 * scale - tp.width, ty - tp.height / 2),
      );
    }

    if (showTopArrow) {
      final tipY = baseY - axisHeight - arrowHead * 1.5;
      final baseArrowY = baseY - axisHeight;
      _drawArrowHead(
        canvas,
        Offset(axisX, tipY),
        Offset(axisX, baseArrowY),
        CurveFittingConstants.barometerArrowHeadWidth * scale,
        arrowHead,
      );
      canvas.drawLine(
        Offset(axisX, baseArrowY),
        Offset(axisX, tipY + arrowHead),
        Paint()
          ..color = Colors.black
          ..strokeWidth =
              CurveFittingConstants.barometerArrowTailWidth * math.max(scale, 1)
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset tip,
    Offset from,
    double headWidth,
    double headHeight,
  ) {
    final dx = tip.dx - from.dx;
    final dy = tip.dy - from.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1e-6) return;
    final ux = dx / len;
    final uy = dy / len;
    final base = Offset(tip.dx - ux * headHeight, tip.dy - uy * headHeight);
    final px = -uy;
    final py = ux;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx + px * headWidth / 2, base.dy + py * headWidth / 2)
      ..lineTo(base.dx - px * headWidth / 2, base.dy - py * headWidth / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _BarometerPainter oldDelegate) =>
      oldDelegate.fillProportion != fillProportion ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.fillVisible != fillVisible ||
      oldDelegate.axisHeight != axisHeight ||
      oldDelegate.scale != scale;
}
