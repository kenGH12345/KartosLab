import 'pendulum.dart';

/// Period-trace recorder. Source: `PeriodTrace.js`.
///
/// numberOfPoints:
/// 0 not started; 1 first zero-crossing; 2 first peak;
/// 3 second peak; 4 completed (third zero-crossing).
class PeriodTrace {
  PeriodTrace(this.pendulum);

  final Pendulum pendulum;

  int numberOfPoints = 0;
  bool isVisible = false;
  double elapsedTime = 0;
  bool? counterClockwise;
  double? firstAngle;
  double? secondAngle;

  void onCrossing(double dt, bool isPositive) {
    if (numberOfPoints == 0 && pendulum.angle.abs() < 0.5) {
      numberOfPoints = 1;
      counterClockwise = !isPositive;
      elapsedTime = -dt;
    } else if (numberOfPoints == 3) {
      elapsedTime += dt;
      numberOfPoints = 4;
    } else if (numberOfPoints == 1) {
      resetPathPoints();
    }
  }

  void onPeak(double theta) {
    if (numberOfPoints == 1) {
      firstAngle = theta;
      numberOfPoints = 2;
    } else if (numberOfPoints == 2) {
      secondAngle = theta;
      numberOfPoints = 3;
    }
  }

  void onStep(double dt) {
    if (numberOfPoints > 0 && numberOfPoints < 4) {
      elapsedTime += dt;
    }
  }

  /// Intro/Energy (`!hasPeriodTimer`): keep tracing after fade.
  /// Lab: stay hidden until PeriodTimer starts another run.
  void onFaded() {
    isVisible = false;
    if (!pendulum.hasPeriodTimer) {
      isVisible = true;
    }
  }

  void reset() {
    isVisible = false;
    resetPathPoints();
  }

  void resetPathPoints() {
    counterClockwise = null;
    firstAngle = null;
    secondAngle = null;
    numberOfPoints = 0;
    elapsedTime = 0;
  }
}
