import 'package:flutter/material.dart';

import '../model/ball.dart';
import '../plinko_colors.dart';
import '../transform/plinko_mvt.dart';

/// Trajectory polyline for Lab path mode — `TrajectoryPath.js`.
///
/// Uses the **same** precomputed `pegHistory` as the ball (Bernoulli path),
/// not a separate physics trajectory.
class TrajectoryPathPainter extends CustomPainter {
  TrajectoryPathPainter({
    required this.balls,
    required this.mvt,
  });

  final List<Ball> balls;
  final PlinkoMvt mvt;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PlinkoColors.ball
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final ball in balls) {
      // After animation/land, pegHistory may be emptied — rebuild from hops
      // that were consumed. For path mode, balls land immediately while
      // pegHistory is still intact at TrajectoryPath construction time in
      // PhET. We snapshot hops at spawn; if empty, skip.
      final hops = ball.pathHops;
      if (hops.isEmpty) continue;

      final verticalOffset = ball.pegSeparation / 2;
      final path = Path();
      final first = hops.first;
      final start = mvt.modelToView(
        Offset(first.positionX, first.positionY + ball.pegSeparation),
      );
      path.moveTo(start.dx, start.dy);
      for (final peg in hops) {
        final p = mvt.modelToView(
          Offset(peg.positionX, peg.positionY + verticalOffset),
        );
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant TrajectoryPathPainter oldDelegate) => true;
}
