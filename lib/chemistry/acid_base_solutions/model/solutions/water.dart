import 'dart:math' as math;

import '../abs_colors.dart';
import '../abs_constants.dart';
import '../abs_particle.dart';
import '../particle_key.dart';
import 'aqueous_solution.dart';

/// Pure water — PhET `Water.ts`.
class Water extends AqueousSolution {
  Water()
      : super(
          strengthRange: AbsConstants.waterStrengthRange,
          concentrationRange: AbsConstants.waterConcentrationRange,
        );

  @override
  List<AbsParticle> buildParticles() => [
        AbsParticle(
          key: ParticleKey.h2o,
          color: AbsColors.h2o,
          getConcentration: getH2OConcentration,
        ),
        AbsParticle(
          key: ParticleKey.h3o,
          color: AbsColors.h3o,
          getConcentration: getH3OConcentration,
        ),
        AbsParticle(
          key: ParticleKey.oh,
          color: AbsColors.oh,
          getConcentration: getOHConcentration,
        ),
      ];

  @override
  double getSoluteConcentration() => 0;

  @override
  double getProductConcentration() => 0;

  /// [H3O+] = sqrt(Kw)
  @override
  double getH3OConcentration() =>
      math.sqrt(AbsConstants.waterEquilibriumConstant);

  /// [OH-] = [H3O+]
  @override
  double getOHConcentration() => getH3OConcentration();

  /// [H2O] = W
  @override
  double getH2OConcentration() => concentration;
}
