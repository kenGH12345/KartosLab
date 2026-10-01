/// [已确认] `js/common/model/PeriodTracker.ts`
library;

import '../keplers_laws_constants.dart';
import 'elliptical_orbit_engine.dart';

enum TrackingState { idle, running, fading, invisible }

class PeriodTracker {
  PeriodTracker(this.engine);

  final EllipticalOrbitEngine engine;

  TrackingState trackingState = TrackingState.idle;
  double periodTimerStartTime = 0;
  bool tracingPath = false;
  double periodTraceStart = 0;
  double periodTraceEnd = 0;
  bool afterPeriodThreshold = false;
  bool periodStopwatchRunning = false;
  double periodStopwatchTime = 0;
  double fadingTime = 0;
  bool fadingRunning = false;

  void onTime(double time, double period) {
    if (trackingState != TrackingState.running) return;
    if (periodTimerStartTime > time) {
      periodTimerStartTime = time;
    }
    final measuredTime = time - periodTimerStartTime;
    afterPeriodThreshold = measuredTime > period * 0.8;
    if (periodStopwatchRunning) {
      if (measuredTime >= period) {
        _beginFade();
      }
      periodStopwatchTime = measuredTime;
    }
  }

  void step(double dt) {
    if (trackingState == TrackingState.fading) {
      fadingTime += dt;
      if (fadingTime >= KeplersLawsConstants.periodFadeDuration) {
        fadingRunning = false;
        softReset();
      }
    }
  }

  void setRunning(bool running, double time) {
    periodStopwatchRunning = running;
    if (running) {
      trackingState = TrackingState.running;
      periodTimerStartTime = time;
      tracingPath = true;
      periodTraceStart = engine.nu;
    } else if (trackingState != TrackingState.fading) {
      softReset();
      periodStopwatchTime = 0;
      tracingPath = false;
    } else {
      tracingPath = false;
    }
  }

  void _beginFade() {
    tracingPath = false;
    trackingState = TrackingState.fading;
    fadingTime = 0;
    fadingRunning = true;
  }

  void timerReset() {
    periodStopwatchRunning = false;
    periodStopwatchTime = 0;
  }

  void softReset() {
    trackingState = TrackingState.idle;
    periodTimerStartTime = 0;
    fadingTime = 0;
    fadingRunning = false;
    afterPeriodThreshold = false;
    tracingPath = false;
    periodTraceStart = 0;
    periodTraceEnd = 0;
  }

  void reset() {
    softReset();
    periodStopwatchRunning = false;
    periodStopwatchTime = 0;
  }
}
