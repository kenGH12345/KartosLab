/// Compare screen layout spec — PHASE 2B. No Composer / Widget.
library;

import 'dart:ui';

import 'buoyancy_global_layout_spec.dart';

/// Module classification for layout archaeology.
enum BuoyancyLayoutCategory {
  functional,
  display,
  structural,
  physicsVisualization,
  measurement,
  control,
  overlay,
}

enum BuoyancyGeometryDriver {
  staticLayout,
  modelDriven,
  physicsDriven,
  inputDriven,
  animationDriven,
}

class BuoyancyCompareLayoutSpec {
  const BuoyancyCompareLayoutSpec();

  Size get designSize =>
      const Size(buoyancyDesignWidth, buoyancyDesignHeight);

  /// Camera lookAt / viewOffset differ from default Buoyancy screens.
  Offset3 get cameraLookAt => buoyancyBasicsCameraLookAt;
  Offset get viewOffset => buoyancyBasicsViewOffset;

  /// Max right-side content width seed = layoutBounds.width / 2.
  double get rightSideMaxContentWidthSeed => buoyancyDesignWidth / 2;

  /// AlignBox shell (visibleBounds + MARGIN_SMALL).
  List<BuoyancyAnchoredModule> get alignBoxModules => const [
        BuoyancyAnchoredModule(
          id: 'blocksPanel',
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
          id: 'fluidPanel',
          category: BuoyancyLayoutCategory.control,
          xAlign: 'center',
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

  /// Right-side VBox: top = modelToView(pool.maxX,maxY,maxZ).y + MARGIN_SMALL;
  /// right = visibleBounds.right - MARGIN_SMALL.
  String get rightSidePanelsAnchorRule =>
      'top = THREE.modelToView(pool.max corner).y + 5; right = visibleBounds.right - 5';

  /// Blocks A/B: shared pool, left/right of pool in MODEL meters (PHYSICS_DRIVEN pose).
  List<BuoyancyDynamicObject> get dynamicObjects => const [
        BuoyancyDynamicObject(
          id: 'blockA',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Pose from CompareModel; view via THREE MVT — never fixed design y',
        ),
        BuoyancyDynamicObject(
          id: 'blockB',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Same pool; opposite side of poolBounds',
        ),
        BuoyancyDynamicObject(
          id: 'poolFluidY',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Waterline dynamic',
        ),
        BuoyancyDynamicObject(
          id: 'forceArrows',
          driver: BuoyancyGeometryDriver.modelDriven,
          coordinateSpace: BuoyancyCoordinateSpace.sceneryOverlay,
          note: 'ForceDiagramNode length from Force×zoom×20; not LayoutSpec physics',
        ),
      ];
}

class BuoyancyAnchoredModule {
  const BuoyancyAnchoredModule({
    required this.id,
    required this.category,
    required this.xAlign,
    required this.yAlign,
    required this.driver,
  });

  final String id;
  final BuoyancyLayoutCategory category;
  final String xAlign;
  final String yAlign;
  final BuoyancyGeometryDriver driver;
}

class BuoyancyDynamicObject {
  const BuoyancyDynamicObject({
    required this.id,
    required this.driver,
    required this.coordinateSpace,
    required this.note,
  });

  final String id;
  final BuoyancyGeometryDriver driver;
  final BuoyancyCoordinateSpace coordinateSpace;
  final String note;
}
