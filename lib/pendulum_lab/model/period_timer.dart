import 'movable_component.dart';
import 'pendulum.dart';

/// Lab period timer. Source: `lab/model/PeriodTimer.js` + local `Stopwatch.js`.
class PeriodTimer extends MovableComponent {
  PeriodTimer(this.pendula) : super(initiallyVisible: false) {
    for (final p in pendula) {
      p.periodTrace.isVisible = false;
    }
  }

  final List<Pendulum> pendula;

  bool isRunning = false;
  double elapsedTime = 0;
  int activePendulumIndex = 0;

  Pendulum get activePendulum => pendula[activePendulumIndex];

  void setVisible(bool visible) {
    isVisible = visible;
    _syncRunningVisibility();
  }

  void setRunning(bool running) {
    isRunning = running;
    _syncRunningVisibility();
  }

  void setActiveIndex(int index) {
    if (index == activePendulumIndex) return;
    final old = activePendulum;
    clear();
    old.periodTrace.isVisible = false;
    activePendulumIndex = index;
    activePendulum.periodTrace.isVisible = isRunning;
  }

  void _syncRunningVisibility() {
    if (isRunning && isVisible) {
      elapsedTime = 0;
      clear();
      activePendulum.periodTrace.isVisible = true;
    } else if (isVisible) {
      if (activePendulum.periodTrace.numberOfPoints < 4) {
        clear();
      }
      if (activePendulum.periodTrace.numberOfPoints == 0) {
        activePendulum.periodTrace.isVisible = false;
      }
    } else if (isRunning) {
      isRunning = false;
    } else {
      clear();
      activePendulum.periodTrace.isVisible = false;
    }
  }

  /// Pull elapsed time from the active pendulum's period trace.
  void syncFromTrace() {
    if (!isRunning) return;
    elapsedTime = activePendulum.periodTrace.elapsedTime;
    if (activePendulum.periodTrace.numberOfPoints == 4) {
      isRunning = false;
    }
  }

  void onPendulumParameterChanged(Pendulum pendulum) {
    if (activePendulum == pendulum) {
      clear();
    }
  }

  @override
  void reset() {
    super.reset();
    isRunning = false;
    elapsedTime = 0;
    activePendulumIndex = 0;
    clear();
  }

  void clear() {
    elapsedTime = 0;
    if (!isRunning) {
      activePendulum.periodTrace.isVisible = false;
    }
    for (final p in pendula) {
      p.periodTrace.resetPathPoints();
    }
  }

  void stop() {
    if (isRunning) {
      clear();
      isRunning = false;
    }
  }
}
