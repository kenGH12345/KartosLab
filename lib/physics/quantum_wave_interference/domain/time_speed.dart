/// PhET `TimeSpeed` (scenery-phet).
enum TimeSpeed {
  slow,
  normal,
  fast,
}

/// Screen-specific multipliers applied to continuous `step(wallDt)`.
///
/// `stepOnce` uses fixed `1/60` and does **not** multiply by these factors
/// (`BaseScreenModel.stepOnce`).
class TimeSpeedFactors {
  const TimeSpeedFactors({
    required this.slow,
    required this.normal,
    required this.fast,
  });

  final double slow;
  final double normal;
  final double fast;

  double factor(TimeSpeed speed) {
    switch (speed) {
      case TimeSpeed.slow:
        return slow;
      case TimeSpeed.normal:
        return normal;
      case TimeSpeed.fast:
        return fast;
    }
  }

  static const TimeSpeedFactors experiment = TimeSpeedFactors(
    slow: 0.25,
    normal: 1.0,
    fast: 4.0,
  );

  static const TimeSpeedFactors highIntensity = TimeSpeedFactors(
    slow: 0.15,
    normal: 0.35,
    fast: 0.65,
  );

  static const TimeSpeedFactors singleParticles = TimeSpeedFactors(
    slow: 0.15,
    normal: 0.7,
    fast: 16.0,
  );
}
