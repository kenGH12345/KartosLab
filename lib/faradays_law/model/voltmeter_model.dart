import 'dart:math' as math;

import '../faradays_law_constants.dart';
import 'coil.dart';

/// PhET `Voltmeter.js` — needle dynamics driven by calibrated EMF signal.
///
/// `signal = 0.2 * (bottomEmf + topEmf)`
/// `voltage` is both the “displayed voltage” and the needle angle (radians).
class VoltmeterModel {
  double signal = 0;
  double needleAngularVelocity = 0;
  double needleAngularAcceleration = 0;

  /// Same value as root `voltage` / needle angle (radians).
  double voltage = 0;

  double get needleAngle => voltage;

  double get clampedNeedleAngle =>
      voltage.clamp(
        FaradaysLawConstants.needleMinAngle,
        FaradaysLawConstants.needleMaxAngle,
      );

  void step({
    required Coil bottomCoil,
    required Coil topCoil,
    required double dt,
  }) {
    signal = FaradaysLawConstants.emfToSignalScale *
        (bottomCoil.emf + topCoil.emf);

    final responsiveness = FaradaysLawConstants.needleResponsiveness;
    final friction = FaradaysLawConstants.needleFriction;

    needleAngularAcceleration =
        responsiveness * (signal - voltage) - friction * needleAngularVelocity;
    voltage = voltage +
        needleAngularVelocity * dt +
        0.5 * needleAngularAcceleration * dt * dt;

    final angularVelocity =
        needleAngularVelocity + needleAngularAcceleration * dt;
    final angularAcceleration =
        responsiveness * (signal - voltage) - friction * angularVelocity;
    needleAngularVelocity = needleAngularVelocity +
        0.5 * dt * (needleAngularAcceleration + angularAcceleration);

    final threshold = FaradaysLawConstants.activityThreshold;
    if (needleAngularAcceleration != 0 &&
        needleAngularAcceleration.abs() < threshold &&
        needleAngularVelocity != 0 &&
        needleAngularVelocity.abs() < threshold &&
        voltage != 0 &&
        voltage.abs() < threshold) {
      voltage = 0;
      needleAngularVelocity = 0;
      needleAngularAcceleration = 0;
    }
  }

  void reset() {
    signal = 0;
    needleAngularVelocity = 0;
    needleAngularAcceleration = 0;
    voltage = 0;
  }
}

/// Convenience: absolute max needle deflection used by gauge / sound.
double clampNeedleAngle(double angle) => math.max(
      FaradaysLawConstants.needleMinAngle,
      math.min(FaradaysLawConstants.needleMaxAngle, angle),
    );
