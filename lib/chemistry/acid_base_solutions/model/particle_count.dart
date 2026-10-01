import 'dart:math' as math;

import 'abs_constants.dart';
import 'abs_math.dart';

/// Concentration → visible particle count.
///
/// Source: `ParticlesCanvasNode.ts` `getParticleCount`, documented in
/// `doc/HA_A-_ratio_model.pdf`. Visual representation only — not mole count.
int absParticleCount(double concentration) {
  final raiseFactor =
      AbsMath.log10(concentration / AbsConstants.particleBaseConcentration);
  final baseFactor = math
      .pow(
        AbsConstants.particleMaxCount / AbsConstants.particleBaseDots,
        1 / AbsMath.log10(1 / AbsConstants.particleBaseConcentration),
      )
      .toDouble();
  return AbsMath.roundSymmetric(
    AbsConstants.particleBaseDots *
        math.pow(baseFactor, raiseFactor).toDouble(),
  ).toInt();
}
