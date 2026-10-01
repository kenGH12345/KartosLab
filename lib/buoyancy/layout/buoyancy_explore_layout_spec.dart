/// Explore screen layout spec — PHASE 2B. No Composer / Widget.
library;

import 'buoyancy_compare_layout_spec.dart';
import 'buoyancy_global_layout_spec.dart';

class BuoyancyExploreLayoutSpec {
  const BuoyancyExploreLayoutSpec();

  Offset3 get cameraLookAt => buoyancyCameraLookAt;

  /// B default hidden: visibility false on existing MassView — layout reserved
  /// (controls still in rightBox; ABControlsNode holds controlBNode).
  String get blockBVisibilitySemantics =>
      'visibility false on Mass; controls remain in tree; mode radio shows/hides B';

  List<BuoyancyAnchoredModule> get alignBoxModules => const [
        BuoyancyAnchoredModule(
          id: 'displayOptionsPanel',
          category: BuoyancyLayoutCategory.control,
          xAlign: 'left',
          yAlign: 'bottom',
          driver: BuoyancyGeometryDriver.staticLayout,
        ),
        BuoyancyAnchoredModule(
          id: 'fluidDensityPanel',
          category: BuoyancyLayoutCategory.control,
          xAlign: 'center',
          yAlign: 'bottom',
          driver: BuoyancyGeometryDriver.staticLayout,
        ),
        BuoyancyAnchoredModule(
          id: 'rightSideVBox',
          category: BuoyancyLayoutCategory.control,
          xAlign: 'right',
          yAlign: 'top',
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

  /// BlocksModeRadioButtonGroup aligned with ResetAll via ManualConstraint.
  String get modeRadioAnchorRule =>
      'alignNodeWithResetAllButton: right/bottom relative to ResetAll';

  List<BuoyancyDynamicObject> get dynamicObjects => const [
        BuoyancyDynamicObject(
          id: 'blockA',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Default (−0.2, 0.2) m center',
        ),
        BuoyancyDynamicObject(
          id: 'blockB',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Default (0.05, 0.35); visible iff TWO_BLOCKS',
        ),
        BuoyancyDynamicObject(
          id: 'poolFluidY',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Shared pool waterline',
        ),
      ];

  /// Right barrier follows rightSideVBox.boundsProperty (invisible drag barrier).
  String get rightBarrierRule =>
      'setRightBarrierViewPoint(rightSideVBox.boundsProperty)';
}
