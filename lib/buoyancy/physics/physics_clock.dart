import 'constants.dart';

/// External frame dt → fixed 1/120 substeps, max 30.
///
/// Mirrors `PhysicsEngine.step`: `world.step(FIXED_TIME_STEP, dt, MAX_SUB_STEPS)`.
class PhysicsClock {
  PhysicsClock({
    this.fixedDt = BuoyancyPhysicsConstants.fixedTimeStep,
    this.maxSubSteps = BuoyancyPhysicsConstants.maxSubSteps,
  });

  final double fixedDt;
  final int maxSubSteps;

  double accumulator = 0;
  double simulationTime = 0;
  bool paused = false;

  /// Fraction from previous to next internal step for view interpolation.
  double interpolationRatio = 1;

  void reset() {
    accumulator = 0;
    simulationTime = 0;
    interpolationRatio = 1;
    paused = false;
  }

  void pause() => paused = true;
  void resume() => paused = false;

  /// Returns number of fixed substeps to run for [externalDt].
  int planSubsteps(double externalDt) {
    if (paused || externalDt <= 0 || !externalDt.isFinite) {
      return 0;
    }
    accumulator += externalDt;
    var steps = 0;
    while (accumulator >= fixedDt && steps < maxSubSteps) {
      accumulator -= fixedDt;
      steps++;
    }
    // Drop leftover beyond max substeps (same as p2 maxSubSteps behavior).
    if (steps == maxSubSteps && accumulator >= fixedDt) {
      accumulator = accumulator % fixedDt;
    }
    interpolationRatio = (accumulator % fixedDt) / fixedDt;
    return steps;
  }

  void advanceSimulationTime(int steps) {
    simulationTime += steps * fixedDt;
  }
}
