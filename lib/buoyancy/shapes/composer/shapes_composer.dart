import 'dart:ui';

import '../../layout/buoyancy_global_layout_spec.dart';
import '../../layout/buoyancy_shapes_layout_spec.dart';
import '../../rendering/camera/buoyancy_camera_config.dart';
import '../../rendering/primitives/composed_scene.dart';
import '../../rendering/primitives/scene_from_world.dart';
import '../../rendering/transform/bvec3.dart';
import '../../rendering/transform/buoyancy_three_transform.dart';
import '../../shapes/model/buoyancy_shapes_model.dart';
import '../../shared/display_properties.dart';

class ShapesComposer {
  ShapesComposer({
    this.layout = const BuoyancyShapesLayoutSpec(),
    this.global = const BuoyancyGlobalLayoutSpec(),
  });

  final BuoyancyShapesLayoutSpec layout;
  final BuoyancyGlobalLayoutSpec global;

  BuoyancyCameraConfig cameraConfig() => BuoyancyCameraConfig.buoyancyDefault();

  BuoyancyThreeTransform transform(BuoyancyDesignFrame frame) =>
      BuoyancyThreeTransform(camera: cameraConfig(), frame: frame);

  ComposedScene compose(
    BuoyancyShapesModel model, {
    BuoyancyDisplayProperties? display,
  }) {
    final d = display ?? BuoyancyDisplayProperties();
    // initialForceScale 1/4 → bump zoom toward larger arrows.
    final zoom = (d.vectorZoomLevel + 2).clamp(0, 7);
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
          zoomLevel: zoom,
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
        if (m.id.startsWith('shapes.A')) return 'A';
        if (m.id.startsWith('shapes.B')) return 'B';
        return null;
      },
      tagColorForMass: (m) {
        if (m.id.startsWith('shapes.A')) return const Color(0xFF2F59A6);
        if (m.id.startsWith('shapes.B')) return const Color(0xFFED3732);
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
