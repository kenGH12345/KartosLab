import 'dart:math' as math;

import '../../domain/mass/buoyancy_mass.dart';
import '../../physics/constants.dart';
import 'application_displacement_tables.dart';

/// Boat cabin basin — source `BoatBasin.ts` + `Boat.getBasinArea/Volume`.
///
/// Absolute model Y bounds track the boat each step; fluid volume is independent
/// of the main pool until transfer logic moves fluid between them.
class BoatBasin {
  BoatBasin();

  static const oneLiterBoundsMinY = -0.022069290184621743;
  static const oneLiterBoundsMaxY = 0.03596482386676778;
  static const oneLiterInteriorBottom =
      ApplicationDisplacementTables.boatOneLiterInteriorBottom;
  /// Approx half-width of 1 L hull (BoatSourceMesh / BoatDesign bounds).
  static const oneLiterHalfWidth = 0.151321;

  double fluidVolume = 0;
  double fluidY = 0;
  double stepBottom = 0;
  double stepTop = 0;
  double stepMultiplier = 1;
  double stepInternalVolume = 0;

  /// Sync absolute basin extents from boat pose (`Boat.updateStepInformation`).
  void updateStepFromBoat({
    required BuoyancyMass boat,
    required double displacementVolumeM3,
  }) {
    final m = math.pow(displacementVolumeM3 / 0.001, 1 / 3).toDouble();
    stepMultiplier = m;
    final yOffset = boat.position.y;
    stepTop = yOffset + m * oneLiterBoundsMaxY;
    stepBottom = yOffset + m * oneLiterInteriorBottom;
    final internals = ApplicationDisplacementTables.boatOneLiterInternalVolumes;
    stepInternalVolume = internals.last * m * m * m;
  }

  double boatStepBottom(BuoyancyMass boat, double displacementVolumeM3) {
    final m = math.pow(displacementVolumeM3 / 0.001, 1 / 3).toDouble();
    return boat.position.y + m * oneLiterBoundsMinY;
  }

  double boatStepTop(BuoyancyMass boat, double displacementVolumeM3) {
    final m = math.pow(displacementVolumeM3 / 0.001, 1 / 3).toDouble();
    return boat.position.y + m * oneLiterBoundsMaxY;
  }

  double getBasinArea(double fluidLevel) {
    if (fluidLevel <= stepBottom || fluidLevel >= stepTop) {
      return 0;
    }
    final ratio = (fluidLevel - stepBottom) / (stepTop - stepBottom);
    return _piecewise(
          ApplicationDisplacementTables.boatOneLiterInternalAreas,
          ratio,
        ) *
        stepMultiplier *
        stepMultiplier;
  }

  double getBasinVolume(double fluidLevel) {
    if (fluidLevel <= stepBottom) {
      return 0;
    }
    if (fluidLevel >= stepTop) {
      return stepInternalVolume;
    }
    final ratio = (fluidLevel - stepBottom) / (stepTop - stepBottom);
    return _piecewise(
          ApplicationDisplacementTables.boatOneLiterInternalVolumes,
          ratio,
        ) *
        stepMultiplier *
        stepMultiplier *
        stepMultiplier;
  }

  double getMaximumVolume(double y) => getBasinVolume(y);

  double getEmptyVolume(double y) => math.max(0, getMaximumVolume(y));

  /// Root-find fluidY so emptyVolume(y) == fluidVolume (`Basin.computeY`).
  void computeY() {
    if (fluidVolume <= 0) {
      fluidY = stepBottom;
      return;
    }
    final emptyTop = getEmptyVolume(stepTop);
    if ((emptyTop - fluidVolume).abs() <= BuoyancyPhysicsConstants.tolerance ||
        emptyTop <= fluidVolume) {
      fluidY = stepTop;
      return;
    }
    var lo = stepBottom;
    var hi = stepTop;
    for (var i = 0; i < 48; i++) {
      final mid = 0.5 * (lo + hi);
      final empty = getEmptyVolume(mid);
      if (empty < fluidVolume) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    fluidY = 0.5 * (lo + hi);
  }

  /// Approximate "mass inside cabin" using absolute Y into basin (source uses
  /// 2D shape containment; AABB in Y + boat X proximity is the Dart stand-in).
  bool isMassInside(BuoyancyMass mass, BuoyancyMass boat) {
    if (identical(mass, boat)) {
      return false;
    }
    if (mass.bottomY >= stepTop ||
        mass.topY <= stepBottom - BuoyancyPhysicsConstants.slip) {
      return false;
    }
    final halfW = oneLiterHalfWidth * stepMultiplier;
    return (mass.position.x - boat.position.x).abs() <= halfW + 0.05;
  }

  void reset() {
    fluidVolume = 0;
    fluidY = 0;
    stepBottom = 0;
    stepTop = 0;
    stepMultiplier = 1;
    stepInternalVolume = 0;
  }

  static double _piecewise(List<double> values, double ratio) {
    if (values.isEmpty) {
      return 0;
    }
    final r = ratio.clamp(0.0, 1.0);
    final n = values.length;
    final f = r * (n - 1);
    final i = f.floor().clamp(0, n - 2);
    final t = f - i;
    return values[i] * (1 - t) + values[i + 1] * t;
  }
}
