import 'ph_chemistry.dart';

/// Derived concentrations / moles / particle counts — PhET `SolutionDerivedProperties.ts`.
///
/// Used by Micro and My Solution (not Macro).
class SolutionDerivedProperties {
  SolutionDerivedProperties({
    required this.pH,
    required this.totalVolume,
  });

  PhValue pH;
  double totalVolume;

  ConcentrationValue get concentrationH2O =>
      PhChemistry.volumeToConcentrationH2O(totalVolume);

  ConcentrationValue get concentrationH3O =>
      PhChemistry.pHToConcentrationH3O(pH);

  ConcentrationValue get concentrationOH =>
      PhChemistry.pHToConcentrationOH(pH);

  double get quantityH2O =>
      PhChemistry.computeMoles(concentrationH2O, totalVolume);

  double get quantityH3O =>
      PhChemistry.computeMoles(concentrationH3O, totalVolume);

  double get quantityOH =>
      PhChemistry.computeMoles(concentrationOH, totalVolume);

  double get particleCountH2O =>
      PhChemistry.computeParticleCount(concentrationH2O, totalVolume);

  double get particleCountH3O =>
      PhChemistry.computeParticleCount(concentrationH3O, totalVolume);

  double get particleCountOH =>
      PhChemistry.computeParticleCount(concentrationOH, totalVolume);

  /// [H3O+]/[OH-] ratio; null if empty or [OH-]==0.
  double? get h3oOhRatio {
    if (pH == null) return null;
    final h3o = concentrationH3O;
    final oh = concentrationOH;
    if (h3o == null || oh == null || oh == 0) return null;
    return h3o / oh;
  }

  void update({required PhValue pH, required double totalVolume}) {
    this.pH = pH;
    this.totalVolume = totalVolume;
  }
}
