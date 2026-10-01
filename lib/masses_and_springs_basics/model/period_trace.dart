import 'dart:math' as math;

import 'spring.dart';

/// PhET `lab/model/PeriodTrace.js` — records oscillation from real spring state.
class PeriodTrace {
  PeriodTrace(this.spring);

  final MasbSpring spring;

  /// 0 idle … 4 completed (then fade).
  int state = 0;
  int crossing = 0;
  int? direction;
  double firstPeakY = 0;
  double secondPeakY = 0;
  double xOffset = 0;
  double alpha = 1;
  bool thresholdReached = false;
  double lineWidth = 2.5;

  void onPeak(int dir) {
    if (state != 0 && state != 4) {
      state += 1;
      final disp = spring.massEquilibriumDisplacement;
      if (state == 2 && disp != null) firstPeakY = disp;
      if (state == 3 && disp != null) secondPeakY = disp;
    }
    if (direction != null && direction != dir) {
      xOffset += 20;
    }
    direction = dir;
  }

  void onCross({required double velocityAbs}) {
    thresholdReached = velocityAbs <= 0.06;
    crossing += 1;
    if (crossing == 1 || crossing == 3) {
      state += 1;
    }
    if (state != 0 && state % 5 == 0) {
      state = 0;
    }
    if (crossing != 0 && crossing % 4 == 0) {
      crossing = 0;
    }
  }

  /// Fade step while state==4 (PeriodTraceNode.fade).
  void fade(double dt) {
    alpha = math.max(0.0, alpha - 1.0 * dt);
    if (alpha <= 0) {
      onFaded();
    }
  }

  void onFaded() {
    state = 0;
    crossing = 0;
    alpha = 1;
    thresholdReached = false;
    lineWidth = 2.5;
    direction = null;
    xOffset = 0;
  }

  void reset() => onFaded();
}
