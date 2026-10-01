import 'dart:math';

/// PhET `phet-core/js/EventTimer` simplified for Color Vision.
///
/// Fires [onEvent] every `getPeriodBeforeNextEvent()` seconds, accumulating
/// [dt]. Passes the time elapsed since the previous event to the callback
/// (used for photon spawn position correction).
class EventTimer {
  EventTimer({
    required this.getPeriodBeforeNextEvent,
    required this.onEvent,
  }) : timeBeforeNextEvent = getPeriodBeforeNextEvent();

  final double Function() getPeriodBeforeNextEvent;
  final void Function(double timeElapsed) onEvent;

  double timeBeforeNextEvent;

  void step(double dt) {
    var remaining = dt;
    while (remaining > 0) {
      if (timeBeforeNextEvent == double.infinity) {
        return;
      }
      if (remaining < timeBeforeNextEvent) {
        timeBeforeNextEvent -= remaining;
        return;
      }
      remaining -= timeBeforeNextEvent;
      final period = getPeriodBeforeNextEvent();
      // timeElapsed argument in PhET is the period that just elapsed
      // (ConstantEventModel always returns 1/rate).
      onEvent(period == double.infinity ? 0 : period);
      timeBeforeNextEvent = period;
      if (period == double.infinity) {
        return;
      }
    }
  }
}

/// Constant event rate (events per second).
class ConstantEventModel {
  ConstantEventModel(this.ratePerSecond);
  final double ratePerSecond;

  double getPeriodBeforeNextEvent() {
    if (ratePerSecond <= 0) return double.infinity;
    return 1 / ratePerSecond;
  }
}

/// Variable rate from an intensity property (RGBPhotonEventModel).
/// Period = 1 / (rate * 2); rate 0 → infinity.
class IntensityEventModel {
  IntensityEventModel(this.getIntensityPercent);
  final double Function() getIntensityPercent;

  double getPeriodBeforeNextEvent() {
    final rate = getIntensityPercent() * 2;
    if (rate <= 0) return double.infinity;
    return 1 / rate;
  }
}

/// Seedable RNG matching PhET `dotRandom` usage sites.
class CvRandom {
  CvRandom([int? seed]) : _rng = seed == null ? Random() : Random(seed);

  final Random _rng;

  double nextDouble() => _rng.nextDouble();

  /// Inclusive range, matching `dotRandom.nextIntBetween`.
  int nextIntBetween(int min, int max) {
    if (max < min) return min;
    return min + _rng.nextInt(max - min + 1);
  }
}
