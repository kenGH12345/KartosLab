/// Model meters → experiment-area view coordinates.
/// Source: ModelViewTransform2.createSinglePointScaleInvertedYMapping(ZERO, ZERO, 640)
library;

import 'dart:ui';

import '../../layout/qm_photons_layout_spec.dart';
import '../model/photon_scene_meters.dart';

class PhotonViewTransform {
  const PhotonViewTransform({
    this.scale = QmPhotonsLayoutSpec.modelViewScale,
    this.origin = Offset.zero,
  });

  /// Screen coords per meter.
  final double scale;

  /// Experiment-area local origin (PBS maps here).
  final Offset origin;

  Offset physicsToView(PhotonVec2 meters) => Offset(
        origin.dx + meters.x * scale,
        origin.dy - meters.y * scale, // inverted Y
      );

  PhotonVec2 viewToPhysics(Offset view) => PhotonVec2(
        (view.dx - origin.dx) / scale,
        -(view.dy - origin.dy) / scale,
      );

  double modelToViewDeltaX(double meters) => meters * scale;
  double modelToViewDeltaY(double meters) => -meters * scale;
}
