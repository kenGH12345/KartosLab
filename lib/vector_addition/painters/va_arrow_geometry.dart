import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../vector_addition_constants.dart';

/// PhET ArrowNode-like geometry (head 12×14, tail 3.5, dynamic head, fractional 0.5).
class VaArrowGeometry {
  const VaArrowGeometry({
    this.headWidth = VectorAdditionConstants.headWidth,
    this.headHeight = VectorAdditionConstants.headHeight,
    this.tailWidth = VectorAdditionConstants.tailWidth,
    this.fractionalHeadHeight = VectorAdditionConstants.fractionalHeadHeight,
    this.isHeadDynamic = true,
  });

  final double headWidth;
  final double headHeight;
  final double tailWidth;
  final double fractionalHeadHeight;
  final bool isHeadDynamic;

  void paint(
    Canvas canvas, {
    required Offset tail,
    required Offset tip,
    required Color color,
    bool dashed = false,
    Color? strokeColor,
    double strokeWidth = 0,
  }) {
    final delta = tip - tail;
    final len = delta.distance;
    if (len < VectorAdditionConstants.zeroThreshold) return;

    final angle = math.atan2(delta.dy, delta.dx);
    final sized = sizedHead(len);
    final hH = sized.headHeight;
    final hW = sized.headWidth;

    final shaftLen = math.max(0.0, len - hH);
    final dir = Offset(math.cos(angle), math.sin(angle));
    final nrm = Offset(-dir.dy, dir.dx);
    final shaftEnd = tail + dir * shaftLen;

    final path = Path();
    final halfT = dashed
        ? VectorAdditionConstants.componentTailWidth / 2
        : tailWidth / 2;
    final s0 = tail + nrm * halfT;
    final s1 = tail - nrm * halfT;
    final s2 = shaftEnd - nrm * halfT;
    final s3 = shaftEnd + nrm * halfT;
    path.moveTo(s0.dx, s0.dy);
    path.lineTo(s3.dx, s3.dy);
    path.lineTo(s2.dx, s2.dy);
    path.lineTo(s1.dx, s1.dy);
    path.close();

    final left = shaftEnd + nrm * (hW / 2);
    final right = shaftEnd - nrm * (hW / 2);
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(left.dx, left.dy);
    path.lineTo(right.dx, right.dy);
    path.close();

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    if (dashed) {
      _drawDashedShaft(canvas, tail, shaftEnd, color, halfT * 2);
      final head = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(right.dx, right.dy)
        ..close();
      canvas.drawPath(head, fill);
      if (strokeColor != null && strokeWidth > 0) {
        canvas.drawPath(
          head,
          Paint()
            ..color = strokeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth,
        );
      }
    } else {
      canvas.drawPath(path, fill);
      if (strokeColor != null && strokeWidth > 0) {
        canvas.drawPath(
          path,
          Paint()
            ..color = strokeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..isAntiAlias = true,
        );
      }
    }
  }

  /// Head size after dynamic / length clamps — for tests & hit-test alignment.
  ({double headWidth, double headHeight}) sizedHead(double viewLength) {
    var hH = headHeight;
    var hW = headWidth;
    if (isHeadDynamic && viewLength > 0) {
      final maxH = fractionalHeadHeight * viewLength;
      if (hH > maxH) {
        final scale = maxH / hH;
        hH = maxH;
        hW = headWidth * scale;
      }
    }
    if (hH > viewLength * 0.95 && viewLength > 0) {
      final scale = (viewLength * 0.95) / hH;
      hH *= scale;
      hW *= scale;
    }
    return (headWidth: hW, headHeight: hH);
  }

  void _drawDashedShaft(
    Canvas canvas,
    Offset a,
    Offset b,
    Color color,
    double width,
  ) {
    const dash = VectorAdditionConstants.componentTailDash;
    final total = b - a;
    final len = total.distance;
    if (len < 1) return;
    final dir = total / len;
    var pos = 0.0;
    var draw = true;
    var di = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;
    while (pos < len) {
      final seg = dash[di % dash.length];
      final next = math.min(len, pos + seg);
      if (draw) {
        canvas.drawLine(a + dir * pos, a + dir * next, paint);
      }
      draw = !draw;
      pos = next;
      di++;
    }
  }
}
