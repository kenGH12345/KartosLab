import '../force/force2.dart';
import '../material/buoyancy_material.dart';
import '../shape/shape_geometry.dart';
import '../world/vec2.dart';
import '../../physics/constants.dart';

/// Mutable mass body. Shared across screens; identity is [id], not list index.
///
/// Density relationship from `Mass.ts`:
/// `mass = round(density * volume, TOLERANCE) + containedMass`
class BuoyancyMass {
  BuoyancyMass({
    required this.id,
    required BuoyancyMaterial material,
    required ShapeGeometry geometry,
    required BVec2 position,
    BVec2? velocity,
    this.containedMass = 0,
    this.visible = true,
    this.canMove = true,
  })  : material = material,
        geometry = geometry,
        position = position,
        velocity = velocity ?? BVec2.zero,
        _resetMaterial = material,
        _resetGeometry = geometry,
        _resetPosition = position,
        _resetContainedMass = containedMass,
        _resetVisible = visible;

  final String id;

  BuoyancyMaterial material;
  ShapeGeometry geometry;
  BVec2 position;
  BVec2 velocity;
  double containedMass;
  bool visible;
  bool canMove;

  bool userControlled = false;
  BVec2? dragTarget;

  Force2 gravityForce = Force2.zero;
  Force2 buoyancyForce = Force2.zero;
  Force2 contactForce = Force2.zero;
  Force2 viscosityForce = Force2.zero;
  Force2 constraintForce = Force2.zero;

  double submergedVolume = 0;
  double percentSubmerged = 0;

  final BuoyancyMaterial _resetMaterial;
  final ShapeGeometry _resetGeometry;
  final BVec2 _resetPosition;
  final double _resetContainedMass;
  final bool _resetVisible;

  double get volume => geometry.totalVolume;

  double get density => material.density;

  double get mass =>
      _round(density * volume) + containedMass;

  double get bottomY => position.y - geometry.halfHeight;
  double get topY => position.y + geometry.halfHeight;

  /// Fixed-density material: change mass by resizing volume (Cube.createWithMass).
  void setMassKeepingDensity(double newMass) {
    assert(!material.custom || material.density > 0);
    final selfMass = mathMax(newMass - containedMass, BuoyancyPhysicsConstants.tolerance);
    final v = selfMass / density;
    geometry = ShapeGeometry.cubeFromVolume(v);
  }

  /// Custom materials: volume change updates mass via density×volume.
  void setVolumeKeepingDensity(double newVolume) {
    geometry = ShapeGeometry.cubeFromVolume(newVolume);
  }

  void setMaterial(BuoyancyMaterial next) {
    material = next;
  }

  /// Custom material density change keeping volume (mass updates via density×volume).
  void setCustomDensity(double density) {
    assert(density > 0 && density.isFinite);
    material = BuoyancyMaterial.customSolid(density);
  }

  /// Replace geometry while keeping the bottom Y fixed (Shapes shape switch).
  void setGeometryKeepingBottom(ShapeGeometry next) {
    final bottom = bottomY;
    geometry = next;
    position = BVec2(position.x, bottom + geometry.halfHeight);
  }

  void reset() {
    material = _resetMaterial;
    geometry = _resetGeometry;
    position = _resetPosition;
    velocity = BVec2.zero;
    containedMass = _resetContainedMass;
    visible = _resetVisible;
    userControlled = false;
    dragTarget = null;
    gravityForce = Force2.zero;
    buoyancyForce = Force2.zero;
    contactForce = Force2.zero;
    viscosityForce = Force2.zero;
    constraintForce = Force2.zero;
    submergedVolume = 0;
    percentSubmerged = 0;
  }

  BuoyancyMassSnapshot snapshot() => BuoyancyMassSnapshot(
        id: id,
        position: position,
        velocity: velocity,
        mass: mass,
        volume: volume,
        density: density,
        submergedVolume: submergedVolume,
        percentSubmerged: percentSubmerged,
        gravityForce: gravityForce,
        buoyancyForce: buoyancyForce,
        contactForce: contactForce,
        userControlled: userControlled,
      );

  static double _round(double v) {
    final t = BuoyancyPhysicsConstants.tolerance;
    return (v / t).round() * t;
  }

  static double mathMax(double a, double b) => a > b ? a : b;
}

class BuoyancyMassSnapshot {
  const BuoyancyMassSnapshot({
    required this.id,
    required this.position,
    required this.velocity,
    required this.mass,
    required this.volume,
    required this.density,
    required this.submergedVolume,
    required this.percentSubmerged,
    required this.gravityForce,
    required this.buoyancyForce,
    required this.contactForce,
    required this.userControlled,
  });

  final String id;
  final BVec2 position;
  final BVec2 velocity;
  final double mass;
  final double volume;
  final double density;
  final double submergedVolume;
  final double percentSubmerged;
  final Force2 gravityForce;
  final Force2 buoyancyForce;
  final Force2 contactForce;
  final bool userControlled;

  @override
  bool operator ==(Object other) {
    if (other is! BuoyancyMassSnapshot) {
      return false;
    }
    return id == other.id &&
        position == other.position &&
        velocity == other.velocity &&
        mass == other.mass &&
        volume == other.volume &&
        density == other.density &&
        submergedVolume == other.submergedVolume &&
        percentSubmerged == other.percentSubmerged &&
        gravityForce.value == other.gravityForce.value &&
        buoyancyForce.value == other.buoyancyForce.value &&
        contactForce.value == other.contactForce.value &&
        userControlled == other.userControlled;
  }

  @override
  int get hashCode => Object.hash(
        id,
        position,
        velocity,
        mass,
        volume,
        density,
        submergedVolume,
        percentSubmerged,
      );
}
