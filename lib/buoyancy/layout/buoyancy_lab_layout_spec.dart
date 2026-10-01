/// Lab screen layout spec — PHASE 2B. No Composer / Widget.
library;

import 'buoyancy_compare_layout_spec.dart';
import 'buoyancy_global_layout_spec.dart';

class BuoyancyLabLayoutSpec {
  const BuoyancyLabLayoutSpec();

  Offset3 get cameraLookAt => buoyancyCameraLookAt;

  /// Lab enables forces by default (forcesInitiallyDisplayed: true).
  bool get forcesInitiallyDisplayed => true;
  bool get massValuesInitiallyDisplayed => false;

  /// Force arrow view mapping (not physics).
  double get forceArrowUnitsPerNewton => buoyancyForceArrowUnitsPerNewton;

  List<BuoyancyAnchoredModule> get alignBoxModules => const [
        BuoyancyAnchoredModule(
          id: 'bottomFluidAndGravityHBox',
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

  /// Left stack (fluidDisplaced + displayOptions): ManualConstraint to
  /// visibleBounds.left+MARGIN_SMALL, bottom-MARGIN_SMALL.
  String get leftSideAnchorRule =>
      'left = visibleBounds.left + 5; bottom = visibleBounds.bottom - 5';

  List<BuoyancyDynamicObject> get dynamicObjects => const [
        BuoyancyDynamicObject(
          id: 'block',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Default (−0.2, 0.2)',
        ),
        BuoyancyDynamicObject(
          id: 'forceArrows',
          driver: BuoyancyGeometryDriver.modelDriven,
          coordinateSpace: BuoyancyCoordinateSpace.sceneryOverlay,
          note: 'tip = -Fy * vectorZoom * 20; origin on mass',
        ),
        BuoyancyDynamicObject(
          id: 'fluidDisplacedReadout',
          driver: BuoyancyGeometryDriver.modelDriven,
          coordinateSpace: BuoyancyCoordinateSpace.designPixels,
          note: 'Accordion value from Model liters; panel is STATIC',
        ),
        BuoyancyDynamicObject(
          id: 'poolFluidY',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Waterline',
        ),
      ];
}
