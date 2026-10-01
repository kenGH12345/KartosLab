/// 壳层核子 opacity 动画（render-only）。
///
/// 原版配方 [已确认 `ChartIntroScreenView.fadeAnimation`]：
/// - 对象 = **单个** ParticleView.opacityProperty，不是整层 shell
/// - duration = 1 s
/// - easing = Easing.LINEAR（t 线性）
/// - fade out：当前 opacity → 0，结束后 removeParticle
/// - fade in：先把 opacity 置 0，再 → 1（β 新核子）
///
/// 原版 **箭头加减不是 fade**，是飞入 0.6s / 飞回 300 px/s。
/// [已确认 `BANScreenView.createParticleFromStack` / `returnParticleToStack`]
/// 1s fade 只出现在壳层衰变路径（emit / α / β）。
///
/// ±p/±n **仍复用本套 fade 做 render 验证**，不是原版箭头视觉。
/// 原版箭头：add = 0.6s fly-in；remove = 300 px/s return。
///
/// 已确认的壳层 fade 场景：
/// - α：同帧对 2p+2n 各 `fadeOutShellNucleon`（独立 Animation）
/// - β：旧粒 fade out **同时** 新粒 fade in（同一 1s LINEAR）
/// - p/n 发射：`fadeOutShellNucleon`
///
/// 快速连点 [已确认 原版箭头可同时飞多粒；fade 每粒独立 Animation]：
/// 各核子独立计时，不 restart / 不排队别人。
/// 同一粒先入后出：从**当前** opacity 改向 0。
/// [已确认] twixt Animation `to` 从 property 现值起步。
///
/// Reset [已确认] `BANModel.reset`：先 `particleAnimations.clear()`
/// （remove → `animation.stop()`），再清粒子。立即空核，无残留。
library;

import 'package:flutter/material.dart';

import '../../model/nucleon.dart';
import '../chart_intro_visuals.dart';

class ShellFadeGhost {
  const ShellFadeGhost({
    required this.id,
    required this.type,
    required this.center,
    required this.opacity,
  });

  final int id;
  final NucleonType type;
  final Offset center;
  final double opacity;
}

class _Fade {
  _Fade({
    required this.id,
    required this.from,
    required this.to,
    this.type,
    this.center,
  });

  final int id;
  final double from;
  final double to;
  final NucleonType? type;
  final Offset? center;
  double elapsed = 0;

  double get t =>
      (elapsed / ChartIntroVisuals.shellFadeDuration).clamp(0.0, 1.0);

  /// [已确认] Easing.LINEAR → opacity = from + (to-from)*t
  double get opacity => from + (to - from) * t;

  bool get isDone => elapsed >= ChartIntroVisuals.shellFadeDuration;
}

class ShellFadeAnimator {
  final Map<int, _Fade> _incoming = {};
  final List<_Fade> _outgoing = [];

  bool get hasActive => _incoming.isNotEmpty || _outgoing.isNotEmpty;

  int get incomingCount => _incoming.length;

  int get outgoingCount => _outgoing.length;

  double opacityOf(int id) => _incoming[id]?.opacity ?? 1;

  List<ShellFadeGhost> get ghosts => [
        for (final f in _outgoing)
          if (f.center != null && f.type != null)
            ShellFadeGhost(
              id: f.id,
              type: f.type!,
              center: f.center!,
              opacity: f.opacity,
            ),
      ];

  /// 新入座核子：0 → 1。[已确认] β：`opacity = 0` 再 `fadeAnimation(1, …)`
  void beginIn(int id) {
    _outgoing.removeWhere((f) => f.id == id);
    _incoming[id] = _Fade(id: id, from: 0, to: 1);
  }

  /// 离座核子：现值 → 0，座位冻结。[已确认] fadeOutShellNucleon
  void beginOut({
    required int id,
    required NucleonType type,
    required Offset center,
  }) {
    final from = _incoming.remove(id)?.opacity ?? 1;
    _outgoing.removeWhere((f) => f.id == id);
    _outgoing.add(_Fade(
      id: id,
      from: from,
      to: 0,
      type: type,
      center: center,
    ));
  }

  /// 推进。返回是否仍有活动（或本步刚结束，需要重绘）。
  bool step(double dt) {
    if (!hasActive) return false;
    for (final f in _incoming.values) {
      f.elapsed += dt;
    }
    for (final f in _outgoing) {
      f.elapsed += dt;
    }
    _incoming.removeWhere((_, f) => f.isDone);
    _outgoing.removeWhere((f) => f.isDone);
    return true;
  }

  void clear() {
    _incoming.clear();
    _outgoing.clear();
  }
}
