import 'package:flutter/scheduler.dart';

/// 模拟时钟——驱动所有动力学 sim 的统一心跳。
///
/// 用法：
/// ```dart
/// final clock = SimulationClock(fps: 60);
/// clock.attach(this); // 在 State.initState 中，this 须混入 TickerProviderStateMixin
/// clock.onTick = (dt, totalTime) { model.tick(dt); setState(() {}); };
/// clock.play();
/// ```
class SimulationClock {
  SimulationClock({this.fps = 60.0, this.timeScale = 1.0}) : _dt = 1.0 / fps;

  final double fps;
  double timeScale;

  double get dt => _dt;

  /// 每次 tick 时调用。[dt] 本次步进的模拟时间增量（秒），[totalTime] 累计模拟时间。
  void Function(double dt, double totalTime)? onTick;
  void Function()? onStarted;
  void Function()? onPaused;
  void Function()? onReset;

  final double _dt;
  double _totalTime = 0;
  bool _isRunning = false;
  Ticker? _ticker;

  bool get isRunning => _isRunning;
  bool get isPaused => !_isRunning;
  double get totalTime => _totalTime;

  void attach(TickerProvider vsync) {
    _ticker?.dispose();
    _ticker = vsync.createTicker(_onTick);
  }

  void _onTick(Duration elapsed) {
    if (!_isRunning) return;
    final stepDt = _dt * timeScale;
    _totalTime += stepDt;
    onTick?.call(stepDt, _totalTime);
  }

  void play() {
    if (_isRunning) return;
    _isRunning = true;
    _ticker?.start();
    onStarted?.call();
  }

  void pause() {
    if (!_isRunning) return;
    _isRunning = false;
    _ticker?.stop();
    onPaused?.call();
  }

  void toggle() => _isRunning ? pause() : play();

  /// 手动前进一帧（暂停状态下）。
  void stepForward() {
    if (_isRunning) return;
    final stepDt = _dt * timeScale;
    _totalTime += stepDt;
    onTick?.call(stepDt, _totalTime);
  }

  /// 重置模拟时间到 0。
  void reset() {
    _totalTime = 0;
    onReset?.call();
  }

  void dispose() {
    _ticker?.dispose();
    _ticker = null;
  }
}
