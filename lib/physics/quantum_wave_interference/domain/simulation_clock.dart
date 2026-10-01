import '../constants/qwi_constants.dart';
import 'time_speed.dart';

/// Independent simulation clock — not tied to Flutter frame callbacks.
class SimulationClock {
  SimulationClock({
    required this.speedFactors,
    TimeSpeed initialSpeed = TimeSpeed.normal,
    bool playing = true,
  })  : speed = initialSpeed,
        isPlaying = playing;

  final TimeSpeedFactors speedFactors;

  double time = 0;
  TimeSpeed speed;
  bool isPlaying;

  /// Last effective dt applied by [advance] / [stepOnce] (for diagnostics).
  double lastDt = 0;

  double get speedFactor => speedFactors.factor(speed);

  /// Continuous playback: wall-clock [wallDt] scaled by TimeSpeed.
  /// Returns effective model dt (0 when paused).
  double advance(double wallDt) {
    if (!isPlaying || wallDt <= 0) {
      lastDt = 0;
      return 0;
    }
    final dt = wallDt * speedFactor;
    time += dt;
    lastDt = dt;
    return dt;
  }

  /// HI/SP `stepOnce`: fixed `1/60`, does **not** multiply by TimeSpeed.
  double stepOnce() {
    const dt = QwiConstants.nominalDt;
    time += dt;
    lastDt = dt;
    return dt;
  }

  void pause() => isPlaying = false;

  void play() => isPlaying = true;

  void setSpeed(TimeSpeed value) => speed = value;

  void reset() {
    time = 0;
    lastDt = 0;
    isPlaying = true;
    speed = TimeSpeed.normal;
  }
}
