/// Read-only paint DTO. Painters must not run PEFRL.
library;

import 'dart:ui';

import '../model/mss_vec.dart';
import 'mss_mvt.dart';

class BodyRenderDot {
  const BodyRenderDot({
    required this.position,
    required this.velocity,
    required this.gravityForce,
    required this.radiusAu,
    required this.color,
    required this.path,
    this.velocityOffscale = false,
  });

  final MssVec position;
  final MssVec velocity;
  final MssVec gravityForce;
  final double radiusAu;
  final Color color;
  final List<MssVec> path;

  /// [KEPLER-SECONDARY] |v| < velocityMinMagnitude
  final bool velocityOffscale;
}

class MssRenderData {
  const MssRenderData({
    required this.mvt,
    required this.bodies,
    this.velocityVisible = true,
    this.gravityVisible = false,
    this.gridVisible = false,
    this.pathVisible = true,
    this.centerOfMassVisible = false,
    this.comPosition,
    this.gravityArrowScale = 0,
    this.velocityArrowScale = 0,
  });

  final MssMvt mvt;
  final List<BodyRenderDot> bodies;
  final bool velocityVisible;
  final bool gravityVisible;
  final bool gridVisible;
  final bool pathVisible;
  final bool centerOfMassVisible;
  final MssVec? comPosition;
  final double gravityArrowScale;
  final double velocityArrowScale;
}
