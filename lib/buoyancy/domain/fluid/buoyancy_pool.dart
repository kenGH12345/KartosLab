import 'dart:math' as math;

import '../../physics/constants.dart';
import '../../physics/submerged_volume.dart';
import '../mass/buoyancy_mass.dart';
import '../material/buoyancy_material.dart';

/// Rectangular pool basin. Fluid volume is conserved; surface Y is derived.
///
/// Source: `Pool.ts` + `Basin.computeY`.
class BuoyancyPool {
  BuoyancyPool({
    this.minX = -BuoyancyPhysicsConstants.poolWidth / 2,
    this.maxX = BuoyancyPhysicsConstants.poolWidth / 2,
    double? minY,
    this.maxY = 0,
    this.depth = BuoyancyPhysicsConstants.poolDepth,
    double? fluidVolume,
    BuoyancyMaterial? fluidMaterial,
  })  : minY = minY ?? -BuoyancyPhysicsConstants.poolHeight,
        fluidVolume =
            fluidVolume ?? BuoyancyPhysicsConstants.desiredStartingPoolVolume,
        fluidMaterial = fluidMaterial ?? BuoyancyMaterial.water {
    _initialFluidVolume = this.fluidVolume;
    _initialFluidMaterial = this.fluidMaterial;
    computeFluidY(const []);
  }

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final double depth;

  double fluidVolume;
  BuoyancyMaterial fluidMaterial;
  double fluidY = 0;

  late double _initialFluidVolume;
  late BuoyancyMaterial _initialFluidMaterial;

  double get width => maxX - minX;
  double get crossSectionArea => width * depth;
  double get fluidDensity => fluidMaterial.density;
  double get fluidViscosity => fluidMaterial.viscosity;

  double maximumArea(double y) {
    if (y < minY || y > maxY) {
      return 0;
    }
    return crossSectionArea;
  }

  double maximumVolume(double y) {
    if (y <= minY) {
      return 0;
    }
    if (y >= maxY) {
      return width * depth * (maxY - minY);
    }
    return width * depth * (y - minY);
  }

  double emptyVolumeAt(double y, List<BuoyancyMass> masses) {
    var displaced = 0.0;
    for (final m in masses) {
      if (!m.visible) {
        continue;
      }
      if (m.bottomY >= maxY - BuoyancyPhysicsConstants.slip) {
        continue;
      }
      displaced += SubmergedVolume.displacedVolume(
        geometry: m.geometry,
        centerY: m.position.y,
        fluidY: math.min(y, maxY),
      );
    }
    return math.max(0, maximumVolume(y) - displaced);
  }

  double emptyAreaAt(double y, List<BuoyancyMass> masses) {
    var displaced = 0.0;
    for (final m in masses) {
      if (!m.visible) {
        continue;
      }
      displaced += SubmergedVolume.displacedArea(
        geometry: m.geometry,
        centerY: m.position.y,
        fluidY: y,
      );
    }
    return maximumArea(y) - displaced;
  }

  /// Newton / bisection root: emptyVolume(y) == fluidVolume.
  void computeFluidY(List<BuoyancyMass> masses) {
    if (fluidVolume <= 0) {
      fluidY = minY;
      return;
    }
    final emptyTop = emptyVolumeAt(maxY, masses);
    if ((emptyTop - fluidVolume).abs() <= BuoyancyPhysicsConstants.tolerance ||
        emptyTop <= fluidVolume) {
      fluidY = maxY;
      return;
    }

    var lo = minY;
    var hi = maxY;
    for (var i = 0; i < 48; i++) {
      final mid = 0.5 * (lo + hi);
      final empty = emptyVolumeAt(mid, masses);
      if (empty < fluidVolume) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    fluidY = 0.5 * (lo + hi);
  }

  bool containsMass(BuoyancyMass mass) {
    return mass.bottomY < maxY - BuoyancyPhysicsConstants.slip;
  }

  void reset({bool resetFluidMaterial = true}) {
    fluidVolume = _initialFluidVolume;
    if (resetFluidMaterial) {
      fluidMaterial = _initialFluidMaterial;
    }
    computeFluidY(const []);
  }
}
