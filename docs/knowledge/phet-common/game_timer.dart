import 'package:flutter/material.dart';

/// 游戏计时器——纯墙钟计时（适合"已用时间"显示 · 不驱动动画帧）。
///
/// 用法：
/// ```dart
/// final timer = GameTimer();
/// timer.onTick = (elapsedMs) { setState(() {}); };
/// timer.start();
/// ```
class GameTimer {
  GameTimer({this.tickInterval = const Duration(milliseconds: 200)});

  final Duration tickInterval;
  void Function(int elapsedMs)? onTick;

  int _elapsedMs = 0;
  DateTime? _startTime;
  bool _isRunning = false;

  int get elapsedMs => _isRunning
      ? _elapsedMs + DateTime.now().difference(_startTime!).inMilliseconds
      : _elapsedMs;
  bool get isRunning => _isRunning;

  void start() {
    _elapsedMs = 0;
    _startTime = DateTime.now();
    _isRunning = true;
  }

  void stop() {
    if (!_isRunning) return;
    _elapsedMs += DateTime.now().difference(_startTime!).inMilliseconds;
    _isRunning = false;
    onTick?.call(_elapsedMs);
  }

  void reset() {
    _elapsedMs = 0;
    _startTime = null;
    _isRunning = false;
    onTick?.call(0);
  }

  String get formatted {
    final totalSec = elapsedMs ~/ 1000;
    final min = totalSec ~/ 60;
    final sec = totalSec % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _isRunning = false;
  }
}
