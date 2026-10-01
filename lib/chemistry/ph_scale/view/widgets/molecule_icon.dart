import 'package:flutter/material.dart';

import '../../model/ph_scale_colors.dart';

enum MoleculeKind { h3o, oh, h2o }

/// Ball-and-stick molecule icons — PhET H3ONode / OHNode / H2ONode (ShadedSphere).
class MoleculeIcon extends StatelessWidget {
  const MoleculeIcon({super.key, required this.kind, this.scale = 0.55});

  final MoleculeKind kind;
  final double scale;

  @override
  Widget build(BuildContext context) {
    const base = 42.0;
    return SizedBox(
      width: base * scale,
      height: base * scale,
      child: CustomPaint(painter: _MoleculePainter(kind: kind)),
    );
  }
}

class _MoleculePainter extends CustomPainter {
  _MoleculePainter({required this.kind});

  final MoleculeKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 42;
    void sphere(Offset c, double diameter, Color color) {
      final r = diameter * s / 2;
      final rect = Rect.fromCircle(center: c, radius: r);
      final paint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          radius: 0.9,
          colors: [
            Color.lerp(color, Colors.white, 0.55)!,
            color,
            Color.lerp(color, Colors.black, 0.25)!,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(rect);
      canvas.drawCircle(c, r, paint);
    }

    final ox = Offset(size.width * 0.45, size.height * 0.45);
    final oColor = PhScaleColors.oxygen;
    final hColor = PhScaleColors.hydrogen;

    switch (kind) {
      case MoleculeKind.h3o:
        sphere(
          Offset(ox.dx + 0.2 * 30 * s, ox.dy + 0.4 * 30 * s),
          15,
          hColor,
        );
        sphere(ox, 30, oColor);
        sphere(
          Offset(ox.dx - 0.5 * 30 * s, ox.dy - 0.1 * 30 * s),
          15,
          hColor,
        );
        sphere(
          Offset(ox.dx + 0.4 * 30 * s, ox.dy - 0.4 * 30 * s),
          15,
          hColor,
        );
      case MoleculeKind.oh:
        sphere(ox, 30, oColor);
        sphere(
          Offset(ox.dx + 0.55 * 30 * s, ox.dy - 0.1 * 30 * s),
          15,
          hColor,
        );
      case MoleculeKind.h2o:
        sphere(
          Offset(ox.dx + 0.1 * 30 * s, ox.dy + 0.55 * 30 * s),
          15,
          hColor,
        );
        sphere(ox, 30, oColor);
        sphere(
          Offset(ox.dx + 0.55 * 30 * s, ox.dy - 0.1 * 30 * s),
          15,
          hColor,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _MoleculePainter oldDelegate) =>
      oldDelegate.kind != kind;
}
