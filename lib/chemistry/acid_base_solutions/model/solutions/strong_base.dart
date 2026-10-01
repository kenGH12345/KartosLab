import '../abs_colors.dart';
import '../abs_constants.dart';
import '../abs_particle.dart';
import '../particle_key.dart';
import 'aqueous_solution.dart';

/// Strong base MOH — PhET `StrongBase.ts`.
class StrongBase extends AqueousSolution {
  StrongBase()
      : super(
          strengthRange: AbsConstants.strongStrengthRange,
          concentrationRange: AbsConstants.concentrationRange,
        );

  @override
  List<AbsParticle> buildParticles() => [
        AbsParticle(
          key: ParticleKey.moh,
          color: AbsColors.moh,
          getConcentration: getSoluteConcentration,
        ),
        AbsParticle(
          key: ParticleKey.m,
          color: AbsColors.m,
          getConcentration: getProductConcentration,
        ),
        AbsParticle(
          key: ParticleKey.oh,
          color: AbsColors.oh,
          getConcentration: getOHConcentration,
        ),
      ];

  /// [MOH] = 0
  @override
  double getSoluteConcentration() => 0;

  /// [M+] = C
  @override
  double getProductConcentration() => concentration;

  /// [H3O+] = Kw / [OH-]
  @override
  double getH3OConcentration() =>
      AbsConstants.waterEquilibriumConstant / getOHConcentration();

  /// [OH-] = C
  @override
  double getOHConcentration() => concentration;

  /// [H2O] = W
  @override
  double getH2OConcentration() => AbsConstants.waterConcentration;
}
