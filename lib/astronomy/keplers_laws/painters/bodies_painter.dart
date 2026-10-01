import 'package:flutter/material.dart';

import '../keplers_laws_colors.dart';
import '../render/orbit_render_data.dart';

/// Sun + planet as shaded spheres.
///
/// [已确认] BodyNode uses ShadedSphereNode, radius = modelToViewDeltaX(massToRadius)
class BodiesPainter extends CustomPainter {
  BodiesPainter({required this.data});

  final OrbitRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    _sphere(
      canvas,
      data.mvt.toView(data.sunPos),
      data.mvt.toViewDelta(data.sunRadius),
      KeplersLawsColors.sun,
    );
    _sphere(
      canvas,
      data.mvt.toView(data.planetPos),
      data.mvt.toViewDelta(data.planetRadius),
      KeplersLawsColors.planet,
    );
  }

  void _sphere(Canvas canvas, Offset c, double r, Color color) {
    final rect = Rect.fromCircle(center: c, radius: r);
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Color.lerp(color, Colors.white, 0.45)!,
          color,
          Color.lerp(color, Colors.black, 0.35)!,
        ],
      ).createShader(rect);
    canvas.drawCircle(c, r, paint);
  }

  @override
  bool shouldRepaint(covariant BodiesPainter old) => old.data != data;
}
