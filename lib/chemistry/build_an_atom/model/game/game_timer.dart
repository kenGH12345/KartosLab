/// Game timer abstraction — vegas `GameTimer` domain subset.
///
/// Driven by explicit [tick] from a clock (testable; no Timer.periodic inside).
library;

/// Elapsed-seconds game timer with start / stop / reset.
class GameTimer {
  bool _running = false;
  double _elapsedSeconds = 0;

  bool get isRunning => _running;

  /// Whole seconds (vegas stores integer seconds).
  int get elapsedSeconds => _elapsedSeconds.floor();

  double get elapsedSecondsExact => _elapsedSeconds;

  void start() {
    _running = true;
  }

  void stop() {
    _running = false;
  }

  void reset() {
    _running = false;
    _elapsedSeconds = 0;
  }

  /// Advance by [dt] seconds when running.
  void tick(double dt) {
    if (!_running) return;
    if (dt <= 0) return;
    _elapsedSeconds += dt;
  }
}
