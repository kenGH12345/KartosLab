import '../../domain/mass/buoyancy_mass.dart';
import '../../domain/material/buoyancy_gravity.dart';
import '../../domain/material/buoyancy_material.dart';
import '../../domain/shape/shape_geometry.dart';
import '../../domain/world/vec2.dart';
import '../../physics/buoyancy_physics_world.dart';
import '../../shared/buoyancy_scale_host.dart';
import '../../shared/buoyancy_screen_model.dart';
import '../../shared/shape_ratios.dart';
import '../../shared/two_block_mode.dart';

/// Catalog order from `MassShape.ts` enumeration.
const List<MassShapeKind> kShapesCatalog = [
  MassShapeKind.block,
  MassShapeKind.ellipsoid,
  MassShapeKind.verticalCylinder,
  MassShapeKind.horizontalCylinder,
  MassShapeKind.cone,
  MassShapeKind.invertedCone,
  MassShapeKind.duck,
];

/// One Shapes-screen object slot (`BuoyancyShapeModel`).
class ShapesObjectSlot {
  ShapesObjectSlot({
    required this.idPrefix,
    required this.initialShape,
    required this.widthRatio,
    required this.heightRatio,
    required this.initialPosition,
    required this.material,
    required this.initiallyVisible,
  }) : shape = initialShape {
    mass = BuoyancyMass(
      id: '$idPrefix.${shape.name}',
      material: material,
      geometry: ShapeRatios.fromRatios(shape, widthRatio, heightRatio),
      position: initialPosition,
      visible: initiallyVisible,
    );
  }

  final String idPrefix;
  final MassShapeKind initialShape;
  final BVec2 initialPosition;
  final bool initiallyVisible;

  MassShapeKind shape;
  double widthRatio;
  double heightRatio;
  BuoyancyMaterial material;
  late final BuoyancyMass mass;

  void applyMaterial(BuoyancyMaterial next) {
    material = next;
    mass.setMaterial(next);
  }

  void setShape(MassShapeKind next) {
    if (next == shape) {
      return;
    }
    shape = next;
    mass.setGeometryKeepingBottom(
      ShapeRatios.fromRatios(next, widthRatio, heightRatio),
    );
  }

  void setRatios(double width, double height) {
    widthRatio = width.clamp(0.0, 1.0).toDouble();
    heightRatio = height.clamp(0.0, 1.0).toDouble();
    mass.setGeometryKeepingBottom(
      ShapeRatios.fromRatios(shape, widthRatio, heightRatio),
    );
  }

  void resetSlot() {
    shape = initialShape;
    widthRatio = 0.25;
    heightRatio = 0.75;
    material = BuoyancyMaterial.wood;
    mass.reset();
    mass.setMaterial(material);
    mass.setGeometryKeepingBottom(
      ShapeRatios.fromRatios(shape, widthRatio, heightRatio),
    );
    mass.position = initialPosition;
    mass.visible = initiallyVisible;
  }
}

/// Shapes screen model — `BuoyancyShapesModel.ts`.
///
/// Source snapshot: LOCAL density-buoyancy-common HEAD `0c835c64`.
/// Duck physics = ellipsoid approximation (source Duck extends Ellipsoid).
class BuoyancyShapesModel extends BuoyancyScreenModel with BuoyancyScaleHost {
  BuoyancyShapesModel({super.world}) {
    objectA = ShapesObjectSlot(
      idPrefix: 'shapes.A',
      initialShape: MassShapeKind.block,
      widthRatio: 0.25,
      heightRatio: 0.75,
      initialPosition: const BVec2(-0.225, 0),
      material: BuoyancyMaterial.wood,
      initiallyVisible: true,
    );
    objectB = ShapesObjectSlot(
      idPrefix: 'shapes.B',
      initialShape: MassShapeKind.block,
      widthRatio: 0.25,
      heightRatio: 0.75,
      initialPosition: const BVec2(0.075, 0),
      material: BuoyancyMaterial.wood,
      initiallyVisible: false,
    );
    this.world.addMass(objectA.mass);
    this.world.addMass(objectB.mass);
    // Land scale −0.7 (`BuoyancyShapesModel.ts`).
    initScaleBodies(landX: -0.7);
    this.world.pool.computeFluidY([objectA.mass]);
    lifecycle = ScreenModelLifecycle.idle;
  }

  late final ShapesObjectSlot objectA;
  late final ShapesObjectSlot objectB;
  TwoBlockMode mode = TwoBlockMode.oneBlock;
  BuoyancyMaterial material = BuoyancyMaterial.wood;

  static const List<BuoyancyMaterial> availableMaterials =
      BuoyancyMaterial.simpleMassMaterials;

  void setMode(TwoBlockMode next) {
    mode = next;
    objectB.mass.visible = next == TwoBlockMode.twoBlocks;
    world.pool.computeFluidY(world.masses.where((m) => m.visible).toList());
  }

  void setMaterial(BuoyancyMaterial next) {
    material = next;
    objectA.applyMaterial(next);
    objectB.applyMaterial(next);
  }

  void setObjectShape(String which, MassShapeKind shape) {
    final slot = which == 'B' ? objectB : objectA;
    slot.setShape(shape);
  }

  void setObjectRatios(String which, double width, double height) {
    final slot = which == 'B' ? objectB : objectA;
    slot.setRatios(width, height);
  }

  @override
  void step(double externalDt) {
    syncScaleBodies();
    super.step(externalDt);
    if (!landScale.userControlled) {
      landScaleX = landScale.position.x.clamp(-1.2, world.pool.minX - 0.08);
      landScale.position = BVec2(landScaleX, landScale.position.y);
    }
  }

  @override
  void reset() {
    mode = TwoBlockMode.oneBlock;
    material = BuoyancyMaterial.wood;
    world.gravity = BuoyancyGravity.earth;
    world.resetWorld();
    objectA.resetSlot();
    objectB.resetSlot();
    objectB.mass.visible = false;
    resetScaleBodies(landX: -0.7);
    world.pool.computeFluidY([objectA.mass]);
    lifecycle = ScreenModelLifecycle.idle;
  }

  ShapesModelSnapshot snapshot() => ShapesModelSnapshot(
        mode: mode,
        materialId: material.id,
        shapeA: objectA.shape,
        shapeB: objectB.shape,
        world: world.snapshot(),
      );
}

class ShapesModelSnapshot {
  const ShapesModelSnapshot({
    required this.mode,
    required this.materialId,
    required this.shapeA,
    required this.shapeB,
    required this.world,
  });

  final TwoBlockMode mode;
  final String materialId;
  final MassShapeKind shapeA;
  final MassShapeKind shapeB;
  final BuoyancyWorldSnapshot world;

  @override
  bool operator ==(Object other) =>
      other is ShapesModelSnapshot &&
      mode == other.mode &&
      materialId == other.materialId &&
      shapeA == other.shapeA &&
      shapeB == other.shapeB &&
      world == other.world;

  @override
  int get hashCode => Object.hash(mode, materialId, shapeA, shapeB, world);
}
