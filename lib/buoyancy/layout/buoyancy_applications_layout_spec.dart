/// Applications screen layout spec — PHASE 2C. No Composer / Widget.
///
/// Boat cabin basin fluid coupling RESOLVED in PHASE 6 (Model).
library;

import 'buoyancy_compare_layout_spec.dart';
import 'buoyancy_global_layout_spec.dart';
import 'buoyancy_shapes_layout_spec.dart';

class BuoyancyApplicationsLayoutSpec {
  const BuoyancyApplicationsLayoutSpec();

  Offset3 get cameraLookAt => buoyancyCameraLookAt;

  /// Bottle / Boat mutually exclusive scenes (applicationMode).
  String get sceneSwitchRule =>
      'bottlePanel.visible ↔ bottle mode; boatPanel.visible ↔ boat mode';

  List<BuoyancyAnchoredModule> get alignBoxModules => const [
        BuoyancyAnchoredModule(
          id: 'rightSideVBox',
          category: BuoyancyLayoutCategory.control,
          xAlign: 'right',
          yAlign: 'top',
          driver: BuoyancyGeometryDriver.staticLayout,
        ),
        BuoyancyAnchoredModule(
          id: 'displayOptionsPanel',
          category: BuoyancyLayoutCategory.control,
          xAlign: 'left',
          yAlign: 'bottom',
          driver: BuoyancyGeometryDriver.staticLayout,
        ),
        BuoyancyAnchoredModule(
          id: 'resetAllButton',
          category: BuoyancyLayoutCategory.control,
          xAlign: 'right',
          yAlign: 'bottom',
          driver: BuoyancyGeometryDriver.staticLayout,
        ),
      ];

  /// resetBoatButton.rightTop = modelToView(pool.maxX,minY,maxZ) + (0,5).
  String get resetBoatButtonAnchorRule =>
      'rightTop = modelToView(pool bottom-right front) + (0, 5); visible iff boat mode';

  /// Mode radio aligned with ResetAll (same pattern as Explore blocksMode).
  String get applicationModeRadioRule =>
      'alignNodeWithResetAllButton(applicationModeRadioButtonGroup)';

  List<BuoyancyVisualPhysicsPair> get applicationMeshes => const [
        BuoyancyVisualPhysicsPair(
          objectId: 'bottle',
          visual: 'BottleView THREE mesh + clipping; TEN_LITER profile',
          physics: 'piecewise TEN_LITER_DISPLACED_* tables',
          mapping: 'ratio along height <-> tables; not a cube or cylinder',
        ),
        BuoyancyVisualPhysicsPair(
          objectId: 'boat',
          visual: 'BoatView mesh from BoatDesign intersection vertices',
          physics: 'ONE_LITER_DISPLACED_* x stepMultiplier^3; hull volume separate',
          mapping: 'not a cube; basin interior separate geometry',
        ),
        BuoyancyVisualPhysicsPair(
          objectId: 'brick',
          visual: 'CuboidView',
          physics: 'block ShapeGeometry',
          mapping: '1:1 when boat mode',
        ),
        BuoyancyVisualPhysicsPair(
          objectId: 'boatBasinFluid',
          visual: 'Fluid mesh in boat basin (GEOMETRY known)',
          physics: 'basin fluid volume / updateFluid RESOLVED (PHASE 6)',
          mapping: 'Layout records bounds; Model owns fluid transfer',
        ),
      ];

  /// Boat cabin / basin: geometry + model coupling RESOLVED (PHASE 6).
  String get boatCabinBasinStatus =>
      'GEOMETRY: BoatDesign interior bounds + ONE_LITER_INTERNAL_*; '
      'COUPLING: RESOLVED (Model PHASE 6) — Layout does not invent fluid transfer';

  List<BuoyancyDynamicObject> get dynamicObjects => const [
        BuoyancyDynamicObject(
          id: 'bottle',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Visible in bottle mode',
        ),
        BuoyancyDynamicObject(
          id: 'boat',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Visible in boat mode',
        ),
        BuoyancyDynamicObject(
          id: 'block',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Brick; boat mode',
        ),
        BuoyancyDynamicObject(
          id: 'poolWaterline',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Never fixed pixel Y',
        ),
        BuoyancyDynamicObject(
          id: 'bottleInteriorFluid',
          driver: BuoyancyGeometryDriver.modelDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Interior volume → visual fill level via Bottle.getYFromVolume',
        ),
        BuoyancyDynamicObject(
          id: 'boatBasinWaterline',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Dynamic; Model boatBasin.fluidY → Painter',
        ),
      ];

  bool get usesSameThreeMvtAsOtherBuoyancyScreens => true;
}
