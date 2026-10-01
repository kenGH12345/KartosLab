/// Body path trails — stroke 3, fade oldest [GaoConstants.pathFadeFraction].
library;

import 'package:flutter/material.dart';

import '../gao_constants.dart';
import '../model/gao_body.dart';
import '../render/gao_mvt.dart';

class GaoPathPainter extends CustomPainter {
  GaoPathPainter({
    required this.bodies,
    required this.mvt,
    required this.visible,
  });

  final List<GaoBody> bodies;
  final GaoMvt mvt;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    for (final body in bodies) {
      if (body.path.length < 2) continue;
      final n = body.path.length;
      final fadeCount = (n * GaoConstants.pathFadeFraction).ceil().clamp(1, n);
      for (var i = 1; i < n; i++) {
        final a = mvt.modelToView(body.path[i - 1]);
        final b = mvt.modelToView(body.path[i]);
        final t = i <= fadeCount ? i / fadeCount : 1.0;
        final paint = Paint()
          ..color = Colors.white.withValues(alpha: t.clamp(0.05, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = GaoConstants.pathStrokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawLine(a, b, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GaoPathPainter old) =>
      old.bodies != bodies || old.mvt != mvt || old.visible != visible;
}
