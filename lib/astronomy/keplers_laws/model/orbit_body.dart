/// Gravitational body.
///
/// [已确认] `solar-system-common/js/model/Body.ts` 字段子集
library;

import 'dart:math' as math;

import '../keplers_laws_constants.dart';
import 'kl_vec.dart';

class OrbitBody {
  OrbitBody({
    required this.index,
    required this.mass,
    required this.position,
    required this.velocity,
    this.isActive = true,
  });

  final int index;
  double mass;
  KlVec position;
  KlVec velocity;
  KlVec acceleration = KlVec.zero;
  KlVec gravityForce = KlVec.zero;
  bool isActive;
  bool userIsControllingPosition = false;
  bool userIsControllingVelocity = false;
  bool userIsControllingMass = false;

  /// [已确认] Body.massToRadius
  double get radius => massToRadius(mass);

  static double massToRadius(double mass) {
    return math.max(
      KeplersLawsConstants.minBodyRadius,
      KeplersLawsConstants.massToRadiusCoeff * math.pow(mass, 1 / 3).toDouble(),
    );
  }

  OrbitBody copySnapshot() => OrbitBody(
        index: index,
        mass: mass,
        position: position,
        velocity: velocity,
        isActive: isActive,
      )
        ..acceleration = acceleration
        ..gravityForce = gravityForce;
}
