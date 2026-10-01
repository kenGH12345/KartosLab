import '../pl_constants.dart';
import 'movable_component.dart';

/// scenery-phet `Stopwatch` used by `PendulumLabModel`.
///
/// Distinct from the local `Stopwatch.js` that [PeriodTimer] extends.
class PlStopwatch extends MovableComponent {
  PlStopwatch() : super(initiallyVisible: false);

  bool isRunning = false;
  double time = 0;

  void step(double dt) {
    if (!isRunning) return;
    time = (time + dt).clamp(0, PlConstants.stopwatchMaxSeconds);
  }

  void toggleRunning() {
    isRunning = !isRunning;
  }

  void resetTime() {
    time = 0;
    isRunning = false;
  }

  @override
  void reset() {
    super.reset();
    isRunning = false;
    time = 0;
  }
}
