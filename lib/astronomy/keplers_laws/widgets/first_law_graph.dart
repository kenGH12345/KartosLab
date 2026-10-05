import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../controller/keplers_laws_controller.dart';
import '../keplers_laws_colors.dart';
import '../model/target_orbit.dart';

/// Eccentricity comparison graph — `FirstLawGraph.ts`.
///
/// Y axis 0 at top … 1 at bottom. Examples: Earth, Mercury, Eris, Nereid, Halley.
class FirstLawGraph extends StatelessWidget {
  const FirstLawGraph({super.key, required this.controller});

  final KeplersLawsController controller;

  static const double axisLength = 180;

  static const _examples = [
    TargetOrbit.earth,
    TargetOrbit.mercury,
    TargetOrbit.eris,
    TargetOrbit.nereid,
    TargetOrbit.halley,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 228,
      height: axisLength + 8,
      child: CustomPaint(
        painter: _FirstLawGraphPainter(
          eccentricity: controller.engine.eccentricityDisplay.clamp(0.0, 1.0),
        ),
      ),
    );
  }
}

class _FirstLawGraphPainter extends CustomPainter {
  _FirstLawGraphPainter({required this.eccentricity});

  final double eccentricity;

  static const double _axisX = 118;

  @override
  void paint(Canvas canvas, Size size) {
    const axis = FirstLawGraph.axisLength;
    canvas.save();
    canvas.translate(0, 4);

    final axisPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(_axisX, 0), const Offset(_axisX, axis), axisPaint);
    for (var i = 0; i <= 10; i++) {
      final y = axis * i / 10;
      canvas.drawLine(Offset(_axisX - 4, y), Offset(_axisX + 4, y), axisPaint);
    }

    for (final orbit in FirstLawGraph._examples) {
      final y = axis * orbit.eccentricity;
      _label(canvas, orbit.name, Offset(_axisX - 14, y), alignRight: true);
      canvas.drawLine(
        Offset(_axisX - 12, y),
        Offset(_axisX, y),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5,
      );
    }

    final cy = axis * eccentricity;
    final arrow = Path()
      ..moveTo(_axisX + 4, cy)
      ..lineTo(_axisX + 16, cy - 7)
      ..lineTo(_axisX + 16, cy + 7)
      ..close();
    canvas.drawPath(arrow, Paint()..color = KeplersLawsColors.orbit);
    _label(
      canvas,
      eccentricity.toStringAsFixed(2),
      Offset(_axisX + 20, cy),
      color: KeplersLawsColors.orbit,
    );
    canvas.restore();
  }

  void _label(
    Canvas canvas,
    String text,
    Offset at, {
    bool alignRight = false,
    Color color = Colors.white,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 13, height: 1),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final origin = alignRight
        ? Offset(at.dx - tp.width, at.dy - tp.height / 2)
        : Offset(at.dx, at.dy - tp.height / 2);
    tp.paint(canvas, origin);
  }

  @override
  bool shouldRepaint(covariant _FirstLawGraphPainter old) =>
      old.eccentricity != eccentricity;
}
