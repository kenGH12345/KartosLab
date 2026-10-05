import '../../lab/model/buoyancy_lab_model.dart';
import '../../layout/buoyancy_global_layout_spec.dart';
import '../../layout/buoyancy_lab_layout_spec.dart';
import '../../rendering/camera/buoyancy_camera_config.dart';
import '../../rendering/primitives/composed_scene.dart';
import '../../rendering/primitives/scene_from_world.dart';
import '../../rendering/transform/bvec3.dart';
import '../../rendering/transform/buoyancy_three_transform.dart';
import '../../shared/display_properties.dart';

class LabComposer {
  LabComposer({
    this.layout = const BuoyancyLabLayoutSpec(),
    this.global = const BuoyancyGlobalLayoutSpec(),
  });

  final BuoyancyLabLayoutSpec layout;
  final BuoyancyGlobalLayoutSpec global;

  BuoyancyCameraConfig cameraConfig() => BuoyancyCameraConfig.buoyancyDefault();

  BuoyancyThreeTransform transform(BuoyancyDesignFrame frame) =>
      BuoyancyThreeTransform(camera: cameraConfig(), frame: frame);

  ComposedScene compose(
    BuoyancyLabModel model, {
    BuoyancyDisplayProperties? display,
  }) {
    // Lab defaults: forcesInitiallyDisplayed=true; massValues=false.
    final d = display ??
        BuoyancyDisplayProperties(
          supportsDepthLines: true,
          forcesInitiallyDisplayed: true,
          massValuesInitiallyDisplayed: false,
        );
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
    return composeWorldScene(
      pool: model.world.pool,
      visibleMasses: masses,
      forceArrows: arrows,
      showMassValues: d.massValuesVisible,
      showDepthLines: d.depthLinesVisible,
      scales: [
        SceneScaleMarker(
          id: 'scale.land',
          origin: BVec3(
            model.landScale.position.x,
            model.landScale.position.y,
            0,
          ),
          readout: model.scaleReadout(model.landScale),
          dragMode: ScaleDragMode.none,
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
