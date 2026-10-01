import 'package:flutter/material.dart';

import '../../../gas_properties/painters/shaded_sphere.dart';
import '../model/scaled_atom.dart';
import '../transform/som_coordinate_transform.dart';

/// Draws all [ScaledAtom]s as shaded spheres. Does **not** advance physics.
class ParticleCanvasPainter extends CustomPainter {
  ParticleCanvasPainter({
    required this.atoms,
    required this.mvt,
  });

  final List<ScaledAtom> atoms;
  final SomCoordinateTransform mvt;

  @override
  void paint(Canvas canvas, Size size) {
    for (final atom in atoms) {
      final center = mvt.modelToView(atom.getX(), atom.getY());
      final radius = mvt.modelToViewScale(atom.radius);
      if (radius <= 0) continue;
      paintShadedSphere(
        canvas,
        center,
        radius,
        mainColor: atom.color,
        highlightColor: Color.lerp(atom.color, Colors.white, 0.55)!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticleCanvasPainter oldDelegate) {
    return oldDelegate.atoms != atoms ||
        oldDelegate.mvt.layoutWidth != mvt.layoutWidth ||
        oldDelegate.mvt.layoutHeight != mvt.layoutHeight;
  }
}
