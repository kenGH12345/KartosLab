import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../controller/keplers_laws_controller.dart';
import '../keplers_laws_colors.dart';
import '../model/target_orbit.dart';

/// T vs a graph.
///
/// [已确认] ThirdLawGraph.ts axisLength=160, maxSemiMajorAxis=2
class ThirdLawGraph extends StatelessWidget {
  const ThirdLawGraph({super.key, required this.controller});

  final KeplersLawsController controller;

  static const double axisLength = 160;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: axisLength + 40,
      height: axisLength + 40,
      child: CustomPaint(
        painter: _ThirdLawGraphPainter(controller: controller),
      ),
    );
  }
}

class _ThirdLawGraphPainter extends CustomPainter {
  _ThirdLawGraphPainter({required this.controller});

  final KeplersLawsController controller;

  @override
  void paint(Canvas canvas, Size size) {
    const axisLength = ThirdLawGraph.axisLength;
    canvas.save();
    canvas.translate(28, axisLength + 8);

    final axisPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;
    canvas.drawLine(Offset.zero, const Offset(axisLength, 0), axisPaint);
    canvas.drawLine(Offset.zero, const Offset(0, -axisLength), axisPaint);
    _arrowHead(canvas, const Offset(axisLength, 0), 0);
    _arrowHead(canvas, const Offset(0, -axisLength), -math.pi / 2);

    _label(canvas, 'a${_sup(controller.selectedAxisPower)}',
        const Offset(axisLength / 2, 12));
    _label(canvas, 'T${_sup(controller.selectedPeriodPower)}',
        const Offset(-18, -axisLength / 2));

    final maxA = 2.0;
    final maxT = controller.engine.thirdLaw(maxA);

    Offset viewOf(double a) {
      final period = controller.engine.thirdLaw(a);
      final x = axisLength *
          math.pow((a / maxA).clamp(0.0, 1.0), controller.selectedAxisPower);
      final y = -axisLength *
          math.pow((period / maxT).clamp(0.0, 1.0), controller.selectedPeriodPower);
      return Offset(x.toDouble(), y.toDouble());
    }

    final line = Path();
    var started = false;
    if (controller.minVisitedAxis != controller.maxVisitedAxis) {
      for (var a = controller.minVisitedAxis;
          a <= controller.maxVisitedAxis;
          a += 0.01) {
        final p = viewOf(a);
        if (p.dx < axisLength - 20 && p.dy > -axisLength + 20) {
          if (!started) {
            line.moveTo(p.dx, p.dy);
            started = true;
          } else {
            line.lineTo(p.dx, p.dy);
          }
        }
      }
      canvas.drawPath(
        line,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final target = controller.targetOrbit;
    if (target != TargetOrbit.none && controller.isSolarSystem) {
      final tp = viewOf(target.semiMajorAxis);
      if (tp.dx < axisLength) {
        canvas.drawCircle(tp, 5, Paint()..color = KeplersLawsColors.targetOrbit);
      }
    }

    if (controller.engine.allowedOrbit) {
      final p = viewOf(controller.engine.a);
      const boundsPadding = 20.0;
      final out = p.dx > axisLength - boundsPadding ||
          p.dy < -axisLength + boundsPadding;
      if (!out) {
        canvas.drawCircle(p, 5, Paint()..color = KeplersLawsColors.planet);
      } else {
        // [已确认] ThirdLawGraph.ts outOfBoundsArrow magnitude 20
        final tail = viewOf(maxA / 2);
        final tip = tail + const Offset(14, -14);
        canvas.drawLine(
          tail,
          tip,
          Paint()
            ..color = KeplersLawsColors.planet
            ..strokeWidth = 2,
        );
        _arrowHead(canvas, tip, math.atan2(tip.dy - tail.dy, tip.dx - tail.dx));
      }
    }

    canvas.restore();
  }

  String _sup(int p) => p == 1 ? '' : p.toString();

  void _arrowHead(Canvas canvas, Offset tip, double ang) {
    final p = Paint()..color = Colors.white;
    canvas.drawLine(
      tip,
      tip + Offset(math.cos(ang + 2.6) * 8, math.sin(ang + 2.6) * 8),
      p,
    );
    canvas.drawLine(
      tip,
      tip + Offset(math.cos(ang - 2.6) * 8, math.sin(ang - 2.6) * 8),
      p,
    );
  }

  void _label(Canvas canvas, String text, Offset at) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ThirdLawGraphPainter old) => true;
}
