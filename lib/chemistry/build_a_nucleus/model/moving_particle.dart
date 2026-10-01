/// 匀速运动粒子基类：position 以 speed 向 destination 推进，到达即停。
///
/// 逐行对标 shred `Particle.step` 的运动模型（Nucleon 与衰变发射粒子共用，
/// 不复制第二套定速算法）。
///
/// 速度语义 [已确认] BANParticle.setAnimationDestination + shred 默认值：
/// - 卡位归位（reconfigure 后）：200 px/s（ShredConstants.DEFAULT_PARTICLE_SPEED，
///   BANParticle 构造不覆盖）
/// - 箭头飞入：固定 0.6 s（速度 = 距离/0.6，consistentTime: true）
/// - 飞回生成器 / 衰变发射：300 px/s（BANConstants.PARTICLE_ANIMATION_SPEED）
library;

import 'dart:math';

class MovingParticle {
  MovingParticle({this.x = 0, this.y = 0, this.speed = 200})
      : destX = x,
        destY = y;

  double x;
  double y;

  /// 运动目的地（对标 Particle.destinationProperty）。
  double destX;
  double destY;

  /// 运动速度 px/s（各路径取值见文件头注释）。
  double speed;

  /// 累计已飞行距离（px）。Be-6 α 特例用：α 飞满 1s×300px/s 时触发后续发射。
  /// [已确认] DecayScreenView.emitAlphaParticle 特例分支的 position 距离判定
  double distanceTraveled = 0;

  bool get isAnimating => x != destX || y != destY;

  /// 同时设定位置与目的地（对标 setPositionAndDestination /
  /// 拖拽开始时的动画取消 [已确认] ParticleView dragListener.start）。
  void setPositionImmediate(double nx, double ny) {
    x = nx;
    y = ny;
    destX = nx;
    destY = ny;
  }

  void setDestination(double dx, double dy) {
    destX = dx;
    destY = dy;
  }

  /// 匀速向 destination 推进 dt 秒（对标 Particle.step 的位移分支）。
  /// 返回 true 表示本步到达目的地（对标 animationEndedEmitter 发射时机）。
  bool stepMotion(double dt) {
    final dx = destX - x;
    final dy = destY - y;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist > dt * speed) {
      final step = speed * dt;
      final angle = atan2(dy, dx);
      x += step * cos(angle);
      y += step * sin(angle);
      distanceTraveled += step;
      // [已确认] 原项目 issue#198：恰好相等也算到达
      return x == destX && y == destY;
    } else if (dist > 0) {
      x = destX;
      y = destY;
      distanceTraveled += dist;
      return true;
    }
    return false;
  }
}
