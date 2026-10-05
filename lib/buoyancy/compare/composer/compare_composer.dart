import 'dart:ui';

import '../../domain/world/vec2.dart';
import '../../layout/buoyancy_compare_layout_spec.dart';
import '../../layout/buoyancy_global_layout_spec.dart';
import '../../compare/model/buoyancy_compare_model.dart';
import '../../rendering/camera/buoyancy_camera_config.dart';
import '../../rendering/primitives/composed_scene.dart';
import '../../rendering/primitives/scene_from_world.dart';
import '../../rendering/transform/bvec3.dart';
import '../../rendering/transform/buoyancy_three_transform.dart';
import '../../shared/compare_block_set.dart';
import '../../shared/display_properties.dart';

/// Compare screen composer — camera from CompareLayoutSpec, not Widget literals.
class CompareComposer {
  CompareComposer({
    this.layout = const BuoyancyCompareLayoutSpec(),
    this.global = const BuoyancyGlobalLayoutSpec(),
  });

  final BuoyancyCompareLayoutSpec layout;
  final BuoyancyGlobalLayoutSpec global;

  BuoyancyCameraConfig cameraConfig() => BuoyancyCameraConfig.compare();

  BuoyancyThreeTransform transform(BuoyancyDesignFrame frame) =>
      BuoyancyThreeTransform(camera: cameraConfig(), frame: frame);

  ComposedScene compose(
    BuoyancyCompareModel model, {
    BuoyancyDisplayProperties? display,
  }) {
    final d = display ?? BuoyancyDisplayProperties();
    final masses = model.world.masses.where((m) => m.visible).toList();
    final arrows = <SceneForceArrow>[];
    for (final m in masses) {
      if (m.id.startsWith('scale.')) {
        continue;
      }
      arrows.addAll(
        forceArrowsFor(
          m,
          showGravity: d.gravityForceVisible,
          showBuoyancy: d.buoyancyForceVisible,
          showContact: d.contactForceVisible,
          showValues: d.forceValuesVisible,
          zoomLevel: d.vectorZoomLevel,
        ),
      );
    }
    return composeWorldScene(
      pool: model.world.pool,
      visibleMasses: masses,
      forceArrows: arrows,
      showMassValues: d.massValuesVisible,
      showDepthLines: d.depthLinesVisible,
      tagForMass: (m) {
        if (m.id.startsWith('scale.')) return null;
        if (m.id.endsWith('.A')) {
          return switch (model.comparisonMode) {
            CompareBlockSet.sameMass => '1A',
            CompareBlockSet.sameVolume => '2A',
            CompareBlockSet.sameDensity => '3A',
          };
        }
        if (m.id.endsWith('.B')) {
          return switch (model.comparisonMode) {
            CompareBlockSet.sameMass => '1B',
            CompareBlockSet.sameVolume => '2B',
            CompareBlockSet.sameDensity => '3B',
          };
        }
        return null;
      },
      tagColorForMass: (m) {
        if (m.id.endsWith('.A')) return const Color(0xFF2F59A6);
        if (m.id.endsWith('.B')) return const Color(0xFFED3732);
        return null;
      },
      scales: [
        SceneScaleMarker(
          id: 'scale.land',
          origin: BVec3(
            model.landScale.position.x,
            model.landScale.position.y,
            0,
          ),
          readout: model.scaleReadout(model.landScale),
          dragMode: ScaleDragMode.free,
        ),
        SceneScaleMarker(
          id: 'scale.pool',
          origin: BVec3(
            model.poolScale.position.x,
            model.poolScale.position.y,
            0,
          ),
          readout: model.scaleReadout(model.poolScale),
          dragMode: ScaleDragMode.vertical,
        ),
      ],
    );
  }

  Offset projectedPosition(BuoyancyThreeTransform mvt, BVec2 model) =>
      mvt.modelMetersToView(model.x, model.y);
}
