/// Gravity force arrows from [BodyRenderDot.gravityForce].
///
/// [MSS-SOURCE] VectorNode(body, …, body.gravityForceProperty, scalePower)
/// Scale: [KEPLER-SECONDARY] 10^(power-3) * VELOCITY_TO_VIEW via MVT.
library;

import 'package:flutter/material.dart';

import '../../../common/controls/arrow_painter.dart';
import '../my_solar_system_colors.dart';
import '../my_solar_system_constants.dart';
import '../model/mss_vec.dart';
import '../render/mss_render_data.dart';

class GravityVectorsPainter extends CustomPainter {
  GravityVectorsPainter(this.data);

  final MssRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    if (!data.gravityVisible) return;
    final scale = data.gravityArrowScale;
    if (scale == 0) return;
    for (final body in data.bodies) {
      final tipModel = MssVec(
        body.gravityForce.x * scale,
        body.gravityForce.y * scale,
      );
      if (tipModel.magnitude == 0) continue;
      final capped = tipModel.magnitude > 1e4
          ? MssVec(
              tipModel.x / tipModel.magnitude * 1e4,
              tipModel.y / tipModel.magnitude * 1e4,
            )
          : tipModel;
      final tail = data.mvt.toView(body.position);
      final tip =
          data.mvt.toView(MssVec(body.position.x + capped.x, body.position.y + capped.y));
      if ((tip - tail).distance < 2) continue;
      ArrowPainter(
        tail: tail,
        tip: tip,
        color: MySolarSystemColors.gravity,
        headHeight: MySolarSystemConstants.vectorHeadHeight,
        headWidth: MySolarSystemConstants.vectorHeadWidth,
        tailWidth: MySolarSystemConstants.vectorTailWidth,
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(GravityVectorsPainter oldDelegate) =>
      oldDelegate.data != data;
}
