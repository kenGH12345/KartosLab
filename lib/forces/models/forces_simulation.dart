/// 核心 1D 牛顿力学模拟引擎
/// 被 Motion/Friction/Acceleration 三个屏幕共用
class ForcesSimulation {
  static const double maxSpeed = 40;   // m/s
  static const double maxFriction = 0.5;
  static const double gravity = 9.8;   // m/s²

  ForcesSimulation({this.mass = 50});

  double mass;              // kg
  double position = 0;      // m (1D)
  double velocity = 0;      // m/s
  double appliedForce = 0;  // N (-500 ~ +500)
  double frictionCoeff = 0; // 0 ~ 0.5

  double get frictionForce => _calcFriction();
  double get netForce => appliedForce + frictionForce;
  double get acceleration => mass > 0 ? netForce / mass : 0;
  double get speed => velocity.abs();

  double _calcFriction() {
    if (frictionCoeff == 0 || mass <= 0) return 0;
    // 最大静摩擦力 = μs * N = μs * mg
    // 动摩擦力 = μk * N，通常 μk ≈ 0.8 * μs
    final staticMax = frictionCoeff * mass * gravity;
    final kineticMax = staticMax * 0.8;

    if (speed < 1e-12) {
      // ── 静摩擦（静止状态）──
      // 静摩擦力大小与施加力相等、方向相反，直到超过 μs*mg
      if (appliedForce.abs() <= staticMax) return -appliedForce;
      // 施加力超过最大静摩擦 → 开始滑动，切换到动摩擦
      // 动摩擦力方向与即将发生的运动方向相反
      return -appliedForce.sign * kineticMax;
    }
    // ── 动摩擦（滑动状态）──
    // 动摩擦力方向与速度方向相反，大小 = μk*mg
    // 注意：动摩擦力大小与施加力无关，恒为 μk*mg
    return -velocity.sign * kineticMax;
  }

  void tick(double dt) {
    if (mass <= 0) return;
    final fric = _calcFriction();
    final fNet = appliedForce + fric;
    final a = fNet / mass;
    velocity += a * dt;
    if (velocity.abs() > maxSpeed) velocity = maxSpeed * velocity.sign;
    if (velocity.abs() < 1e-12) velocity = 0;
    position += velocity * dt;
    // 防回弹
    if ((velocity > 0 && fric.abs() > 0 && (velocity + a * dt).sign != velocity.sign)) {
      velocity = 0;
    }
  }

  void reset() { position = 0; velocity = 0; appliedForce = 0; }
}
