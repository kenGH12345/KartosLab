import '../domain/mass/buoyancy_mass.dart';
import '../domain/material/buoyancy_material.dart';
import '../domain/shape/shape_geometry.dart';
import '../domain/world/vec2.dart';
import '../physics/buoyancy_physics_world.dart';

/// Shared Scale body helpers — `Scale.ts` / `PoolScale` / Explore+Compare models.
mixin BuoyancyScaleHost {
  BuoyancyPhysicsWorld get world;

  static const double scaleWidth = 0.15;
  static const double scaleHeight = 0.06;
  static const double scaleDepth = 0.2;
  static const double poolScaleX = 0.35;

  late final BuoyancyMass landScale;
  late final BuoyancyMass poolScale;
  double poolScaleHeight = 0.5;
  double landScaleX = -0.65;

  void initScaleBodies({
    required double landX,
    double poolX = poolScaleX,
    bool landCanMove = true,
  }) {
    landScaleX = landX;
    landScale = BuoyancyMass(
      id: 'scale.land',
      material: BuoyancyMaterial.aluminum,
      geometry: ShapeGeometry.block(
        width: scaleWidth,
        height: scaleHeight,
        depth: scaleDepth,
      ),
      position: BVec2(landScaleX, scaleHeight / 2),
      canMove: landCanMove,
    );
    poolScale = BuoyancyMass(
      id: 'scale.pool',
      material: BuoyancyMaterial.aluminum,
      geometry: ShapeGeometry.block(
        width: scaleWidth,
        height: scaleHeight,
        depth: scaleDepth,
      ),
      position: BVec2(poolX, poolScaleCenterY()),
      canMove: false,
    );
    world.addMass(landScale);
    world.addMass(poolScale);
  }

  double poolScaleCenterY() {
    final pool = world.pool;
    final minY = pool.minY;
    final maxY = pool.fluidY + scaleHeight;
    final t = poolScaleHeight.clamp(0.0, 1.0);
    final currentHeight = minY + t * (maxY - minY);
    return currentHeight + scaleHeight / 2;
  }

  void setPoolScaleHeight(double h) {
    poolScaleHeight = h.clamp(0.0, 1.0).toDouble();
    poolScale.position = BVec2(poolScaleX, poolScaleCenterY());
    poolScale.velocity = BVec2.zero;
  }

  void setLandScaleX(double x) {
    final pool = world.pool;
    landScaleX = x.clamp(-1.2, pool.minX - 0.08).toDouble();
    landScale.position = BVec2(landScaleX, scaleHeight / 2);
  }

  void syncScaleBodies() {
    poolScale.position = BVec2(poolScaleX, poolScaleCenterY());
    poolScale.velocity = BVec2.zero;
    if (!landScale.userControlled) {
      landScaleX = landScale.position.x;
    } else {
      landScale.position = BVec2(landScaleX, landScale.position.y);
    }
  }

  String scaleReadout(BuoyancyMass scale) {
    final n = scale.contactForce.y.abs();
    if (n < 0.05) {
      return '0.0 N';
    }
    return '${n.toStringAsFixed(1)} N';
  }

  void resetScaleBodies({required double landX}) {
    poolScaleHeight = 0.5;
    landScaleX = landX;
    landScale.position = BVec2(landScaleX, scaleHeight / 2);
    landScale.velocity = BVec2.zero;
    poolScale.position = BVec2(poolScaleX, poolScaleCenterY());
    poolScale.velocity = BVec2.zero;
  }
}
