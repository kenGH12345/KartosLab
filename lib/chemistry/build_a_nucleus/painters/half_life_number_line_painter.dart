/// 半衰期数轴基础视觉：轴 + 刻度 + 指针。
///
/// 坐标对标 bamboo `ChartTransform.modelToViewX`（identity xTransform）：
/// `viewX = linear(-24, 24, 0, viewWidth, exponent)`
/// 不使用核画布的 [CanvasProjection]（那是核世界坐标）。
///
/// 只消费 [HalfLifeNumberLineReading]，不查表、不解读 halfLifeNumber 哨兵。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/half_life_number_line.dart';
import '../model/half_life_pointer_animator.dart';

/// ChartTransform 水平映射。[已确认] `modelToView(HORIZONTAL, x)` + identity transform。
class HalfLifeChartTransform {
  const HalfLifeChartTransform._();

  /// 原版 `numberLineWidth: 550`。[已确认] HalfLifeInformationNode
  /// Flutter 用传入的 [viewWidth]（容器宽），不把 550 写死进绘制。
  static const double originalViewWidth = 550;

  static double modelToViewX(double exponent, double viewWidth) {
    const min = HalfLifeNumberLine.startExponent;
    const max = HalfLifeNumberLine.endExponent;
    return (exponent - min) / (max - min) * viewWidth;
  }
}

/// 原版像素级几何（相对轴线）。[已确认] HalfLifeNumberLineNode / TickMarkSet
class HalfLifeNumberLineMetrics {
  const HalfLifeNumberLineMetrics._();

  /// TickMarkSet.extent [已确认] tickMarkExtent: 18
  static const double tickExtent = 18;

  /// [已确认] tickMarkSet lineWidth: 2
  static const double tickStrokeWidth = 2;

  /// [已确认] halfLifeArrowLength: 30
  static const double arrowLength = 30;

  /// [已确认] ArrowNode tailWidth: 4
  static const double arrowTailWidth = 4;

  /// [已确认] ArrowNode headWidth: 12
  static const double arrowHeadWidth = 12;

  /// ArrowNode 默认 headHeight 未在 BAN 中覆盖。[待确认] 用 10 近似
  static const double arrowHeadHeight = 10;

  /// 轴线在画布中的 y：为向下箭头留出 [arrowLength]。
  /// 原版 numberLineNode 内轴线在 y=0、箭头向上伸出；此处把原点下移以便画在正坐标。
  /// [推测：平移，相对几何不变]
  static const double axisY = arrowLength;

  /// [已确认] numberLineLabelFont = PhetFont(15)
  static const double labelFontSize = 15;

  /// [已确认] RichText supScale: 0.6
  static const double superscriptScale = 0.6;

  /// [已确认] BANColors.halfLifeColorProperty default rgb(255,0,255)
  static const Color pointerColor = Color(0xFFFF00FF);

  /// [已确认] HalfLifeNumberLineNode TITLE_FONT = PhetFont(24)
  static const double readoutFontSize = 24;

  /// [已确认] ScientificNotationNode exponentScale 默认 0.75
  static const double readoutExponentScale = 0.75;

  /// 读数条预留高度（字号 24 + HBox align bottom）。像素级位置 [待确认]
  static const double readoutBandHeight = readoutFontSize * 1.5;
}

class HalfLifeNumberLinePainter extends CustomPainter {
  HalfLifeNumberLinePainter({
    required this.reading,
    this.displayExponent,
    this.displayRotation,
  });

  final HalfLifeNumberLineReading reading;

  /// 动画中的 model X；为 null 时用 Reading 的静态目标。
  final double? displayExponent;

  /// 动画中的旋转（0 向下 / -π/2 向右）；为 null 时用 Reading.pointerPointsRight。
  final double? displayRotation;

  @override
  void paint(Canvas canvas, Size size) {
    final axisY = HalfLifeNumberLineMetrics.axisY;
    final w = size.width;
    final axisPaint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final x0 = HalfLifeChartTransform.modelToViewX(
        HalfLifeNumberLine.startExponent.toDouble(), w);
    final x1 = HalfLifeChartTransform.modelToViewX(
        HalfLifeNumberLine.endExponent.toDouble(), w);
    canvas.drawLine(Offset(x0, axisY), Offset(x1, axisY), axisPaint);

    final tickPaint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = HalfLifeNumberLineMetrics.tickStrokeWidth;
    const half = HalfLifeNumberLineMetrics.tickExtent / 2;
    for (final e in HalfLifeNumberLine.tickExponents()) {
      final x = HalfLifeChartTransform.modelToViewX(e.toDouble(), w);
      canvas.drawLine(Offset(x, axisY - half), Offset(x, axisY + half), tickPaint);
    }

    if (!reading.pointerVisible) return;
    final exp = displayExponent ?? reading.pointerExponent;
    final rot = displayRotation ??
        (reading.pointerPointsRight
            ? HalfLifePointerAnimator.rotationRight
            : HalfLifePointerAnimator.rotationDown);
    final px = HalfLifeChartTransform.modelToViewX(exp, w);
    const L = HalfLifeNumberLineMetrics.arrowLength;
    // 尾在 (px, axisY-L)；局部箭头 (0,0)→(0,L)，再按 scenery y-down 旋转 [已确认]
    final tail = Offset(px, axisY - L);
    final tip = Offset(tail.dx + L * -math.sin(rot), tail.dy + L * math.cos(rot));
    _paintArrow(canvas, tail, tip);
  }

  void _paintArrow(Canvas canvas, Offset tail, Offset tip) {
    final delta = tip - tail;
    final length = delta.distance;
    if (length < 1) return;
    final dir = delta / length;
    final perp = Offset(-dir.dy, dir.dx);
    const headH = HalfLifeNumberLineMetrics.arrowHeadHeight;
    const headW = HalfLifeNumberLineMetrics.arrowHeadWidth;
    final bodyEnd = tip - dir * headH;

    final paint = Paint()
      ..color = HalfLifeNumberLineMetrics.pointerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = HalfLifeNumberLineMetrics.arrowTailWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tail, bodyEnd, paint);

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        (tip - dir * headH + perp * (headW / 2)).dx,
        (tip - dir * headH + perp * (headW / 2)).dy,
      )
      ..lineTo(
        (tip - dir * headH - perp * (headW / 2)).dx,
        (tip - dir * headH - perp * (headW / 2)).dy,
      )
      ..close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant HalfLifeNumberLinePainter oldDelegate) =>
      oldDelegate.reading != reading ||
      oldDelegate.displayExponent != displayExponent ||
      oldDelegate.displayRotation != displayRotation;
}
