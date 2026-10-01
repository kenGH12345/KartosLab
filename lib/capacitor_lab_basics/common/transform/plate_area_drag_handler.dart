import 'dart:ui' show Offset;

import '../../clb_constants.dart';
import '../model/capacitor_physics.dart';
import 'yaw_pitch_mvt.dart';

/// Port of PhET `PlateAreaDragHandler.js`.
///
/// Drag axis is the plate diagonal; all math uses view **x** only.
class PlateAreaDragHandler {
  PlateAreaDragHandler({
    required this.mvt,
    this.minWidth = ClbConstants.plateWidthMin,
    this.maxWidth = ClbConstants.plateWidthMax,
  });

  final YawPitchMvt mvt;
  final double minWidth;
  final double maxWidth;

  /// `pMouse.x - modelToViewDeltaXYZ(width/2, 0, width/2).x` at drag start.
  double clickXOffset = 0;

  void start({required Offset pMouse, required double plateWidth}) {
    final pOrigin = mvt.modelToViewDeltaXYZ(plateWidth / 2, 0, plateWidth / 2);
    clickXOffset = pMouse.dx - pOrigin.dx;
  }

  /// Discretized width from current mouse view position.
  double plateWidthAt(Offset pMouse) {
    final raw = getPlateWidth(pMouse);
    return CapacitorPhysics.quantizeWidthFromArea(raw).clamp(minWidth, maxWidth);
  }

  /// `getPlateWidth` — LinearFunction inverse at 0.
  double getPlateWidth(Offset pMouse) {
    const xView1 = 0.0;
    const xView2 = 1.0;
    final xModel1 = getModelX(pMouse, xView1);
    final xModel2 = getModelX(pMouse, xView2);
    // LinearFunction(xView1, xView2, xModel1, xModel2).inverse(0)
    // → interpolate xView where model X is 0.
    final denom = xModel2 - xModel1;
    if (denom.abs() < 1e-18) {
      return minWidth;
    }
    final xViewAtZero = xView1 + (0 - xModel1) * (xView2 - xView1) / denom;
    return xViewAtZero.clamp(minWidth, maxWidth);
  }

  /// Distance from grab offset for a hypothetical [samplePlateWidth].
  double getModelX(Offset pMouse, double samplePlateWidth) {
    final corner =
        mvt.modelToViewXYZ(samplePlateWidth / 2, 0, samplePlateWidth / 2);
    return pMouse.dx - corner.dx - clickXOffset;
  }
}
