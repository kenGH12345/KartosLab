import 'package:flutter/material.dart';

/// 拉绳者（NetForce 屏幕的人物拖拽体）
class Puller {
  Puller({required this.id, required this.force, required this.side, required this.color});

  final String id;
  final double force;      // N: 50, 100, 150
  bool side;               // true=right, false=left ← 改为可变，拖放时设置
  final Color color;
  int? knotIndex;          // 附着的绳结 (0-3), null=未放置
  Offset? position;        // 屏幕位置
}

/// NetForce（合力）屏幕模型：拔河比赛
class NetforceModel {
  static const double gameLength = 400;   // 胜负边界（像素单位）
  static const int knotsPerSide = 4;
  static const double cartStep = 0.003;   // 小车移动倍率

  NetforceModel();

  double cartPosition = 0;
  double cartVelocity = 0;
  bool isRunning = false;
  bool isGameOver = false;
  String? winner; // 'left' | 'right'

  final List<Puller> pullers = [
    // 左侧（蓝色）拉绳者
    Puller(id: 'sl0', force: 50,  side: false, color: const Color(0xFF3B82F6)),
    Puller(id: 'sl1', force: 50,  side: false, color: const Color(0xFF3B82F6)),
    Puller(id: 'ml',  force: 100, side: false, color: const Color(0xFF3B82F6)),
    Puller(id: 'll',  force: 150, side: false, color: const Color(0xFF3B82F6)),
    // 右侧（红色）拉绳者
    Puller(id: 'sr0', force: 50,  side: true, color: const Color(0xFFEF4444)),
    Puller(id: 'sr1', force: 50,  side: true, color: const Color(0xFFEF4444)),
    Puller(id: 'mr',  force: 100, side: true, color: const Color(0xFFEF4444)),
    Puller(id: 'lr',  force: 150, side: true, color: const Color(0xFFEF4444)),
  ];

  List<Puller> get leftPullers => pullers.where((p) => !p.side && p.knotIndex != null).toList();
  List<Puller> get rightPullers => pullers.where((p) => p.side && p.knotIndex != null).toList();

  double get leftForce => leftPullers.fold(0, (s, p) => s + p.force);
  double get rightForce => rightPullers.fold(0, (s, p) => s + p.force);
  double get netForce => rightForce - leftForce;   // 向右为正

  void tick(double dt) {
    if (!isRunning || isGameOver) return;
    cartVelocity += netForce * dt * cartStep;
    cartPosition += cartVelocity * dt * 60;
    _checkGameOver();
  }

  void _checkGameOver() {
    if (cartPosition > gameLength) { isGameOver = true; winner = 'right'; isRunning = false; }
    if (cartPosition < -gameLength) { isGameOver = true; winner = 'left'; isRunning = false; }
  }

  void go() { if (!isGameOver) isRunning = true; }
  void pause() => isRunning = false;
  void returnCart() { cartPosition = 0; cartVelocity = 0; isGameOver = false; winner = null; isRunning = false; }
  void reset() { returnCart(); for (final p in pullers) { p.knotIndex = null; p.position = null; } }
}
