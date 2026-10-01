/// Minimal PhET `Stopwatch` state used by WOASModel.
///
/// Source steps the stopwatch inside `manualStep` via
/// `stopwatch.step(FRAME_DURATION * speedMultiplier)`.
/// Advancement only occurs when [isRunning] is true (scenery-phet Stopwatch).
class WoasStopwatch {
  bool isVisible = false;
  bool isRunning = false;

  /// Elapsed simulation time on the stopwatch (seconds).
  double time = 0;

  /// Approximate PhET `Stopwatch.ZERO_TO_ALMOST_SIXTY` upper bound.
  static const double maxTime = 59.99;

  void step(double dt) {
    if (!isRunning) return;
    time = (time + dt).clamp(0.0, maxTime);
  }

  void reset() {
    isVisible = false;
    isRunning = false;
    time = 0;
  }
}
