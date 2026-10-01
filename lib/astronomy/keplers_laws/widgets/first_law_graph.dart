import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../controller/keplers_laws_controller.dart';
import '../keplers_laws_colors.dart';
import '../model/target_orbit.dart';

/// Eccentricity comparison graph.
///
/// [已确认] FirstLawGraph.ts Y_AXIS_LENGTH=180, range 0–1
/// shown: Mercury, Earth, Eris, Nereid, Halley
class FirstLawGraph extends StatelessWidget {
  const FirstLawGraph({super.key, required this.controller});

  final KeplersLawsController controller;

  static const double axisLength = 180;

  static const _examples = [
    TargetOrbit.mercury,
    TargetOrbit.earth,
    TargetOrbit.eris,
    TargetOrbit.nereid,
    TargetOrbit.halley,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: axisLength + 16,
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

  @override
  void paint(Canvas canvas, Size size) {
    const axis = FirstLawGraph.axisLength;
    canvas.save();
    canvas.translate(140, 8);

    final axisPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;
    canvas.drawLine(Offset.zero, const Offset(0, axis), axisPaint);
    for (var i = 0; i <= 10; i++) {
      final y = axis * i / 10;
      canvas.drawLine(Offset(-4, y), Offset(4, y), axisPaint);
    }

    for (final orbit in FirstLawGraph._examples) {
      final y = axis * orbit.eccentricity;
      _label(canvas, orbit.name, Offset(-28, y), alignRight: true);
      canvas.drawLine(
        Offset(-20, y),
        Offset(0, y),
        Paint()..color = Colors.white,
      );
    }

    final cy = axis * eccentricity;
    canvas.drawLine(
      Offset(0, cy),
      Offset(20, cy),
      Paint()..color = KeplersLawsColors.orbit,
    );
    _label(
      canvas,
      eccentricity.toStringAsFixed(2),
      Offset(24, cy),
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
        style: TextStyle(color: color, fontSize: 12),
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
