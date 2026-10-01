import 'dart:ui';

import '../mesh/triangle_mesh.dart';
import '../transform/bvec3.dart';
import 'scene_scale_marker.dart';

export 'scene_scale_marker.dart';

class SceneMeshInstance {
  const SceneMeshInstance({
    required this.id,
    required this.mesh,
    required this.origin,
    required this.color,
    this.scale = 1,
    this.opacity = 1,
    this.dragTarget = false,
    this.textureAsset,
    this.massLabel,
    this.tagLabel,
    this.tagColor,
  });

  final String id;
  final TriangleMesh mesh;
  final BVec3 origin;
  final Color color;
  final double scale;
  final double opacity;
  final bool dragTarget;

  /// PhET material color-map path (`assets/buoyancy/images/*_col.jpg`).
  final String? textureAsset;

  /// Mass Values readout, e.g. `4.00 kg`.
  final String? massLabel;

  /// Cuboid tag, e.g. `1A` / `1B`.
  final String? tagLabel;
  final Color? tagColor;
}

class SceneForceArrow {
  const SceneForceArrow({
    required this.origin,
    required this.tipYDesign,
    required this.color,
    this.label,
  });

  final BVec3 origin;
  final double tipYDesign;
  final Color color;
  final String? label;
}

class ComposedScene {
  const ComposedScene({
    required this.background,
    required this.ground,
    required this.pool,
    required this.fluidY,
    required this.meshes,
    this.forceArrows = const [],
    this.scales = const [],
    this.cabinFluidY,
    this.cabinFluidMinX,
    this.cabinFluidMaxX,
    this.cabinCouplingDeferred = false,
    this.fluidVolumeLiters,
    this.showDepthLines = false,
  });

  final Color background;
  final Color ground;
  final ({double minX, double maxX, double minY, double maxY, double depth}) pool;
  final double fluidY;
  final List<SceneMeshInstance> meshes;
  final List<SceneForceArrow> forceArrows;
  final List<SceneScaleMarker> scales;

  /// Boat cabin waterline (model Y). Null when empty / not in boat mode.
  final double? cabinFluidY;
  final double? cabinFluidMinX;
  final double? cabinFluidMaxX;

  /// Legacy flag — cabin coupling is RESOLVED in PHASE 6.
  final bool cabinCouplingDeferred;

  /// Pool `levelVolumeProperty` in liters (displaced + free).
  final double? fluidVolumeLiters;

  final bool showDepthLines;
}
