import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../caf_colors.dart';
import '../caf_constants.dart';
import '../model/charges_and_fields_model.dart';
import '../model/vec2.dart';
import '../transform/caf_mvt.dart';

/// Electric field arrow grid — port of ElectricFieldCanvasNode.
class ElectricFieldGridPainter extends CustomPainter {
  ElectricFieldGridPainter({
    required this.model,
    required this.mvt,
  });

  final ChargesAndFieldsModel model;
  final CafMvt mvt;

  @override
  void paint(Canvas canvas, Size size) {
    if (!model.isElectricFieldVisible) return;
    if (model.activeChargedParticles.isEmpty) return;

    final bounds = model.enlargedBounds;
    final spacing = CafConstants.electricFieldSensorSpacing;
    final numHorizontal = (bounds.width / spacing).ceil();
    final numVertical = (bounds.height / spacing).ceil();

    for (var col = 0; col < numHorizontal; col++) {
      for (var row = 0; row < numVertical; row++) {
        final x = bounds.minX + (col + 0.5) * bounds.width / numHorizontal;
        final y = bounds.minY + (row + 0.5) * bounds.height / numVertical;
        final pos = CafVec2(x, y);
        final e = model.getElectricField(pos);
        final mag = e.magnitude;
        if (mag < 1e-12) continue;

        double alpha;
        if (model.isElectricFieldDirectionOnly) {
          alpha = mag > 1e-9 ? 1.0 : 0.0;
        } else {
          alpha = (mag / CafConstants.eFieldColorSatMagnitude).clamp(0.0, 1.0);
        }
        if (alpha <= 0) continue;

        final viewPos = mvt.modelToView(pos);
        _drawFieldArrow(canvas, viewPos, e.angle, alpha);
      }
    }
  }

  void _drawFieldArrow(Canvas canvas, Offset center, double modelAngle, double alpha) {
    // Model Y+ is up; view Y is down → rotate by -angle in view.
    final viewAngle = -modelAngle;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(viewAngle);
    canvas.scale(1 / CafConstants.fieldArrowCanvasScale);

    final ratio = CafConstants.fieldArrowRatio;
    final len = CafConstants.fieldArrowLength;
    final tail = Offset(-ratio * len, 0);
    final tip = Offset((1 - ratio) * len, 0);

    final fill = Paint()
      ..color = CafColors.electricFieldGridSaturation.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = CafColors.electricFieldGridSaturationStroke.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = _arrowPath(tail, tip);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Center hole
    final hole = Paint()
      ..color = CafColors.background
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.src;
    canvas.drawCircle(Offset.zero, CafConstants.fieldArrowHoleRadius, hole);

    canvas.restore();
  }

  Path _arrowPath(Offset tail, Offset tip) {
    final dx = tip.dx - tail.dx;
    final dy = tip.dy - tail.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    final dir = Offset(dx / length, dy / length);
    final perp = Offset(-dy / length, dx / length);
    final headH = CafConstants.fieldArrowHeadHeight;
    final headW = CafConstants.fieldArrowHeadWidth;
    final tailW = CafConstants.fieldArrowTailWidth;

    final bodyEnd = tip - dir * headH;
    final halfTail = perp * (tailW / 2);
    final halfHead = perp * (headW / 2);

    return Path()
      ..moveTo(tail.dx + halfTail.dx, tail.dy + halfTail.dy)
      ..lineTo(bodyEnd.dx + halfTail.dx, bodyEnd.dy + halfTail.dy)
      ..lineTo(bodyEnd.dx + halfHead.dx, bodyEnd.dy + halfHead.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(bodyEnd.dx - halfHead.dx, bodyEnd.dy - halfHead.dy)
      ..lineTo(bodyEnd.dx - halfTail.dx, bodyEnd.dy - halfTail.dy)
      ..lineTo(tail.dx - halfTail.dx, tail.dy - halfTail.dy)
      ..close();
  }

  @override
  bool shouldRepaint(covariant ElectricFieldGridPainter oldDelegate) => true;
}

/// Major/minor grid + optional 1 m scale arrow.
class CafGridPainter extends CustomPainter {
  CafGridPainter({
    required this.model,
    required this.mvt,
  });

