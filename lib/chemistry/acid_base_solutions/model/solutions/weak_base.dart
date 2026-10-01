import 'dart:math' as math;

import '../abs_colors.dart';
import '../abs_constants.dart';
import '../abs_particle.dart';
import '../particle_key.dart';
import 'aqueous_solution.dart';

/// Weak base B — PhET `WeakBase.ts`.
class WeakBase extends AqueousSolution {
  WeakBase()
      : super(
          strengthRange: AbsConstants.weakStrengthRange,
          concentrationRange: AbsConstants.concentrationRange,
        );

  @override
  List<AbsParticle> buildParticles() => [
        AbsParticle(
          key: ParticleKey.b,
          color: AbsColors.b,
          getConcentration: getSoluteConcentration,
        ),
        AbsParticle(
          key: ParticleKey.h2o,
          color: AbsColors.h2o,
          getConcentration: getH2OConcentration,
        ),
        AbsParticle(
          key: ParticleKey.bh,
          color: AbsColors.bh,
          getConcentration: getProductConcentration,
        ),
        AbsParticle(
          key: ParticleKey.oh,
          color: AbsColors.oh,
          getConcentration: getOHConcentration,
        ),
      ];

  /// [B] = C - [BH+]
  @override
  double getSoluteConcentration() =>
      concentration - getProductConcentration();

  /// [BH+] = ( -Kb + sqrt( Kb*Kb + 4*Kb*c ) ) / 2
  @override
  double getProductConcentration() {
    final kb = strength;
    final c = concentration;
    return (-kb + math.sqrt((kb * kb) + (4 * kb * c))) / 2;
  }

  /// [H3O+] = Kw / [OH-]
  @override
  double getH3OConcentration() =>
      AbsConstants.waterEquilibriumConstant / getOHConcentration();

  /// [OH-] = [BH+]
  @override
  double getOHConcentration() => getProductConcentration();

  /// [H2O] = W - [BH+]
  @override
  double getH2OConcentration() =>
      AbsConstants.waterConcentration - getProductConcentration();
}
