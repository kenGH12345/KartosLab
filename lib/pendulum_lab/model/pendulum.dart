import 'dart:math' as math;

import 'period_trace.dart';
import 'pl_vector2.dart';

typedef PlCrossingListener = void Function(double dt, bool isPositive);
typedef PlPeakListener = void Function(double theta);
typedef PlStepListener = void Function(double dt);

/// Single pendulum. Source: `js/common/model/Pendulum.js`.
class Pendulum {
  Pendulum({
    required this.index,
    required double mass,
    required double length,
    required this.hasPeriodTimer,
    required double Function() gravity,
    required double Function() friction,
  })  : _mass = mass,
        _length = length,
        _initialMass = mass,
        _initialLength = length,
        _gravityOf = gravity,
        _frictionOf = friction {
    periodTrace = PeriodTrace(this);
    updateDerivedVariables(false);
  }

  final int index;
  final bool hasPeriodTimer;
  final double _initialMass;
  final double _initialLength;
  final double Function() _gravityOf;
  final double Function() _frictionOf;

  late final PeriodTrace periodTrace;

  double _mass;
  double _length;
  double angle = 0;
  double angularVelocity = 0;
  double angularAcceleration = 0;
  PlVector2 position = PlVector2.zero;
  PlVector2 velocity = PlVector2.zero;
  PlVector2 acceleration = PlVector2.zero;
  double kineticEnergy = 0;
  double potentialEnergy = 0;
  double thermalEnergy = 0;
  bool isUserControlled = false;
  bool isTickVisible = false;

  /// Controlled by [PendulumLabModel.numberOfPendula], not by [reset].
  bool isVisible = false;

  final List<PlCrossingListener> crossingListeners = [];
  final List<PlPeakListener> peakListeners = [];
  final List<PlStepListener> stepListeners = [];
  final List<void Function()> userMovedListeners = [];
  final List<void Function()> resetMotionListeners = [];

  /// Called when length/mass/gravity change so the model can notify the view.
  void Function()? onChanged;

  double get mass => _mass;
  double get length => _length;
  double get gravity => _gravityOf();
  double get friction => _frictionOf();
  double get totalEnergy => kineticEnergy + potentialEnergy + thermalEnergy;

  set mass(double value) {
    _mass = value;
    updateDerivedVariables(false);
    onChanged?.call();
  }

  set length(double value) {
    final oldLength = _length;
    _length = value;
    if (oldLength != 0) {
      angularVelocity = angularVelocity * oldLength / value;
    }
    updateDerivedVariables(false);
    periodTrace.resetPathPoints();
    onChanged?.call();
  }

  void notifyGravityChanged() {
    updateDerivedVariables(false);
    periodTrace.resetPathPoints();
    onChanged?.call();
  }

  void setUserControlled(bool controlled) {
    if (isUserControlled == controlled) return;
    isUserControlled = controlled;
    if (controlled) {
      isTickVisible = true;
      angularVelocity = 0;
      updateDerivedVariables(false);
      thermalEnergy = 0;
    }
    periodTrace.resetPathPoints();
    onChanged?.call();
  }

  /// Drag / programmatic angle. Source: angleProperty.lazyLink while user-controlled.
  void setAngle(double value, {required bool fromUser}) {
    angle = value;
    if (fromUser && isUserControlled) {
      updateDerivedVariables(false);
      for (final l in userMovedListeners) {
        l();
      }
    }
    onChanged?.call();
  }

  /// Instantaneous angular acceleration. `Pendulum.omegaDerivative`.
  double omegaDerivative(double theta, double omega) {
    return -frictionTerm(omega) - (gravity / length) * math.sin(theta);
  }

  /// Tangential drag per unit mass per unit length (units of angular accel).
  double frictionTerm(double omega) {
    final m = mass;
    final c = friction;
    return c * length / math.pow(m, 1 / 3) * omega * omega.abs() +
        c / math.pow(m, 2 / 3) * omega;
  }

