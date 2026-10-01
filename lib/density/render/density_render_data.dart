import 'dart:ui';

import '../model/density_material.dart';
import '../model/density_vec.dart';
import 'density_mvt.dart';

class DensityCubeView {
  const DensityCubeView({
    required this.id,
    required this.tag,
    required this.center,
    required this.volume,
    required this.color,
    required this.massKg,
    required this.showMassLabel,
    required this.materialId,
    this.colorArgb,
    this.grabbed = false,
  });

  final String id;
  final String tag;
  final DensityVec center;
  final double volume;
  final Color color;
  final double massKg;
  final bool showMassLabel;
  final DensityMaterialId materialId;
  final int? colorArgb;
  final bool grabbed;
}

class DensityScaleView {
  const DensityScaleView({
    required this.position,
    required this.massKg,
  });

  final DensityVec position;
  final double massKg;
}

/// Immutable snapshot for painters. Painters must not mutate model.
class DensityRenderData {
  const DensityRenderData({
    required this.mvt,
    required this.cubes,
    required this.fluidSurfaceY,
    this.scale,
  });

  final DensityMvt mvt;
  final List<DensityCubeView> cubes;
  final double fluidSurfaceY;
  final DensityScaleView? scale;
}
