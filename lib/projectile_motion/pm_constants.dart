import 'package:flutter/material.dart';

/// PhET `ProjectileMotionConstants.ts` 的 Flutter 等价。
/// 所有数值均来自本地源码 projectile-motion 1.1.0-dev.41。
abstract final class PmConstants {
  // ── 布局（joist 默认 layoutBounds，本 sim 未覆盖）─────────────────────
  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;

  /// VIEW_ORIGIN，屏坐标 (Constants:44)
  static const Offset viewOrigin = Offset(70, 510);

  /// DEFAULT_SCALE = 30 px/m (ScreenView:55)
  static const double defaultScale = 30;

  // ── 炮弹默认（Constants:47-49）──────────────────────────────────────
  static const double cannonballMass = 17.6;
  static const double cannonballDiameter = 0.18;
  static const double cannonballDragCoefficient = 0.47;

  // ── 容量约束（Constants:51-59）──────────────────────────────────────
  static const int maxNumberOfTrajectories = 10;

  // ── 参数范围（Constants:61-72）──────────────────────────────────────
  static const double cannonHeightMin = 0;
  static const double cannonHeightMax = 15;
  /// Drag-follow is continuous; pointer-up snaps to this step (meters).
  static const double cannonHeightSnap = 0.1;
  static const double cannonAngleMin = -90;
  static const double cannonAngleMax = 90;
  static const double launchVelocityMin = 0;
  static const double launchVelocityMax = 30;
  static const double projectileMassMin = 0.01;
  static const double projectileMassMax = 5000;
  static const double projectileDiameterMin = 0.01;
  static const double projectileDiameterMax = 3;
  static const double dragCoefficientMin = 0.04;
  static const double dragCoefficientMax = 1.2;
  static const double altitudeMin = 0;
  static const double altitudeMax = 5000;
  static const double gravityMin = 1;
  static const double gravityMax = 20;

  // ── 轨迹（Constants:75-91）──────────────────────────────────────────
  static const Color airResistanceOnPathColor = Color.fromRGBO(252, 40, 252, 1);
  static const Color airResistanceOffPathColor = Colors.blue;
  static const double pathWidth = 2;
  static const double slowMotionFactor = 0.33;

  /// TIME_PER_DATA_POINT = 12ms → 物理恒定 dt（Constants:86）
  static const double timePerDataPoint = 0.012;
  static const double timePerMinorDot = 0.1; // 100 ms
  static const double timePerMajorDot = 1.0; // 1000 ms
  static const double smallDotRadius = 1.65;
  static const double largeDotRadius = 3.3;

  // ── 轨迹透明度（TrajectoryNode:28-36, 165-180）───────────────────────
  static const double pathMinOpacity = 0.1;
  static const double pathMaxOpacity = 1.0;
  static const double dotsMinOpacity = 0.1;
  static const double dotsMaxOpacity = 0.5;

  static double pathOpacityForRank(int rank, [int maxTrajectories = maxNumberOfTrajectories]) {
    final strength = (maxTrajectories - rank) / maxTrajectories;
    final v = pathMinOpacity + strength * (pathMaxOpacity - pathMinOpacity);
    return v < pathMinOpacity ? pathMinOpacity : v;
  }

  static double dotsOpacityForRank(int rank, [int maxTrajectories = maxNumberOfTrajectories]) {
    final strength = (maxTrajectories - rank) / maxTrajectories;
    final v = dotsMinOpacity + strength * (dotsMaxOpacity - dotsMinOpacity);
    return v < dotsMinOpacity ? dotsMinOpacity : v;
  }

  // ── 靶（Constants:137-140）──────────────────────────────────────────
  static const double targetXDefault = 15;
  static const double targetWidth = 3;
  static const double targetHeight = 0.6;

  // ── 向量箭头标量（无物理单位，ProjectileNode / FreeBodyDiagram）───────
  static const double velocityVectorScalar = 15;
  static const double accelerationVectorScalar = 15;
  static const double forceVectorScalar = 3;

  // ── 大炮视图（CannonNode:48-53）─────────────────────────────────────
  static const double cannonLength = 4; // m，仅用于视图缩放
  static const double cylinderDistanceFromOrigin = 1.3; // m
  static const double heightLeaderLineX = -1.5; // m
  static const double crosshairLength = 120; // view px

  /// height<4 时各高度段的角度下限（CannonNode:60）
  static const List<double> angleRangeMins = [5, -5, -20, -40];

  // ── David 参照（Model:220-221）──────────────────────────────────────
  static const double davidHeight = 2; // m
  static const Offset davidPosition = Offset(7, 0); // m

  // ── Zoom（Constants:187-189）────────────────────────────────────────
  static const double minZoom = 0.25;
  static const double maxZoom = 2;
  static const double defaultZoom = 1;

  // ── 重力默认（phet-core PhysicalConstants.GRAVITY_ON_EARTH）──────────
  static const double gravityOnEarth = 9.81;

  // ── Flatirons 彩蛋海拔区间（ScreenView:447-449）──────────────────────
  static const double flatironsAltitudeMin = 1500;
  static const double flatironsAltitudeMax = 1700;

  // ── DataProbe（DataProbe.ts:24）──────────────────────────────────────
  static const double dataProbeSensingRadius = 0.2; // m（÷zoom）

  // ── Muzzle flash（CannonNode:70-74）──────────────────────────────────
  static const double muzzleFlashDuration = 0.4; // s

  /// PhET `PhetFont(14)` / `toFixedNumber` 字符串化。
  static const String uiFontFamily = 'Arial';

  static const TextStyle uiText = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 14,
    color: Color(0xFF000000),
    decoration: TextDecoration.none,
  );

  /// `dot/js/util/toFixedNumber` 再转字符串：四舍五入到 [decimals] 位后去掉多余 0。
  static String toFixedNumber(double v, int decimals) {
    final n = double.parse(v.toStringAsFixed(decimals));
    if (n == n.roundToDouble()) return n.round().toString();
    return n.toString();
  }
}
