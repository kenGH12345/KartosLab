import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../keplers_laws_colors.dart';
import '../keplers_laws_constants.dart';
import '../render/orbit_render_data.dart';

/// Gray target-orbit ellipse.
///
/// [已确认] TargetOrbitNode.ts: translate to sun, ellipse(-a*e, 0, a, b)
class TargetOrbitPainter extends CustomPainter {
  TargetOrbitPainter({required this.data});

  final OrbitRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    if (!data.showTargetOrbit) return;
    final orbit = data.targetOrbit;
    if (orbit.semiMajorAxis <= 0) return;
    final scale = data.mvt.scale;
    final a = scale * orbit.semiMajorAxis;
    final e = orbit.eccentricity;
    final b = a * math.sqrt(math.max(0, 1 - e * e));
    final sun = data.mvt.toView(data.sunPos);
    canvas.save();
    canvas.translate(sun.dx, sun.dy);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-a * e, 0),
        width: a * 2,
        height: b * 2,
      ),
      Paint()
        ..color = KeplersLawsColors.targetOrbit
        ..style = PaintingStyle.stroke
        ..strokeWidth = KeplersLawsConstants.orbitLineWidth,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TargetOrbitPainter old) => old.data != data;
}
