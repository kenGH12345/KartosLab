/// 半衰期指针运动（纯渲染状态，不查核素表）。
///
/// 对标 `HalfLifeNumberLineNode.moveHalfLifePointerSet` + twixt `Animation`：
/// - 动画对象是 **model X**（`arrowXPositionProperty` = log10 指数），再经 ChartTransform 上屏
/// - X：0.7s，`Easing.QUADRATIC_IN_OUT`
/// - 旋转：0.1s，同一 easing；向右（钉在 10^24）时先 X 后转；否则先转回向下再 X
/// - 新目标：`stop()` 当前动画（停在当前值，**不**触发 then），再从当前值开新序列
/// - hidden 时仍把 X 动画到指数 0；visible 立即按 Reading 切换
library;

import 'dart:math' as math;

import 'half_life_number_line.dart';

class HalfLifePointerPose {
  const HalfLifePointerPose({
    required this.exponent,
    required this.rotation,
    required this.visible,
  });

  /// 当前显示用的 model X（秒的 log10）。
  final double exponent;

  /// scenery 旋转：0 = 向下，-π/2 = 向右。[已确认] ROTATION_POINTING_*
  final double rotation;

  final bool visible;
}

class HalfLifePointerAnimator {
  HalfLifePointerAnimator();

  /// [已确认] moveHalfLifePointerSet arrowXPositionAnimationDuration = 0.7
  static const double xDuration = 0.7;

  /// [已确认] arrowRotationAnimationDuration = 0.1
  static const double rotationDuration = 0.1;

  static const double rotationDown = 0;
  static const double rotationRight = -math.pi / 2;

  double exponent = 0;
  double rotation = rotationDown;
  bool visible = false;

  _Tween? _active;
  _Tween? _queued;

  HalfLifePointerPose get pose => HalfLifePointerPose(
        exponent: exponent,
        rotation: rotation,
        visible: visible,
      );

  /// 对标 `moveHalfLifePointerSet`：停掉旧动画，从**当前**指数/旋转开新序列。
  void setTarget(HalfLifeNumberLineReading reading) {
    _active = null;
    _queued = null;
    visible = reading.pointerVisible;

    final x = _Tween(
      kind: _Kind.x,
      from: exponent,
      to: reading.pointerExponent,
      duration: xDuration,
    );
    final rot = _Tween(
      kind: _Kind.rot,
      from: rotation,
      to: reading.pointerPointsRight ? rotationRight : rotationDown,
      duration: rotationDuration,
    );

    // [已确认] halfLife === 10^24 → 先 X 再旋转向右；否则先转回向下再 X
    if (reading.pointerPointsRight) {
      _active = x;
      _queued = rot;
    } else {
      _active = rot;
      _queued = x;
    }
  }

  /// 停在当前值。对标 `Animation.stop()`（不发 finish，不启动 then）。
  void stop() {
    _active = null;
    _queued = null;
  }

  void tick(double dt) {
    var remaining = dt;
    while (remaining > 0 && _active != null) {
      final overflow = _active!.advance(remaining);
      _apply(_active!);
      if (!_active!.done) return;
      remaining = overflow;
      _active = _queued;
      _queued = null;
      // then(start(overflow))：下一段立刻用溢出时间开跑 [已确认]
    }
  }

  void _apply(_Tween t) {
    switch (t.kind) {
      case _Kind.x:
        exponent = t.value;
      case _Kind.rot:
        rotation = t.value;
    }
  }

  /// twixt Easing.QUADRATIC_IN_OUT = polynomialEaseInOut(2) [已确认]
  static double quadraticInOut(double t) {
    final x = t.clamp(0.0, 1.0);
    if (x <= 0.5) return 2 * x * x;
    final u = 1 - x;
    return 1 - 2 * u * u;
  }
}

enum _Kind { x, rot }

class _Tween {
  _Tween({
    required this.kind,
    required this.from,
    required this.to,
    required this.duration,
  });

  final _Kind kind;
  final double from;
  final double to;
  final double duration;
  double elapsed = 0;
  bool done = false;

  double get value {
    if (duration <= 0) return to;
    final ratio = (elapsed / duration).clamp(0.0, 1.0);
    return from + (to - from) * HalfLifePointerAnimator.quadraticInOut(ratio);
  }

  /// 推进 [dt] 秒；若结束则返回溢出时间（可交给下一段）。
  double advance(double dt) {
    elapsed += dt;
    if (elapsed >= duration) {
      done = true;
      final overflow = elapsed - duration;
      elapsed = duration;
      return overflow;
    }
    return 0;
  }
}
