import 'dart:math' as math;

import '../domain/force/force2.dart';
import '../domain/mass/buoyancy_mass.dart';
import '../domain/fluid/buoyancy_pool.dart';
import '../domain/material/buoyancy_gravity.dart';
import '../domain/world/vec2.dart';
import 'constants.dart';
import 'submerged_volume.dart';

/// Force computation from `DensityBuoyancyModel` postStep listener.
class BuoyancyForces {
  BuoyancyForces._();

  /// Applies gravity, buoyancy, viscosity; writes force fields on [mass].
  ///
  /// Order matches source postStep body loop after contact measurement:
  /// submerged volume → buoyancy → viscosity → gravity.
  static void applyPostStepForces({
    required BuoyancyMass mass,
    required BuoyancyPool pool,
    required BuoyancyGravity gravity,
    required double fixedDt,
    double additionalVerticalAcceleration = 0,
    double? fluidYOverride,
    double? fluidVolumeOverride,
    double? fluidDensityOverride,
  }) {
    final g = gravity.value;
    final massValue = mass.mass;
    final fluidY = fluidYOverride ?? pool.fluidY;
    final fluidVolume = fluidVolumeOverride ?? pool.fluidVolume;
    final fluidDensity = fluidDensityOverride ?? pool.fluidDensity;

    var submerged = 0.0;
    final inFluid = fluidYOverride != null || pool.containsMass(mass);
    if (inFluid) {
      final displaced = SubmergedVolume.displacedVolume(
        geometry: mass.geometry,
        centerY: mass.position.y,
        fluidY: fluidY,
      );
      submerged = displaced > fluidVolume ? fluidVolume : displaced;
    }
    mass.submergedVolume = submerged;

    if (submerged != 0) {
      final displacedMass = submerged * fluidDensity;
      final acceleration = g + additionalVerticalAcceleration;
      final buoyant = BVec2(0, displacedMass * acceleration);
      mass.buoyancyForce = Force2(buoyant);

      // Viscosity from DensityBuoyancyModel.ts
      final ratioSubmerged =
          (1 - BuoyancyPhysicsConstants.viscositySubmergedRatio) +
              BuoyancyPhysicsConstants.viscositySubmergedRatio *
                  submerged /
                  mass.volume;
      final mu = pool.fluidViscosity;
      final hackedViscosity =
          0.03 * math.pow(mu / 0.03, 0.8).toDouble();
      final viscosityMass = math.max(
        BuoyancyPhysicsConstants.viscosityMassCutoff,
        massValue,
      );
      var viscous = mass.velocity *
          (-hackedViscosity *
              viscosityMass *
              ratioSubmerged *
              3000 *
              BuoyancyPhysicsConstants.viscosityMultiplier);
      final maxViscous = mass.velocity.magnitude * massValue / fixedDt;
      if (viscous.magnitude > 1e-6) {
        if (viscous.magnitude > maxViscous) {
          viscous = viscous.withMagnitude(maxViscous);
        }
        mass.viscosityForce = Force2(viscous);
      } else {
        mass.viscosityForce = Force2.zero;
      }
    } else {
      mass.buoyancyForce = Force2.zero;
      mass.viscosityForce = Force2.zero;
    }

    mass.gravityForce = Force2(BVec2(0, -massValue * g));

    // percentSubmerged from buoyancy magnitude (Mass.updateSubmergedMassFraction)
    if (g > 0 && fluidDensity > 0 && mass.volume > 0) {
      final frac = 100 *
          mass.buoyancyForce.magnitude /
          (mass.volume * g * fluidDensity);
      mass.percentSubmerged = frac.clamp(0, 100).toDouble();
    } else {
      mass.percentSubmerged = 0;
    }
  }

  static Force2 netNonContact(BuoyancyMass mass) =>
      mass.gravityForce +
      mass.buoyancyForce +
      mass.viscosityForce +
      mass.constraintForce;
}
