import 'dart:math' as math;

import 'ph_scale_constants.dart';
import 'water.dart';

/// Nullable pH / concentration — `null` means no value (empty beaker).
typedef PhValue = double?;
typedef ConcentrationValue = double?;

/// Static chemistry from PhET `PHModel.ts`.
///
/// Implicit Kw via constant **14** (`pH + pOH = 14`). No named `Kw` symbol.
class PhChemistry {
  PhChemistry._();

  /// Particles in one mole — PhET uses `6.023E23` (not 6.022×10²³).
  static const double avogadrosNumber = 6.023e23;

  static double log10(double x) => math.log(x) / math.ln10;

  /// Dilution pH from stock solute + water volumes (L).
  static PhValue computePH({
    required double solutePH,
    required double soluteVolume,
    required double waterVolume,
  }) {
    final totalVolume = soluteVolume + waterVolume;
    if (totalVolume == 0) return null;
    if (waterVolume == 0) return solutePH;
    if (soluteVolume == 0) return Water.pH;
    if (solutePH < 7) {
      return -log10(
        (math.pow(10, -solutePH) * soluteVolume +
                math.pow(10, -Water.pH) * waterVolume) /
            totalVolume,
      );
    }
    return 14 +
        log10(
          (math.pow(10, solutePH - 14) * soluteVolume +
                  math.pow(10, Water.pH - 14) * waterVolume) /
              totalVolume,
        );
  }

  static PhValue concentrationH3OToPH(ConcentrationValue concentration) {
    if (concentration == null || concentration == 0) return null;
    return -log10(concentration);
  }

  static PhValue concentrationOHToPH(ConcentrationValue concentration) {
    final pH = concentrationH3OToPH(concentration);
    return pH == null ? null : 14 - pH;
  }

  static PhValue molesH3OToPH(double moles, double volume) {
    if (moles == 0 || volume == 0) return null;
    return concentrationH3OToPH(moles / volume);
  }

  static PhValue molesOHToPH(double moles, double volume) {
    if (moles == 0 || volume == 0) return null;
    return concentrationOHToPH(moles / volume);
  }

  static ConcentrationValue volumeToConcentrationH2O(double volume) {
    return volume == 0 ? null : Water.concentration;
  }

  static ConcentrationValue pHToConcentrationH3O(PhValue pH) {
    return pH == null ? null : math.pow(10, -pH).toDouble();
  }

  static ConcentrationValue pHToConcentrationOH(PhValue pH) {
    return pH == null ? null : pHToConcentrationH3O(14 - pH);
  }

  static double computeParticleCount(
    ConcentrationValue concentration,
    double volume,
  ) {
    if (concentration == null) return 0;
    return concentration * volume * avogadrosNumber;
  }

  static double computeMoles(ConcentrationValue concentration, double volume) {
    if (concentration == null) return 0;
    return concentration * volume;
  }

  /// True when displayed pH (2 dp) equals water pH 7.
  static bool isEquivalentToWater(PhValue pH) {
    if (pH == null) return false;
    return PhScaleConstants.toFixedNumber(
          pH,
          PhScaleConstants.phMeterDecimalPlaces,
        ) ==
        Water.pH;
  }
}
