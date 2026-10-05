/// nitroglycerin / BAM AtomNode — shaded sphere + element symbol.
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../bam_constants.dart';
import '../data/bam_element.dart';

class BamAtomSpherePainter {
  const BamAtomSpherePainter._();

  static void paint(
    Canvas canvas,
    Offset center,
    double r,
    Color color, {
    String? symbol,
  }) {
    if (r <= 0) return;
    // scenery-phet ShadedSphereNode: highlight at (-0.4,-0.4)×r, gradient r×2.
    final highlight = Offset(center.dx - r * 0.4, center.dy - r * 0.4);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          highlight,
          r * 2,
          [Colors.white, color, const Color(0xFF000000)],
          const [0.0, 0.5, 1.0],
        ),
    );
    if (symbol == null || symbol.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          color: BamConstants.atomTextColor(color),
          fontSize: (r * 0.85).clamp(6.0, 36.0),
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  static double viewRadius(double covalentRadius, double modelToViewScale) {
    final fromMvt = covalentRadius * modelToViewScale;
    final fromDisplay = covalentRadius * 0.48;
    final r = fromMvt > fromDisplay ? fromMvt : fromDisplay;
    if (r < 18) return 18;
    if (r > 34) return 34;
    return r;
  }

  /// Compact kit-bowl atom size from covalent pm (not stretched to Row width).
  static double bucketAtomRadius(double covalentRadius, {int count = 1}) {
    var r = covalentRadius * 0.22;
    if (count >= 8) r *= 0.85;
    if (r < 9) return 9;
    if (r > 20) return 20;
    return r;
  }

  static double kitBowlWidth(double covalentRadius, int count) {
    final n = count < 1 ? 1 : count;
    final onBottom = n <= 2 ? n : (n / 2).floor() + 1;
    final r = bucketAtomRadius(covalentRadius, count: n);
    final w = onBottom * 2.15 * r + 36;
    if (w < 108) return 108;
    if (w > 176) return 176;
    return w;
  }
}

class BamAtomSphere extends StatelessWidget {
  const BamAtomSphere({
    super.key,
    required this.element,
    required this.radius,
  });

  final BamElement element;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final d = radius * 2;
    return CustomPaint(
      size: Size(d, d),
      painter: _SpherePainter(element: element, radius: radius),
    );
  }
}

class _SpherePainter extends CustomPainter {
  _SpherePainter({required this.element, required this.radius});

  final BamElement element;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    BamAtomSpherePainter.paint(
      canvas,
      Offset(size.width / 2, size.height / 2),
      radius,
      element.color,
      symbol: element.symbol,
    );
  }

  @override
  bool shouldRepaint(covariant _SpherePainter oldDelegate) =>
      oldDelegate.element != element || oldDelegate.radius != radius;
}
