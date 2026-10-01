import 'dart:ui' show Offset;

import '../../clb_constants.dart';
import '../model/capacitor_physics.dart';
import 'yaw_pitch_mvt.dart';

/// Port of PhET `PlateSeparationDragHandler.js`.
///
/// Vertical only. Uses absolute pointer Y + [clickYOffset] (not delta accumulate).
class PlateSeparationDragHandler {
  PlateSeparationDragHandler({
    required this.mvt,
    this.minSeparation = ClbConstants.plateSeparationMin,
    this.maxSeparation = ClbConstants.plateSeparationMax,
  });

  final YawPitchMvt mvt;
  final double minSeparation;
  final double maxSeparation;

  /// `pMouse.y - modelToViewXYZ(0, -sep/2, 0).y` at drag start.
  double clickYOffset = 0;

  void start({
    required Offset pMouse,
    required double plateSeparation,
  }) {
    final pOrigin =
        mvt.modelToViewXYZ(0, -(plateSeparation / 2), 0);
    clickYOffset = pMouse.dy - pOrigin.dy;
  }

  /// Discretized separation from current mouse view position.
  double separationAt(Offset pMouse) {
    final yView = pMouse.dy - clickYOffset;
    final separation = 2 * mvt.viewToModelDeltaXY(0, -yView).dy;
    final clamped = separation.clamp(minSeparation, maxSeparation);
    return CapacitorPhysics.quantizeSeparation(clamped);
  }
}
