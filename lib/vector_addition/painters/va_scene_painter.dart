import 'package:flutter/material.dart';

import '../model/enums.dart';
import '../render/va_render_data.dart';
import '../vector_addition_colors.dart';
import '../vector_addition_constants.dart';
import 'va_angle_arc_geometry.dart';
import 'va_arrow_geometry.dart';

/// Paints graph + vectors from [VaRenderData] only (no business math).
class VaScenePainter extends CustomPainter {
  VaScenePainter({required this.data});

  final VaRenderData data;
  final _arrow = const VaArrowGeometry();
  final _angleArc = const VaAngleArcGeometry();

  @override
  void paint(Canvas canvas, Size size) {
    final graphPaint = Paint()..color = VectorAdditionColors.graphBackground;
    canvas.drawRect(data.graphRect, graphPaint);

    if (data.gridVisible) {
      final minor = Paint()
        ..color = VectorAdditionColors.graphMinorLine
        ..strokeWidth = 1;
      final major = Paint()
        ..color = VectorAdditionColors.graphMajorLine
        ..strokeWidth = 1.5;
      for (final l in data.minorGridLines) {
        canvas.drawLine(l.a, l.b, minor);
      }
      for (final l in data.majorGridLines) {
        canvas.drawLine(l.a, l.b, major);
      }
    }

    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5;
    for (final l in data.axisSegments) {
      canvas.drawLine(l.a, l.b, axisPaint);
    }

    canvas.drawCircle(
      data.originView,
      7,
      Paint()..color = VectorAdditionColors.origin,
    );
    canvas.drawCircle(
      data.originView,
      7,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    for (final t in data.tickLabels) {
      final tp = TextPainter(
        text: TextSpan(
          text: t.text,
          style: const TextStyle(
            color: VectorAdditionColors.graphTickLabel,
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, t.position - Offset(tp.width / 2, tp.height / 2));
    }

    // Base vectors under components / main vectors (PhET layering).
    for (final v in data.baseVectors) {
      canvas.save();
      canvas.clipRect(data.graphRect);
      _paintArrow(canvas, v);
      canvas.restore();
    }

    for (final c in data.components) {
      if (!c.onGraph) {
        _paintArrow(canvas, c);
        continue;
      }
      canvas.save();
      canvas.clipRect(data.graphRect);
      _paintArrow(canvas, c);
      canvas.restore();
    }

    for (final v in [...data.resultants, ...data.vectors]) {
      if (v.onGraph) {
        canvas.save();
        canvas.clipRect(data.graphRect);
        _paintArrow(canvas, v);
        canvas.restore();
      } else {
        _paintArrow(canvas, v);
      }
    }
  }

  void _paintArrow(Canvas canvas, VaArrowRender v) {
    if (v.showShadow) {
      _arrow.paint(
        canvas,
        tail: v.tail + const Offset(3.2, 2.1),
        tip: v.tip + const Offset(3.2, 2.1),
        color: Colors.black.withValues(alpha: 0.28),
      );
    }
    _arrow.paint(
      canvas,
      tail: v.tail,
      tip: v.tip,
      color: v.color,
      dashed: v.dashed,
      strokeColor: v.strokeColor,
      strokeWidth: v.strokeWidth,
    );
    if (v.showAngle &&
        v.angleDegrees != null &&
        v.modelAngleRadians != null &&
        (v.viewMagnitude ?? 0) > 0) {
      _angleArc.paint(
        canvas,
        tailView: v.tail,
        modelAngleRadians: v.modelAngleRadians!,
        angleDegrees: v.angleDegrees!,
        viewMagnitude: v.viewMagnitude!,
        signedConvention: data.angleConvention == AngleConvention.signed,
        decimalPlaces: VectorAdditionConstants.vectorValueDecimalPlaces,
      );
    }
    if (v.showLabel) {
      _label(canvas, v, highlight: v.selected);
    }
  }

  void _label(Canvas canvas, VaArrowRender v, {bool highlight = false}) {
    final mid = Offset(
      (v.tail.dx + v.tip.dx) / 2,
      (v.tail.dy + v.tip.dy) / 2,
    );
    final color = v.isBaseVector ? (v.strokeColor ?? v.color) : v.color;
    final tp = TextPainter(
      text: TextSpan(
        text: v.labelText,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final origin = mid - Offset(tp.width / 2, tp.height + 6);
    final bg = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        origin.dx - 3,
        origin.dy - 1,
        tp.width + 6,
        tp.height + 2,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      bg,
      Paint()
        ..color = highlight
            ? const Color(0xFFFFF59D)
            : Colors.white.withValues(alpha: 0.85),
    );
    tp.paint(canvas, origin);
  }

  @override
  bool shouldRepaint(covariant VaScenePainter oldDelegate) =>
      oldDelegate.data != data;
}
