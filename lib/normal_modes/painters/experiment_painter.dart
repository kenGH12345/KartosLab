import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/amplitude_direction.dart';
import '../normal_modes_colors.dart';
import '../normal_modes_constants.dart';
import '../render/nm_render_data.dart';

class ExperimentPainter extends CustomPainter {
  ExperimentPainter({
    required this.data,
    required this.circleMasses,
  });

  final NmRenderData data;
  final bool circleMasses;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.border != null) {
      final borderPaint = Paint()
        ..color = NormalModesColors.wallStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(data.border!, borderPaint);
    }

    final springPaint = Paint()
      ..color = NormalModesColors.springStroke
      ..strokeWidth = NormalModesConstants.springLineWidth
      ..strokeCap = StrokeCap.round;
    for (final s in data.springs) {
      if (!s.visible) continue;
      if ((s.p1 - s.p2).distance == 0) continue;
      canvas.drawLine(s.p1, s.p2, springPaint);
    }

    for (final w in data.walls) {
      final rect = Rect.fromCenter(
        center: w.center,
        width: NormalModesConstants.wallWidth,
        height: NormalModesConstants.wallHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()..color = NormalModesColors.wallFill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()
          ..color = NormalModesColors.wallStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    const sizeMass = NormalModesConstants.massNodeSize;
    for (final m in data.masses) {
      if (!m.visible) continue;
      final fill = Paint()..color = NormalModesColors.massFill;
      final stroke = Paint()
        ..color = NormalModesColors.massStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = NormalModesConstants.massStrokeWidth;
      if (circleMasses) {
        canvas.drawCircle(m.center, sizeMass / 2, fill);
        canvas.drawCircle(m.center, sizeMass / 2, stroke);
      } else {
        final rect = Rect.fromCenter(
          center: m.center,
          width: sizeMass,
          height: sizeMass,
        );
        canvas.drawRect(rect, fill);
        canvas.drawRect(rect, stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ExperimentPainter oldDelegate) => true;
}

class ArrowOverlayPainter extends CustomPainter {
  ArrowOverlayPainter({required this.mass, required this.hovered});

  final MassRender mass;
  final bool hovered;

  @override
  void paint(Canvas canvas, Size size) {
    if (!hovered || !mass.showArrows || !mass.visible) return;
    canvas.save();
    canvas.translate(mass.center.dx, mass.center.dy);
    if (mass.rotateArrows) {
      canvas.rotate(math.pi / 4);
    }
    const half = NormalModesConstants.massNodeSize / 2;
    const arrow = 23.0;
    if (mass.rotateArrows ||
        mass.arrowDirection == AmplitudeDirection.horizontal) {
      _arrow(canvas, Offset(-half, 0), Offset(-half - arrow, 0));
      _arrow(canvas, Offset(half, 0), Offset(half + arrow, 0));
    }
    if (mass.rotateArrows ||
        mass.arrowDirection == AmplitudeDirection.vertical) {
      _arrow(canvas, Offset(0, -half), Offset(0, -half - arrow));
      _arrow(canvas, Offset(0, half), Offset(0, half + arrow));
    }
    canvas.restore();
  }

  void _arrow(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = NormalModesColors.arrowFill
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    final path = Path();
    final d = to - from;
    final len = d.distance;
    if (len == 0) return;
    final dir = d / len;
    final n = Offset(-dir.dy, dir.dx);
    const headH = 16.0;
    const headW = 20.0;
    const tailW = 10.0;
    final neck = to - dir * headH;
    path.moveTo((from + n * (tailW / 2)).dx, (from + n * (tailW / 2)).dy);
    path.lineTo((neck + n * (tailW / 2)).dx, (neck + n * (tailW / 2)).dy);
    path.lineTo((neck + n * (headW / 2)).dx, (neck + n * (headW / 2)).dy);
    path.lineTo(to.dx, to.dy);
    path.lineTo((neck - n * (headW / 2)).dx, (neck - n * (headW / 2)).dy);
    path.lineTo((neck - n * (tailW / 2)).dx, (neck - n * (tailW / 2)).dy);
    path.lineTo((from - n * (tailW / 2)).dx, (from - n * (tailW / 2)).dy);
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..color = NormalModesColors.arrowStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant ArrowOverlayPainter oldDelegate) => true;
}
