/// Body name labels with yellow leader lines when body is too small to see.
///
/// Port of `BodyNode.createArrowIndicator`: visible iff viewDiameter ≤ 12.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../gao_assets.dart';
import '../gao_colors.dart';
import '../model/gao_body.dart';
import '../render/gao_mvt.dart';

/// `GravityAndOrbitsColors.bodyLabelIndicatorProperty` default yellow.
const Color kGaoBodyLabelIndicator = Color.fromARGB(255, 255, 255, 0);

class GaoBodyLabelsPainter extends CustomPainter {
  GaoBodyLabelsPainter({
    required this.bodies,
    required this.mvt,
  });

  final List<GaoBody> bodies;
  final GaoMvt mvt;

  /// Source: `BodyNode` — show label when view diameter ≤ 12.
  static const double visibilityThreshold = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = kGaoBodyLabelIndicator
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (final body in bodies) {
      if (body.isCollided) continue;
      final diameterPx = mvt.modelDeltaToViewDelta(body.diameter).abs();
      if (diameterPx > visibilityThreshold) continue;

      final center = mvt.modelToView(body.position);
      final angle = body.labelAngle;
      // Scenery local: createPolar → (r·cos θ, r·sin θ); +y down on screen.
      // labelAngle −π/4 → "northeast" (right + up on screen = sin negative? 
      // Actually sin(−π/4)<0 so y decreases = up). Matches BodyNode northEastVector.
      final tip = Offset(
        center.dx + 10 * math.cos(angle),
        center.dy + 10 * math.sin(angle),
      );
      final tail = Offset(
        center.dx + 70 * math.cos(angle),
        center.dy + 70 * math.sin(angle),
      );

      canvas.drawLine(tail, tip, linePaint);

      final tp = TextPainter(
        text: TextSpan(
          text: GaoAssets.labelFor(body.type),
          style: const TextStyle(
            color: GaoColors.foreground,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 65);

      // label.centerX = tail.x; label.y = tail.y - rendererHeight - 10
      tp.paint(
        canvas,
        Offset(tail.dx - tp.width / 2, tail.dy - tp.height - 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GaoBodyLabelsPainter old) =>
      old.bodies != bodies || old.mvt != mvt;
}
