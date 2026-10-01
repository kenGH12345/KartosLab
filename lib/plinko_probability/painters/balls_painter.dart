import 'package:flutter/material.dart';

import '../../gas_properties/painters/shaded_sphere.dart';
import '../model/ball.dart';
import '../model/ball_phase.dart';
import '../plinko_colors.dart';
import '../transform/plinko_mvt.dart';

/// Falling / collected balls — shaded spheres.
class BallsPainter extends CustomPainter {
  BallsPainter({
    required this.balls,
    required this.mvt,
    this.showCollected = true,
  });

  final List<Ball> balls;
  final PlinkoMvt mvt;
  final bool showCollected;

  @override
  void paint(Canvas canvas, Size size) {
    for (final ball in balls) {
      if (!showCollected && ball.phase == BallPhase.collected) continue;
      final c = mvt.modelToView(ball.position);
      final r = mvt.modelToViewRadius(ball.ballRadius);
      paintShadedSphere(
        canvas,
        c,
        r,
        mainColor: PlinkoColors.ball,
        highlightColor: PlinkoColors.ballHighlight,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BallsPainter oldDelegate) => true;
}
