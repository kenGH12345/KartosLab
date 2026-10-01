import 'dart:async';

import 'package:flutter/foundation.dart';

/// PhET vegas `GameTimer` @ SHA 6e4726b — wall-clock seconds for status bar.
///
/// Full vegas package not cloned (network); this file vendors the exact
/// start/stop/reset/elapsed semantics used by BCE GameModel.
class GameTimer extends ChangeNotifier {
  bool _isRunning = false;
  int _elapsedSeconds = 0;
  Timer? _interval;

  bool get isRunning => _isRunning;
  int get elapsedSeconds => _elapsedSeconds;

  void reset() {
    _interval?.cancel();
    _interval = null;
    _isRunning = false;
    _elapsedSeconds = 0;
    notifyListeners();
  }

  /// Starts the timer. No-op if already running. Resets elapsed to 0.
  void start() {
    if (_isRunning) return;
    _elapsedSeconds = 0;
    _interval = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds += 1;
      notifyListeners();
    });
    _isRunning = true;
    notifyListeners();
  }

  void stop() {
    if (!_isRunning) return;
    _interval?.cancel();
    _interval = null;
    _isRunning = false;
    notifyListeners();
  }

  void restart() {
    stop();
    start();
  }

  /// PhET `GameTimer.formatTime` — M:SS or H:MM:SS.
  static String formatTime(int time) {
    final hours = time ~/ 3600;
    final minutes = (time - hours * 3600) ~/ 60;
    final seconds = time - hours * 3600 - minutes * 60;
    final minutesString =
        (minutes > 9 || hours == 0) ? '$minutes' : '0$minutes';
    final secondsString = seconds > 9 ? '$seconds' : '0$seconds';
    if (hours > 0) {
      return '$hours:$minutesString:$secondsString';
    }
    return '$minutesString:$secondsString';
  }

  @override
  void dispose() {
    _interval?.cancel();
    _interval = null;
    _isRunning = false;
    super.dispose();
  }
}
