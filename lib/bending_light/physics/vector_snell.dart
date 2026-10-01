import 'dart:math' as math;

import '../model/bl_vec2.dart';
import 'fresnel.dart';

/// Result of Wikipedia vector-form Snell's law (`PrismsModel.propagateTheRay`).
class VectorSnellResult {
  const VectorSnellResult({
    required this.cosTheta1,
    required this.cosTheta2,
    required this.totalInternalReflection,
    required this.vReflect,
    required this.vRefract,
    required this.reflectedPower,
    required this.transmittedPower,
  });

  final double cosTheta1;
  final double cosTheta2;
  final bool totalInternalReflection;
  final BlVec2 vReflect;
  final BlVec2 vRefract;
  final double reflectedPower;
  final double transmittedPower;
}

/// Prism / multi-surface Snell — **not** Intro scalar Snell.
class VectorSnell {
  VectorSnell._();

  /// [L] = incident direction unit vector.
  /// [n] = surface unit normal pointing toward incident side.
  static VectorSnellResult compute({
    required BlVec2 L,
    required BlVec2 n,
    required double n1,
    required double n2,
  }) {
    final cosTheta1 = n.dotXY(L.x * -1, L.y * -1);
    final cosTheta2Radicand =
        1 - math.pow(n1 / n2, 2).toDouble() * (1 - math.pow(cosTheta1, 2).toDouble());
    final totalInternalReflection = cosTheta2Radicand < 0;
    final cosTheta2 = math.sqrt(cosTheta2Radicand.abs());

    final vReflect = n.times(2 * cosTheta1) + L;

    BlVec2 vRefract;
    if (cosTheta1 > 0) {
      vRefract = L.times(n1 / n2) +
          BlVec2(
            n.x * (n1 / n2 * cosTheta1 - cosTheta2),
            n.y * (n1 / n2 * cosTheta1 - cosTheta2),
          );
    } else {
      vRefract = L.times(n1 / n2) +
          BlVec2(
            n.x * (n1 / n2 * cosTheta1 + cosTheta2),
            n.y * (n1 / n2 * cosTheta1 + cosTheta2),
          );
    }
    vRefract = vRefract.normalize();

    final reflectedPower = totalInternalReflection
        ? 1.0
        : Fresnel.clamp01(
            Fresnel.getReflectedPower(n1, n2, cosTheta1, cosTheta2),
          );
    final transmittedPower = totalInternalReflection
        ? 0.0
        : Fresnel.clamp01(
            Fresnel.getTransmittedPower(n1, n2, cosTheta1, cosTheta2),
          );

    return VectorSnellResult(
      cosTheta1: cosTheta1,
      cosTheta2: cosTheta2,
      totalInternalReflection: totalInternalReflection,
      vReflect: vReflect,
      vRefract: vRefract,
      reflectedPower: reflectedPower,
      transmittedPower: transmittedPower,
    );
  }
}