  void step(double dt) {
    var theta = angle;
    var omega = angularVelocity;
    final numSteps = math.max(7.0, dt * 120);

    for (var i = 0; i < numSteps; i++) {
      final stepSize = dt / numSteps;
      final k1 = omega * stepSize;
      final l1 = omegaDerivative(theta, omega) * stepSize;
      final k2 = (omega + 0.5 * l1) * stepSize;
      final l2 = omegaDerivative(theta + 0.5 * k1, omega + 0.5 * l1) * stepSize;
      final k3 = (omega + 0.5 * l2) * stepSize;
      final l3 = omegaDerivative(theta + 0.5 * k2, omega + 0.5 * l2) * stepSize;
      final k4 = (omega + l3) * stepSize;
      final l4 = omegaDerivative(theta + k3, omega + l3) * stepSize;
      final newTheta = modAngle(theta + (k1 + 2 * k2 + 2 * k3 + k4) / 6);
      final newOmega = omega + (l1 + 2 * l2 + 2 * l3 + l4) / 6;

      if ((newTheta * theta < 0) || (newTheta == 0 && theta != 0)) {
        cross(i * stepSize, (i + 1) * stepSize, newOmega > 0, theta, newTheta);
      }
      if ((newOmega * omega < 0) || (newOmega == 0 && omega != 0)) {
        peak(theta, newTheta);
      }
      theta = newTheta;
      omega = newOmega;
    }

    angle = theta;
    angularVelocity = omega;
    updateDerivedVariables(friction > 0);
    for (final l in stepListeners) {
      l(dt);
    }
    periodTrace.onStep(dt);
  }

  void cross(
    double oldDT,
    double newDT,
    bool isPositiveDirection,
    double oldTheta,
    double newTheta,
  ) {
    final crossingDT = _linear(oldTheta, newTheta, oldDT, newDT, 0);
    for (final l in crossingListeners) {
      l(crossingDT, isPositiveDirection);
    }
    periodTrace.onCrossing(crossingDT, isPositiveDirection);
  }

  void peak(double oldTheta, double newTheta) {
    final turningAngle = (oldTheta + newTheta > 0)
        ? math.max(oldTheta, newTheta)
        : math.min(oldTheta, newTheta);
    for (final l in peakListeners) {
      l(turningAngle);
    }
    periodTrace.onPeak(turningAngle);
  }

  void updateDerivedVariables(bool energyChangeToThermal) {
    final speed = angularVelocity.abs() * length;
    angularAcceleration = omegaDerivative(angle, angularVelocity);
    final height = length * (1 - math.cos(angle));

    final oldKe = kineticEnergy;
    kineticEnergy = 0.5 * mass * speed * speed;
    final oldPe = potentialEnergy;
    potentialEnergy = mass * gravity * height;

    if (energyChangeToThermal) {
      thermalEnergy += (oldKe + oldPe) - (kineticEnergy + potentialEnergy);
    }

    position = PlVector2.polar(length, angle - math.pi / 2);
    velocity = PlVector2.polar(angularVelocity * length, angle);

    var acc = PlVector2.polar(
      -frictionTerm(angularVelocity) / mass,
      angle,
    );
    acc += PlVector2.polar(-gravity * math.sin(angle), angle);
    acc += PlVector2.polar(
      length * angularVelocity * angularVelocity,
      angle + math.pi / 2,
    );
    acceleration = acc;
  }

  /// Does not reset [isVisible].
  void reset() {
    _length = _initialLength;
    _mass = _initialMass;
    angle = 0;
    angularVelocity = 0;
    angularAcceleration = 0;
    position = PlVector2.zero;
    velocity = PlVector2.zero;
    acceleration = PlVector2.zero;
    kineticEnergy = 0;
    potentialEnergy = 0;
    thermalEnergy = 0;
    isUserControlled = false;
    isTickVisible = false;
    periodTrace.resetPathPoints();
    updateDerivedVariables(false);
  }

  bool isStationary() {
    return isUserControlled ||
        (angle == 0 && angularVelocity == 0 && angularAcceleration == 0);
  }

  double getApproximatePeriod() {
    if (gravity <= 0) return double.infinity;
    return 2 * math.pi * math.sqrt(length / gravity);
  }

  void resetMotion() {
    angle = 0;
    angularVelocity = 0;
    isTickVisible = false;
    periodTrace.resetPathPoints();
    updateDerivedVariables(false);
    for (final l in resetMotionListeners) {
      l();
    }
  }

  void resetThermalEnergy() {
    thermalEnergy = 0;
  }

  /// JS `%` sign-of-dividend. Dart `%` is not equivalent — use [num.remainder].
  static double modAngle(double angle) {
    var a = angle.remainder(2 * math.pi);
    if (a < -math.pi) a += 2 * math.pi;
    if (a > math.pi) a -= 2 * math.pi;
    return a;
  }

  static double _linear(
    double x1,
    double x2,
    double y1,
    double y2,
    double x,
  ) {
    if (x2 == x1) return y1;
    return y1 + (x - x1) * (y2 - y1) / (x2 - x1);
  }
}
