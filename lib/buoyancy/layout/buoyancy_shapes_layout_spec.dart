/// Shapes screen layout spec — PHASE 2C. No Composer / Widget.
library;

import '../domain/shape/shape_geometry.dart';
import 'buoyancy_compare_layout_spec.dart';
import 'buoyancy_global_layout_spec.dart';

class BuoyancyShapesLayoutSpec {
  const BuoyancyShapesLayoutSpec();

  Offset3 get cameraLookAt => buoyancyCameraLookAt;

  /// Shapes uses larger force arrows (initialForceScale: 1/4 vs default 1/16).
  double get initialForceScale => 1 / 4;

  List<MassShapeKind> get shapeCatalogOrder => const [
        MassShapeKind.block,
        MassShapeKind.ellipsoid,
        MassShapeKind.verticalCylinder,
        MassShapeKind.horizontalCylinder,
        MassShapeKind.cone,
        MassShapeKind.invertedCone,
        MassShapeKind.duck,
      ];

  List<BuoyancyAnchoredModule> get alignBoxModules => const [
        BuoyancyAnchoredModule(
          id: 'fluidDensityPanel',
          category: BuoyancyLayoutCategory.control,
          xAlign: 'center',
          yAlign: 'bottom',
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

  /// InfoButton: top/left from modelToView(pool.minX,minY,maxZ) + (0,10).
  String get infoButtonAnchorRule =>
      'top = modelToView(pool bottom-left front).y + 10; left = that.x';

  /// Duck: visual mesh ≠ physics ellipsoid. Layout must keep both bounds.
  BuoyancyVisualPhysicsPair get duckGeometry => const BuoyancyVisualPhysicsPair(
        objectId: 'duck',
        visual: 'Duck mesh (DuckView / THREE geometry)',
        physics: 'Ellipsoid submerged volume / collider',
        mapping: 'Same pose (mass.matrix); different mesh vs ShapeGeometry.duck',
      );

  List<BuoyancyVisualPhysicsPair> get shapeVisualPhysics => const [
        BuoyancyVisualPhysicsPair(
          objectId: 'block',
          visual: 'Cuboid mesh',
          physics: 'block ShapeGeometry',
          mapping: '1:1',
        ),
        BuoyancyVisualPhysicsPair(
          objectId: 'ellipsoid',
          visual: 'Ellipsoid mesh',
          physics: 'ellipsoid',
          mapping: '1:1',
        ),
        BuoyancyVisualPhysicsPair(
          objectId: 'verticalCylinder',
          visual: 'VerticalCylinder mesh',
          physics: 'verticalCylinder',
          mapping: 'axis = +Y',
        ),
        BuoyancyVisualPhysicsPair(
          objectId: 'horizontalCylinder',
          visual: 'HorizontalCylinder mesh',
          physics: 'horizontalCylinder',
          mapping: 'axis along length (not rotate-90 of vertical)',
        ),
        BuoyancyVisualPhysicsPair(
          objectId: 'cone',
          visual: 'Cone mesh vertexUp=true',
          physics: 'cone vertexUp',
          mapping: 'orientation from Cone.isVertexUp',
        ),
        BuoyancyVisualPhysicsPair(
          objectId: 'invertedCone',
          visual: 'Cone mesh vertexUp=false',
          physics: 'invertedCone',
          mapping: 'orientation from Cone.isVertexUp',
        ),
        BuoyancyVisualPhysicsPair(
          objectId: 'duck',
          visual: 'Duck mesh',
          physics: 'ellipsoid approx',
          mapping: 'visual != physics',
        ),
      ];

  List<BuoyancyDynamicObject> get dynamicObjects => const [
        BuoyancyDynamicObject(
          id: 'objectA',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Shape switch keeps bottom Y',
        ),
        BuoyancyDynamicObject(
          id: 'objectB',
          driver: BuoyancyGeometryDriver.physicsDriven,
          coordinateSpace: BuoyancyCoordinateSpace.modelMeters,
          note: 'Hidden unless TWO_BLOCKS',
        ),
      ];
}

class BuoyancyVisualPhysicsPair {
  const BuoyancyVisualPhysicsPair({
    required this.objectId,
    required this.visual,
    required this.physics,
    required this.mapping,
  });

  final String objectId;
  final String visual;
  final String physics;
  final String mapping;
}
