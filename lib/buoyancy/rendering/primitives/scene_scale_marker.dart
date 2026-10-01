import '../transform/bvec3.dart';

/// Visual + interactive scale platform (land / pool).
///
/// Source: `Scale.ts` / `PoolScale.ts` / `ScaleView.ts`.
class SceneScaleMarker {
  const SceneScaleMarker({
    required this.id,
    required this.origin,
    required this.readout,
    this.dragMode = ScaleDragMode.none,
  });

  final String id;
  final BVec3 origin;
  final String readout;
  final ScaleDragMode dragMode;
}

enum ScaleDragMode {
  none,
  /// Land scale: free XY on ground plane.
  free,
  /// Pool scale: vertical only via heightProperty.
  vertical,
}
