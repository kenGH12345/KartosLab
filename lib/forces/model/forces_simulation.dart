import 'famb_constants.dart';

/// Core 1D Newton engine for Motion / Friction / Acceleration.
/// Behavior authority: PhET `js/motion/model/MotionModel.ts`.
class ForcesSimulation {
  ForcesSimulation({this.mass = 0});

  double mass; // kg (stack sum)
  double position = 0; // m
  double velocity = 0; // m/s
  double appliedForce = 0; // N
  double frictionCoeff = 0; // 0 … MAX_FRICTION

  double frictionForce = 0;
  double sumOfForces = 0;
  double acceleration = 0;

  bool fallen = false;
  String fallenDirection = 'left'; // 'left' | 'right'
  double timeSinceFallen = 0;
  double time = 0;

  double get speed => velocity.abs();

  bool get isStationary => speed <= MotionConstants.velocityThreshold;

  /// Recompute friction + sum forces (also while paused — PhET step()).
  void updateForces() {
    frictionForce = _calcFriction(appliedForce);
    sumOfForces = frictionForce + appliedForce;
  }

  double _calcFriction(double applied) {
    if (frictionCoeff == 0 || mass <= 0) return 0;

    final frictionForceMagnitude =
        (frictionCoeff * mass * MotionConstants.gravity).abs();

    double friction;
    if (isStationary) {
      if (frictionForceMagnitude >= applied.abs()) {
        friction = -applied;
      } else {
        friction = -_sign(applied) * frictionForceMagnitude;
      }
    } else {
      friction = -_sign(velocity) *
          frictionForceMagnitude *
          MotionConstants.kineticFrictionFactor;
    }
    return roundSymmetric(friction);
  }

  static double _sign(double v) => v < 0 ? -1 : 1;

  static bool _changedDirection(double a, double b) {
    return (a < 0 && b > 0) || (a > 0 && b < 0);
  }

  /// Full physics step when playing (PhET stepModel).
  void stepModel(double dt) {
    time += dt;
    updateForces();

    if (mass <= 0) {
      acceleration = 0;
      velocity = 0;
      return;
    }

    acceleration = sumOfForces / mass;

    var newVelocity = velocity + acceleration * dt;
    if (_changedDirection(newVelocity, velocity)) {
      newVelocity = 0;
    }
    if (newVelocity > MotionConstants.maxSpeed) {
      newVelocity = MotionConstants.maxSpeed;
    }
    if (newVelocity < -MotionConstants.maxSpeed) {
      newVelocity = -MotionConstants.maxSpeed;
    }

    velocity = newVelocity;
    position += velocity * dt;

    if (velocity >= MotionConstants.maxSpeed) {
      timeSinceFallen = 0;
      fallenDirection = 'right';
      fallen = true;
      appliedForce = 0;
    } else if (velocity <= -MotionConstants.maxSpeed) {
      timeSinceFallen = 0;
      fallenDirection = 'left';
      fallen = true;
      appliedForce = 0;
    } else if (fallen) {
      timeSinceFallen += dt;
      // Stand up after delay, or if applying force within allowed range.
      if (timeSinceFallen >= MotionConstants.fallenStandUpDelay ||
          appliedForce != 0) {
        fallen = false;
        timeSinceFallen = 0;
      }
    }
  }

  /// PhET manualStep — one 1/60 s frame of motion (forces already updated by caller via updateForces).
  void manualStep() => stepModel(MotionConstants.dt);

  void setAppliedForce(double f) {
    appliedForce = f.clamp(
      MotionConstants.appliedForceMin,
      MotionConstants.appliedForceMax,
    );
    updateForces();
  }

  void setFriction(double mu) {
    frictionCoeff = mu.clamp(0, MotionConstants.maxFriction);
    updateForces();
  }

  void resetDynamics() {
    position = 0;
    velocity = 0;
    appliedForce = 0;
    frictionForce = 0;
    sumOfForces = 0;
    acceleration = 0;
    fallen = false;
    timeSinceFallen = 0;
    time = 0;
  }

  void reset() {
    resetDynamics();
    // frictionCoeff retained or reset by screen model
  }
}
