import 'ph_chemistry.dart';
import 'ph_scale_constants.dart';

/// Visual particle counts for Ratio view — PhET `RatioNode.ts` algorithm.
///
/// **Not** the same as [SolutionDerivedProperties] Avogadro counts.
class RatioParticleCounts {
  RatioParticleCounts._();

  static const int totalParticlesAtPh7 = 100;
  static const int maxMajorityParticles = 3000;
  static const int minMinorityParticles = 5;
  static const double logPhMin = 6;
  static const double logPhMax = 8;

  static int computeNumberOfH3O(PhValue pH) {
    if (pH == null) return 0;
    final c = PhChemistry.pHToConcentrationH3O(pH)!;
    return PhScaleConstants.roundSymmetric(
      c * (totalParticlesAtPh7 / 2) / 1e-7,
    );
  }

  static int computeNumberOfOH(PhValue pH) {
    if (pH == null) return 0;
    final c = PhChemistry.pHToConcentrationOH(pH)!;
    return PhScaleConstants.roundSymmetric(
      c * (totalParticlesAtPh7 / 2) / 1e-7,
    );
  }

  /// Display counts after log/linear clamping (displayed pH, 2 dp).
  static ({int h3o, int oh}) displayCounts(PhValue rawPH) {
    if (rawPH == null) return (h3o: 0, oh: 0);

    final pH = PhScaleConstants.toFixedNumber(
      rawPH,
      PhScaleConstants.phMeterDecimalPlaces,
    );

    late double numberOfH3O;
    late double numberOfOH;

    if (pH >= logPhMin && pH <= logPhMax) {
      numberOfH3O =
          mathMax(minMinorityParticles.toDouble(), computeNumberOfH3O(pH).toDouble());
      numberOfOH =
          mathMax(minMinorityParticles.toDouble(), computeNumberOfOH(pH).toDouble());
    } else {
      final n = (maxMajorityParticles - computeNumberOfOH(logPhMax)) /
          (PhScaleConstants.phMax - logPhMax);
      if (pH > logPhMax) {
        final pHDiff = pH - logPhMax;
        numberOfH3O = mathMax(
          minMinorityParticles.toDouble(),
          computeNumberOfH3O(logPhMax) - pHDiff,
        );
        numberOfOH = computeNumberOfOH(logPhMax) + (pHDiff * n);
      } else {
        final pHDiff = logPhMin - pH;
        numberOfH3O = computeNumberOfH3O(logPhMin) + (pHDiff * n);
        numberOfOH = mathMax(
          minMinorityParticles.toDouble(),
          computeNumberOfOH(logPhMin) - pHDiff,
        );
      }
    }

    return (
      h3o: PhScaleConstants.roundSymmetric(numberOfH3O),
      oh: PhScaleConstants.roundSymmetric(numberOfOH),
    );
  }

  static double mathMax(double a, double b) => a > b ? a : b;
}
