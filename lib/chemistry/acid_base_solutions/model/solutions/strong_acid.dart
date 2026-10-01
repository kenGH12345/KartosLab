import '../abs_colors.dart';
import '../abs_constants.dart';
import '../abs_particle.dart';
import '../particle_key.dart';
import 'aqueous_solution.dart';

/// Strong acid HA — PhET `StrongAcid.ts`.
class StrongAcid extends AqueousSolution {
  StrongAcid()
      : super(
          strengthRange: AbsConstants.strongStrengthRange,
          concentrationRange: AbsConstants.concentrationRange,
        );

  @override
  List<AbsParticle> buildParticles() => [
        AbsParticle(
          key: ParticleKey.ha,
          color: AbsColors.ha,
          getConcentration: getSoluteConcentration,
        ),
        AbsParticle(
          key: ParticleKey.h2o,
          color: AbsColors.h2o,
          getConcentration: getH2OConcentration,
        ),
        AbsParticle(
          key: ParticleKey.a,
          color: AbsColors.a,
          getConcentration: getProductConcentration,
        ),
        AbsParticle(
          key: ParticleKey.h3o,
          color: AbsColors.h3o,
          getConcentration: getH3OConcentration,
        ),
      ];

  /// [HA] = 0
  @override
  double getSoluteConcentration() => 0;

  /// [A-] = C
  @override
  double getProductConcentration() => concentration;

  /// [H3O+] = C
  @override
  double getH3OConcentration() => concentration;

  /// [OH-] = Kw / [H3O+]
  @override
  double getOHConcentration() =>
      AbsConstants.waterEquilibriumConstant / getH3OConcentration();

  /// [H2O] = W - C
  @override
  double getH2OConcentration() =>
      AbsConstants.waterConcentration - concentration;
}
