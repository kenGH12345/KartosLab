/// Force (blue) and velocity (green) arrows from body.force / body.velocity.
///
/// Does not recompute physics — scales with [forceScale] / [velocityVectorScale].
library;

import 'package:flutter/material.dart';

import '../../../common/controls/arrow_painter.dart';
import '../gao_colors.dart';
import '../model/gao_body.dart';
import '../model/gao_vec.dart';
import '../render/gao_mvt.dart';

class GaoVectorsPainter extends CustomPainter {
  GaoVectorsPainter({
    required this.bodies,
    required this.mvt,
    required this.forceScale,
    required this.velocityVectorScale,
    required this.showForce,
    required this.showVelocity,
  });

  final List<GaoBody> bodies;
  final GaoMvt mvt;
  final double forceScale;
  final double velocityVectorScale;
  final bool showForce;
  final bool showVelocity;

  static const double _headH = 12;
  static const double _headW = 12;
  static const double _tailW = 4;
  static const double _grabR = 10;

  @override
  void paint(Canvas canvas, Size size) {
    for (final body in bodies) {
      if (body.isCollided) continue;
      final tail = mvt.modelToView(body.position);

      if (showForce) {
        final tipModel = GaoVec(
          body.position.x + body.force.x * forceScale,
          body.position.y + body.force.y * forceScale,
        );
        final tip = mvt.modelToView(tipModel);
        if ((tip - tail).distance >= 2) {
          ArrowPainter(
            tail: tail,
            tip: tip,
            color: GaoColors.gravitationalForce,
            headHeight: _headH,
            headWidth: _headW,
            tailWidth: _tailW,
          ).paint(canvas, size);
        }
      }

      if (showVelocity) {
        final tipModel = GaoVec(
          body.position.x + body.velocity.x * velocityVectorScale,
          body.position.y + body.velocity.y * velocityVectorScale,
        );
        final tip = mvt.modelToView(tipModel);
        if ((tip - tail).distance >= 2) {
          ArrowPainter(
            tail: tail,
            tip: tip,
            color: GaoColors.velocity,
            headHeight: _headH,
            headWidth: _headW,
            tailWidth: _tailW,
          ).paint(canvas, size);
          canvas.drawCircle(
            tip,
            _grabR,
            Paint()
              ..color = GaoColors.velocity
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
          final tp = TextPainter(
            text: const TextSpan(
              text: 'v',
              style: TextStyle(
                color: GaoColors.velocity,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, tip - Offset(tp.width / 2, tp.height / 2));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant GaoVectorsPainter old) =>
      old.bodies != bodies ||
      old.mvt != mvt ||
      old.forceScale != forceScale ||
      old.velocityVectorScale != velocityVectorScale ||
      old.showForce != showForce ||
      old.showVelocity != showVelocity;
}
