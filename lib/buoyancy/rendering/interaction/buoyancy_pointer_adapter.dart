import 'dart:ui';

import '../../domain/mass/buoyancy_mass.dart';
import '../../domain/world/vec2.dart';
import '../../shared/buoyancy_scale_host.dart';
import '../../shared/buoyancy_screen_model.dart';
import '../primitives/composed_scene.dart';
import '../transform/bvec3.dart';
import '../transform/buoyancy_three_transform.dart';

/// Pointer → inverse camera → model XY. View never teleports masses.
class BuoyancyPointerAdapter {
  BuoyancyPointerAdapter(this.transform);
  final BuoyancyThreeTransform transform;

  String? hitMassId(Offset viewport, ComposedScene scene) {
    for (final inst in scene.meshes.reversed) {
      if (!inst.dragTarget) {
        continue;
      }
      final c = transform.modelToView(inst.origin);
      final dx = viewport.dx - c.dx;
      final dy = viewport.dy - c.dy;
      if (dx * dx + dy * dy < 48 * 48) {
        return inst.id;
      }
    }
    return null;
  }

  SceneScaleMarker? hitScale(Offset viewport, ComposedScene scene) {
    SceneScaleMarker? best;
    var bestD = 40.0 * 40.0;
    for (final s in scene.scales) {
      if (s.dragMode == ScaleDragMode.none) {
        continue;
      }
      final c = transform.modelToView(s.origin);
      final dx = viewport.dx - c.dx;
      final dy = viewport.dy - c.dy;
      final d = dx * dx + dy * dy;
      if (d < bestD) {
        bestD = d;
        best = s;
      }
    }
    return best;
  }

  /// Vertical span in viewport pixels for pool scale height 0..1.
  double poolScaleSpanPixels(BuoyancyScaleHost model) {
    final pool = model.world.pool;
    final minY = pool.minY;
    final maxY = pool.fluidY + BuoyancyScaleHost.scaleHeight;
    final a =
        transform.modelToView(BVec3(BuoyancyScaleHost.poolScaleX, minY, 0));
    final b =
        transform.modelToView(BVec3(BuoyancyScaleHost.poolScaleX, maxY, 0));
    return (a.dy - b.dy).abs().clamp(40.0, 400.0);
  }

  BVec2? viewportToModelOnMassPlane(
    Offset viewport,
    BuoyancyMass mass,
  ) {
    final ray = transform.rayFromViewport(viewport);
    final hit = transform.intersectZPlane(ray, 0);
    if (hit == null) {
      return null;
    }
    return BVec2(hit.x, hit.y);
  }

  void start(BuoyancyScreenModel model, String id, Offset viewport) {
    final mass = model.world.massById(id);
    if (mass == null || !mass.canMove || !mass.visible) {
      return;
    }
    final p = viewportToModelOnMassPlane(viewport, mass);
    if (p == null) {
      return;
    }
    model.startDrag(id, p);
  }

  void update(BuoyancyScreenModel model, String id, Offset viewport) {
    final mass = model.world.massById(id);
    if (mass == null) {
      return;
    }
    final p = viewportToModelOnMassPlane(viewport, mass);
    if (p == null) {
      return;
    }
    model.updateDrag(id, p);
  }

  void end(BuoyancyScreenModel model, String id) {
    model.endDrag(id);
  }

  /// Delta-based height update — matches small PrecisionSliderThumb travel.
  void updatePoolScaleHeightByDelta(
    BuoyancyScaleHost model, {
    required double startHeight,
    required double startViewportY,
    required Offset viewport,
  }) {
    final span = poolScaleSpanPixels(model);
    // Screen +y down → height decreases when dragging down.
    final dh = (viewport.dy - startViewportY) / span;
    model.setPoolScaleHeight(startHeight - dh);
  }

  void updateLandScaleX(BuoyancyScaleHost model, Offset viewport) {
    final ray = transform.rayFromViewport(viewport);
    final hit = transform.intersectZPlane(ray, 0);
    if (hit == null) {
      return;
    }
    model.setLandScaleX(hit.x);
  }
}
