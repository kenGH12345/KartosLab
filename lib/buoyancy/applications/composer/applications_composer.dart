import 'dart:ui';

import '../../applications/model/buoyancy_applications_model.dart';
import '../../applications/model/boat_basin.dart';
import '../../layout/buoyancy_applications_layout_spec.dart';
import '../../layout/buoyancy_global_layout_spec.dart';
import '../../rendering/camera/buoyancy_camera_config.dart';
import '../../rendering/primitives/composed_scene.dart';
import '../../rendering/primitives/scene_from_world.dart';
import '../../rendering/transform/bvec3.dart';
import '../../rendering/transform/buoyancy_three_transform.dart';
import '../../shared/application_mode.dart';
import '../../shared/display_properties.dart';

/// Geometry + cabin basin coupling (PHASE 6 RESOLVED).
class ApplicationsComposer {
  ApplicationsComposer({
    this.layout = const BuoyancyApplicationsLayoutSpec(),
    this.global = const BuoyancyGlobalLayoutSpec(),
  });

  final BuoyancyApplicationsLayoutSpec layout;
  final BuoyancyGlobalLayoutSpec global;

  /// PHASE 6: model-level cabin coupling implemented.
  static const cabinBasinCoupling = 'RESOLVED';

  BuoyancyCameraConfig cameraConfig() => BuoyancyCameraConfig.buoyancyDefault();

  BuoyancyThreeTransform transform(BuoyancyDesignFrame frame) =>
      BuoyancyThreeTransform(camera: cameraConfig(), frame: frame);

  ComposedScene compose(
    BuoyancyApplicationsModel model, {
    BuoyancyDisplayProperties? display,
  }) {
    final d = display ?? BuoyancyDisplayProperties();
    double? cabinY;
    double? cabinMinX;
    double? cabinMaxX;
    if (model.applicationMode == ApplicationMode.boat &&
        model.boat.visible &&
        model.boatBasin.fluidVolume > 0) {
      cabinY = model.boatBasin.fluidY;
      final half =
          BoatBasin.oneLiterHalfWidth * model.boatBasin.stepMultiplier;
      cabinMinX = model.boat.position.x - half;
      cabinMaxX = model.boat.position.x + half;
    }
    final masses = model.world.masses.where((m) => m.visible).toList();
    final arrows = <SceneForceArrow>[];
    for (final m in masses) {
      if (m.id.startsWith('scale.')) continue;
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
    final bottleMode = model.applicationMode == ApplicationMode.bottle;
    return composeWorldScene(
      pool: model.world.pool,
      visibleMasses: masses,
      forceArrows: arrows,
      showMassValues: d.massValuesVisible,
      showDepthLines: d.depthLinesVisible,
      cabinCouplingDeferred: false,
      cabinFluidY: cabinY,
      cabinFluidMinX: cabinMinX,
      cabinFluidMaxX: cabinMaxX,
      // Mesh already scaled to geometry.height (includes stepMultiplier).
      boatScale: (_) => 1.0,
      tagForMass: (m) {
        if (m.id == model.block.id) return 'Brick';
        if (m.id == model.bottle.id) return 'A';
        return null;
      },
      tagColorForMass: (m) {
        if (m.id == model.block.id) return const Color(0xFFED3732);
        if (m.id == model.bottle.id) return const Color(0xFFED3732);
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
        if (bottleMode)
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
}
