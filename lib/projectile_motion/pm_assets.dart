/// Projectile Motion 原版 asset 路径映射（对齐 assets/simulations/projectile_motion）。
/// 详见 requirements/req-projectile-motion/ASSET_MAP.md
abstract final class PmAssets {
  static const String _base = 'assets/simulations/projectile_motion';

  // ── 炮 ──
  static const String cannonBarrel = '$_base/cannonBarrel.png';
  static const String cannonBarrelTop = '$_base/cannonBarrelTop.png';
  static const String cannonBaseTop = '$_base/cannonBaseTop.png';
  static const String cannonBaseBottom = '$_base/cannonBaseBottom.png';

  // ── 抛体（mipmaps）──
  static const String tankShell = '$_base/tankShell.png';
  static const String cannonball = '$_base/baseball.png'; // 圆形，程序绘制
  static const String baseball = '$_base/baseball.png';
  static const String football = '$_base/football.png';

  // ── 抛体飞行/落地态 ──
  static const String pumpkinFlying = '$_base/pumpkin1.png';
  static const String pumpkinLanded = '$_base/pumpkin2.png';
  static const String carFlying = '$_base/car1.png';
  static const String carLanded = '$_base/car2.png';
  static const String humanFlying = '$_base/human1.png';
  static const String humanLanded = '$_base/human2.png';
  static const String pianoFlying = '$_base/piano1.png';
  static const String pianoLanded = '$_base/piano2.png';

  static const String uncenteredHuman1 = '$_base/uncenteredHuman1.png';

  // ── 背景（images/）──
  static const String david = '$_base/david.png';
  static const String flatirons = '$_base/flatirons.png';

  // ── 按钮 ──
  static const String fireButton = '$_base/fireButton.png';
  static const String fireMultipleButton = '$_base/fireMultipleButton.png';

  // ── 测量工具（scenery-phet MeasuringTapeNode）──
  static const String measuringTape = '$_base/measuringTape.png';

  // ── Tab 图标 ──
  static const String introScreenIcon = '$_base/uncenteredHuman1.png';
}
