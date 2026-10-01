import 'dart:ui';

import '../../explore/model/buoyancy_explore_model.dart';
import '../../layout/buoyancy_explore_layout_spec.dart';
import '../../layout/buoyancy_global_layout_spec.dart';
import '../../rendering/camera/buoyancy_camera_config.dart';
import '../../rendering/primitives/composed_scene.dart';
import '../../rendering/primitives/scene_from_world.dart';
import '../../rendering/primitives/scene_scale_marker.dart';
import '../../rendering/transform/bvec3.dart';
import '../../rendering/transform/buoyancy_three_transform.dart';
import '../../shared/display_properties.dart';

class ExploreComposer {
  ExploreComposer({
    this.layout = const BuoyancyExploreLayoutSpec(),
    this.global = const BuoyancyGlobalLayoutSpec(),
  });

  final BuoyancyExploreLayoutSpec layout;
  final BuoyancyGlobalLayoutSpec global;

  BuoyancyCameraConfig cameraConfig() => BuoyancyCameraConfig.buoyancyDefault();

  BuoyancyThreeTransform transform(BuoyancyDesignFrame frame) =>
      BuoyancyThreeTransform(camera: cameraConfig(), frame: frame);

  ComposedScene compose(
    BuoyancyExploreModel model, {
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
        if (m.id == model.blockA.id) return 'A';
        if (m.id == model.blockB.id) return 'B';
        return null;
      },
      tagColorForMass: (m) {
        if (m.id == model.blockA.id) return const Color(0xFF2F59A6);
        if (m.id == model.blockB.id) return const Color(0xFFED3732);
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
}
