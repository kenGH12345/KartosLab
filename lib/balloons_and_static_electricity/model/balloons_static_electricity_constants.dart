import 'base_vec2.dart';

/// Charge visibility modes — PhET `BASEModel.showChargesProperty`.
enum ShowCharges {
  allCharges,
  noCharges,
  chargeDifferences,
}

/// Constants from PhET `BASEConstants.ts` / `BalloonModel.ts` / `WallModel.ts`.
abstract final class BaseConstants {
  static const double width = 768;
  static const double height = 504;

  /// Seconds → milliseconds scale used in [BalloonModel.step].
  static const double msScaleFactor = 1000;

  /// Max electrons a balloon can hold (sweater provides 57 transferable −).
  static const int maxBalloonCharge = 57;

  /// Used for wall↔balloon force (polarization / inducingCharge).
  static const double coulombsLawConstant = 10000;

  static const double wallWidth = 80;

  static const double balloonWidth = 134;
  static const double balloonHeight = 222;

  /// `BalloonModel.FORCE_CONSTANT`.
  static const double forceConstant = 0.05;

  /// Rolling velocity sample count for charge pickup.
  static const int velocityArrayLength = 5;

  /// Wall minus displacement force threshold for `inducingCharge`.
  static const double forceMagnitudeThreshold = 2;

  /// Special wall-attraction fright factor.
  static const double wallAttractionFright = 0.003;

  /// Cap on sweater+other balloon force magnitude.
  static const double maxForceMagnitude = 1e-2;

  /// Point charge radius (`PointChargeModel.RADIUS`).
  static const double pointChargeRadius = 8;

  /// `PointChargeModel.CHARGE` = −100/57 for Java parity.
  static const double pointCharge = -1.754;

  /// Critical balloon-center X when touching the wall (`PlayAreaMap.X_POSITIONS.AT_WALL`).
  static const double atWallCenterX = 621;

  static const BaseVec2 yellowInitialPosition = BaseVec2(440, 100);
  static const BaseVec2 greenInitialPosition = BaseVec2(380, 130);
  static const BaseVec2 sweaterPosition = BaseVec2(25, 20);

  static const double sweaterWidth = 305;
  static const double sweaterHeight = 385;

  /// Wall left edge X = WIDTH − wallWidth.
  static const double wallX = width - wallWidth; // 688

  /// Drag bounds for balloon upper-left when wall is visible.
  static const double dragMaxXWithWall = width - wallWidth - balloonWidth; // 554
  static const double dragMaxXWithoutWall = width - balloonWidth; // 634
  static const double dragMaxY = height - balloonHeight; // 282

  static const int wallNumX = 3;
  static const int wallNumY = 18;
  static const int wallChargePairCount = wallNumX * wallNumY; // 54
}
