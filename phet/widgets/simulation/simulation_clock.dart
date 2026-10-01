/// Simulation Clock — a ChangeNotifier that manages simulation time, dt,
/// speed, and play/pause state.
///
/// All simulations should use this instead of creating their own
/// [AnimationController] timers.
library;

import 'package:flutter/foundation.dart';

class SimulationClock extends ChangeNotifier {
  /// Total accumulated simulation time (seconds).
  double _time = 0;
  double get time => _time;

  /// Delta time of the last tick (seconds).
  double _dt = 0;
  double get dt => _dt;

  /// Speed multiplier (1.0 = real-time, 0.25 = slow-mo, 2.0 = fast-forward).
  double _speed = 1.0;
  double get speed => _speed;
  set speed(double v) {
    _speed = v;
    notifyListeners();
  }

  /// Whether the simulation is paused.
  bool _isPaused = false;
  bool get isPaused => _isPaused;
  bool get isRunning => !_isPaused;

  /// Whether the simulation has started (at least one tick has occurred).
  bool _hasStarted = false;
  bool get hasStarted => _hasStarted;

  /// Advance the simulation by one tick.
  ///
  /// [rawDt] is the real-time delta in seconds. The clock applies
  /// [speed] multiplier and clamps to prevent large jumps.
  void tick(double rawDt) {
    if (_isPaused) return;
    final clamped = rawDt.clamp(0.001, 0.05);
    _dt = clamped * _speed;
    _time += _dt;
    _hasStarted = true;
    notifyListeners();
  }

  void play() {
    if (_isPaused) {
      _isPaused = false;
      notifyListeners();
    }
  }

  void pause() {
    if (!_isPaused) {
      _isPaused = true;
      notifyListeners();
    }
  }

  void toggle() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  /// Advance exactly one step (used by "step" button when paused).
  void step({double stepDt = 0.016}) {
    _dt = stepDt * _speed;
    _time += _dt;
    _hasStarted = true;
    notifyListeners();
  }

  /// Reset to initial state.
  void reset() {
    _time = 0;
    _dt = 0;
    _isPaused = false;
    _hasStarted = false;
    notifyListeners();
  }
}
