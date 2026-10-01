import 'dart:math' as math;

import '../abs_colors.dart';
import '../abs_constants.dart';
import '../abs_particle.dart';
import '../particle_key.dart';
import 'aqueous_solution.dart';

/// Weak acid HA — PhET `WeakAcid.ts`.
class WeakAcid extends AqueousSolution {
  WeakAcid()
      : super(
          strengthRange: AbsConstants.weakStrengthRange,
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

  /// [HA] = C - [H3O+]
  @override
  double getSoluteConcentration() => concentration - getH3OConcentration();

  /// [A-] = [H3O+]
  @override
  double getProductConcentration() => getH3OConcentration();

  /// [H3O+] = ( -Ka + sqrt( Ka*Ka + 4*Ka*c ) ) / 2
  @override
  double getH3OConcentration() {
    final ka = strength;
    final c = concentration;
    return (-ka + math.sqrt((ka * ka) + (4 * ka * c))) / 2;
  }

  /// [OH-] = Kw / [H3O+]
  @override
  double getOHConcentration() =>
      AbsConstants.waterEquilibriumConstant / getH3OConcentration();

  /// [H2O] = W - [A-]
  @override
  double getH2OConcentration() =>
      AbsConstants.waterConcentration - getProductConcentration();
}
