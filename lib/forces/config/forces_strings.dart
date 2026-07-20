/// 力与运动模块的字符串常量
/// 所有用户可见文本集中在此，便于国际化
class ForcesStrings {
  ForcesStrings._();

  // ── 屏幕标题 ──
  static const String screenNetForce = '合力 (Net Force)';
  static const String screenMotion = '运动';
  static const String screenFriction = '摩擦';
  static const String screenAcceleration = '加速度';

  // ── ForcesHome ──
  static const String forcesHomeTitle = '力与运动';
  static const String selectExperiment = '选择一个实验';
  static const String netForceCard = '合力';
  static const String netForceSubtitle = '拔河比赛\n力的合成与平衡';
  static const String motionCard = '运动';
  static const String motionSubtitle = '力、质量\n与加速度';
  static const String frictionCard = '摩擦';
  static const String frictionSubtitle = '摩擦力\n对运动的影响';
  static const String accelCard = '加速度';
  static const String accelSubtitle = '测量加速度\n探索 F=ma';

  // ── 首页按钮 ──
  static const String homeButtonLabel = '力与运动 知识点';

  // ── NetForceScreen ──
  static const String netForceFilter = '合力';
  static const String netForceValues = '值';
  static const String netForceSpeed = '速度';
  static const String netForcePause = '暂停';
  static const String netForceGo = 'Go!';
  static const String netForceReturn = 'Return';
  static const String netForceReset = '重置';
  static const String netForceWinTemplate = '{side} 获胜!'; // side=红队/蓝队

  // ── MotionScreen 控制面板 ──
  static const String motionForce = '力';
  static const String motionSum = '合力';
  static const String motionValues = '值';
  static const String motionMass = '质量';
  static const String motionSpeed = '速度';
  static const String frictionLabel = '摩擦: ';
  static const String massUnit = 'kg';
  static const String accelLabel = 'a = {value} m/s²';
}
