import 'dart:ui';

import '../../domain/fluid/buoyancy_pool.dart';
import '../../domain/force/force_visualization_contract.dart';
import '../../domain/mass/buoyancy_mass.dart';
import '../../domain/shape/shape_geometry.dart';
import '../../physics/constants.dart';
import '../mesh/procedural_meshes.dart';
import '../texture/buoyancy_texture_asset.dart';
import '../transform/bvec3.dart';
import 'composed_scene.dart';

ComposedScene composeWorldScene({
  required BuoyancyPool pool,
  required Iterable<BuoyancyMass> visibleMasses,
  List<SceneForceArrow> forceArrows = const [],
  bool cabinCouplingDeferred = false,
  double? cabinFluidY,
  double? cabinFluidMinX,
  double? cabinFluidMaxX,
  double Function(BuoyancyMass mass)? boatScale,
  bool showMassValues = true,
  bool showDepthLines = false,
  String? Function(BuoyancyMass mass)? tagForMass,
  Color? Function(BuoyancyMass mass)? tagColorForMass,
  List<SceneScaleMarker> scales = const [],
}) {
  final meshes = <SceneMeshInstance>[];
  for (final m in visibleMasses) {
    if (!m.visible) {
      continue;
    }
    if (m.id.startsWith('scale.')) {
      continue;
    }
    // Boat/bottle meshes are pre-scaled to geometry.height; keep instance scale 1
    // (legacy boatScale kept for callers that still pass a multiplier).
    var scale = 1.0;
    if (m.geometry.kind == MassShapeKind.boat) {
      scale = boatScale?.call(m) ?? 1.0;
    }
    final kind = m.geometry.kind;
    final isBottle = kind == MassShapeKind.bottle;
    final isBoat = kind == MassShapeKind.boat;
    // Dense lathe/hull: solid tint. Bottle = translucent plastic (BottleView
    // MeshPhong white/0.4–0.8); boat = aluminum hull.
    final texture = (isBottle || isBoat)
        ? null
        : BuoyancyTextureAsset.pathForMaterial(m.material);
    final color = isBottle
        ? const Color(0xAAD0D8E0) // translucent grey plastic (α≈0.67)
        : BuoyancyTextureAsset.fallbackColor(m.material);
    meshes.add(
      SceneMeshInstance(
        id: m.id,
        mesh: ProceduralMeshes.forGeometry(m.geometry),
        origin: BVec3(m.position.x, m.position.y, 0),
        color: color,
        scale: scale,
        opacity: isBottle ? 0.72 : 1.0,
        dragTarget: m.canMove,
        textureAsset: texture,
        massLabel: showMassValues ? '${m.mass.toStringAsFixed(2)} kg' : null,
        tagLabel: tagForMass?.call(m),
        tagColor: tagColorForMass?.call(m),
      ),
    );
  }

  final liters = pool.fluidVolume * BuoyancyPhysicsConstants.litersInCubicMeter +
      _displacedLiters(pool, visibleMasses);

  return ComposedScene(
    background: const Color.fromARGB(255, 19, 165, 224),
    ground: const Color.fromARGB(255, 161, 101, 47),
    pool: (
      minX: pool.minX,
      maxX: pool.maxX,
      minY: pool.minY,
      maxY: pool.maxY,
      depth: pool.depth,
    ),
    fluidY: pool.fluidY,
    meshes: meshes,
    forceArrows: forceArrows,
    cabinFluidY: cabinFluidY,
    cabinFluidMinX: cabinFluidMinX,
    cabinFluidMaxX: cabinFluidMaxX,
    cabinCouplingDeferred: cabinCouplingDeferred,
    fluidVolumeLiters: liters,
    showDepthLines: showDepthLines,
    scales: scales,
  );
}

double _displacedLiters(BuoyancyPool pool, Iterable<BuoyancyMass> masses) {
  // levelVolume ≈ free fluid + displaced; free is pool.fluidVolume.
  // Approximate displayed liters from surface height × cross-section when full.
  final filled = (pool.fluidY - pool.minY).clamp(0.0, pool.maxY - pool.minY);
  return filled * pool.width * pool.depth * BuoyancyPhysicsConstants.litersInCubicMeter;
}

List<SceneForceArrow> forceArrowsFor(
  BuoyancyMass mass, {
  required bool showGravity,
  required bool showBuoyancy,
  required bool showContact,
  required bool showValues,
  int zoomLevel = 4,
  double hideBelowNewtons = 0.05,
}) {
  final arrows = <SceneForceArrow>[];
  void add(double fy, bool show, int color) {
    if (!show || fy.abs() < hideBelowNewtons) {
      return;
    }
    arrows.add(
      SceneForceArrow(
        origin: BVec3(mass.position.x, mass.position.y, 0),
        tipYDesign: ForceVisualizationContract.arrowTipY(fy, zoomLevel),
        color: Color(color),
        label: showValues ? '${fy.abs().toStringAsFixed(1)} N' : null,
      ),
    );
  }

  add(mass.gravityForce.y, showGravity, 0xFFC51E1E);
  add(mass.buoyancyForce.y, showBuoyancy, 0xFFDA338A);
  add(mass.contactForce.y, showContact, 0xFFEA963E);
  return arrows;
}