  final ChargesAndFieldsModel model;
  final CafMvt mvt;

  @override
  void paint(Canvas canvas, Size size) {
    if (!model.isGridVisible) return;
    final bounds = model.enlargedBounds;
    final major = CafConstants.gridMajorSpacing;
    final minor = CafConstants.gridMinorSpacing;

    final minorPaint = Paint()
      ..color = CafColors.gridStroke
      ..strokeWidth = 1;
    final majorPaint = Paint()
      ..color = CafColors.gridStroke
      ..strokeWidth = 2;

    for (var x = _ceilTo(bounds.minX, minor); x <= bounds.maxX + 1e-9; x += minor) {
      final a = mvt.modelToView(CafVec2(x, bounds.minY));
      final b = mvt.modelToView(CafVec2(x, bounds.maxY));
      final isMajor = (x / major).abs() % 1.0 < 1e-6 || (x / major).abs() % 1.0 > 1 - 1e-6;
      canvas.drawLine(a, b, isMajor ? majorPaint : minorPaint);
    }
    for (var y = _ceilTo(bounds.minY, minor); y <= bounds.maxY + 1e-9; y += minor) {
      final a = mvt.modelToView(CafVec2(bounds.minX, y));
      final b = mvt.modelToView(CafVec2(bounds.maxX, y));
      final isMajor = (y / major).abs() % 1.0 < 1e-6 || (y / major).abs() % 1.0 > 1 - 1e-6;
      canvas.drawLine(a, b, isMajor ? majorPaint : minorPaint);
    }

    if (model.areValuesVisible) {
      // Scale arrow at (2, -2.20) length 1 m
      final start = mvt.modelToView(const CafVec2(2, -2.20));
      final end = mvt.modelToView(const CafVec2(3, -2.20));
      final paint = Paint()
        ..color = CafColors.gridLengthScaleArrowFill
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(start, end, paint);
      _drawArrowHead(canvas, end, start);
      _drawArrowHead(canvas, start, end);
      final tp = TextPainter(
        text: const TextSpan(
          text: '1 meter',
          style: TextStyle(color: CafColors.gridTextFill, fontSize: 12),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((start.dx + end.dx) / 2 - tp.width / 2, start.dy + 4));
    }
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Offset from) {
    final dir = tip - from;
    final len = dir.distance;
    if (len < 1) return;
    final n = dir / len;
    final perp = Offset(-n.dy, n.dx);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - n.dx * 8 + perp.dx * 4, tip.dy - n.dy * 8 + perp.dy * 4)
      ..lineTo(tip.dx - n.dx * 8 - perp.dx * 4, tip.dy - n.dy * 8 - perp.dy * 4)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = CafColors.gridLengthScaleArrowFill,
    );
  }

  double _ceilTo(double v, double step) => (v / step).ceil() * step;

  @override
  bool shouldRepaint(covariant CafGridPainter oldDelegate) => true;
}

class ChargePainter extends CustomPainter {
  ChargePainter({required this.positive});

  final bool positive;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final gradient = RadialGradient(
      colors: positive
          ? const [
              CafColors.positiveChargeInner,
              CafColors.positiveChargeMid,
              CafColors.positiveChargeOuter,
            ]
          : const [
              CafColors.negativeChargeInner,
              CafColors.negativeChargeMid,
              CafColors.negativeChargeOuter,
            ],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(
      center,
      r,
      Paint()..shader = gradient.createShader(Rect.fromCircle(center: center, radius: r)),
    );

    final stroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.3 * r
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final arm = 0.6 * r;
    canvas.drawLine(center - Offset(arm, 0), center + Offset(arm, 0), stroke);
    if (positive) {
      canvas.drawLine(center - Offset(0, arm), center + Offset(0, arm), stroke);
    }
  }

  @override
  bool shouldRepaint(covariant ChargePainter oldDelegate) =>
      oldDelegate.positive != positive;
}
