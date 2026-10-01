import '../domain/force/force2.dart';
import '../domain/mass/buoyancy_mass.dart';
import '../domain/world/vec2.dart';
import 'constants.dart';

/// Pointer drag via force-limited constraint (source: `PhysicsEngine.addPointerConstraint`).
///
/// Source: `p2.RevoluteConstraint` with
/// `maxForce = p2PointerMassForce * mass + p2PointerBaseForce` (defaults 0*m + 2500).
///
/// This is NOT `lib/density/solver/buoyancy_world.dart` spring-damper
/// (stiffness 180 / damping 34). That Density solver is REFERENCE ONLY.
class DragConstraint {
  DragConstraint._();

  static const startDragOffset = BuoyancyPhysicsConstants.startDragOffset;

  static double maxForceFor(BuoyancyMass mass) =>
      BuoyancyPhysicsConstants.pointerMassForce * mass.mass +
      BuoyancyPhysicsConstants.pointerBaseForce;

  /// `Mass.startDrag`: lift y by 0.0001 m, mark userControlled, set target.
  static void startDrag(BuoyancyMass mass, BVec2 modelPosition) {
    assert(!mass.userControlled);
    mass.userControlled = true;
    mass.position = mass.position.plusXY(0, startDragOffset);
    mass.dragTarget = modelPosition.plusXY(0, startDragOffset);
  }

  /// `PhysicsEngine.updatePointerConstraint`: move constraint pivot.
  static void updateDrag(BuoyancyMass mass, BVec2 modelPosition) {
    if (!mass.userControlled) {
      return;
    }
    mass.dragTarget = modelPosition;
  }

  /// `Mass.endDrag`: remove constraint, keep velocity.
  static void endDrag(BuoyancyMass mass) {
    if (!mass.userControlled) {
      return;
    }
    mass.userControlled = false;
    mass.dragTarget = null;
    // Velocity intentionally preserved.
  }

  /// Force that pulls the mass center toward [dragTarget], clamped to maxForce.
  ///
  /// Dart reimplementation of a force-limited positional constraint for one
  /// fixed substep (no p2). Does not teleport position.
  static Force2 computeForce(BuoyancyMass mass, double fixedDt) {
    final target = mass.dragTarget;
    if (!mass.userControlled || target == null || fixedDt <= 0) {
      return Force2.zero;
    }
    final error = target - mass.position;
    // Desired velocity to close the error in one fixed step, then force from Δv.
    final desiredVelocity = error * (1 / fixedDt);
    final deltaV = desiredVelocity - mass.velocity;
    final uncapped = deltaV * (mass.mass / fixedDt);
    final capped = uncapped.clampMagnitude(maxForceFor(mass));
    return Force2(capped);
  }
}
