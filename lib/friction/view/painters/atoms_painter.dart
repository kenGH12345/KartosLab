import 'package:flutter/material.dart';

import '../../friction_constants.dart';
import '../../model/atom.dart';
import 'package:kratos/gases_intro/painters/shaded_sphere.dart';

/// Port of PhET `AtomCanvasNode` — shaded spheres with black stroke.
class AtomsPainter extends CustomPainter {
  AtomsPainter({required this.atoms});

  final List<FrictionAtom> atoms;

  static Color _brighter(Color c, double factor) {
    final r = (c.r * 255.0).round();
    final g = (c.g * 255.0).round();
    final b = (c.b * 255.0).round();
    final a = (c.a * 255.0).round();
    return Color.fromARGB(
      a,
      (r + ((255 - r) * factor)).round().clamp(0, 255),
      (g + ((255 - g) * factor)).round().clamp(0, 255),
      (b + ((255 - b) * factor)).round().clamp(0, 255),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final topMain = FrictionConstants.topBookAtomsColor;
    final topHi = _brighter(topMain, FrictionConstants.atomHighlightFactor);
    final botMain = FrictionConstants.bottomBookAtomsColor;
    final botHi = _brighter(botMain, FrictionConstants.atomHighlightFactor);
    final radius = FrictionConstants.atomRadius * 1.2;

    for (final atom in atoms) {
      if (atom.isShearedOff &&
          atom.centerPosition.dx.abs() > 4 * FrictionConstants.layoutWidth) {
        continue;
      }
      paintShadedSphere(
        canvas,
        atom.position,
        radius,
        mainColor: atom.isTopAtom ? topMain : botMain,
        highlightColor: atom.isTopAtom ? topHi : botHi,
      );
      canvas.drawCircle(
        atom.position,
        radius,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = FrictionConstants.atomStrokeWidth,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AtomsPainter oldDelegate) => true;
}
