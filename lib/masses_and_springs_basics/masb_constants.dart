/// Constants from PhET `MassesAndSpringsConstants.js`.
class MasbConstants {
  MasbConstants._();

  static const double defaultSpringLength = 0.5;
  static const double slowSimDtRatio = 8;

  static const double floorY = 0;
  static const double ceilingY = 1.47;
  static const double shelfHeight = 0.02;
  static const double hookHeight = 0.037;
  static const double hookCenter = hookHeight / 2;

  static const double earthGravity = 9.8;
  static const double moonGravity = 1.6;
  static const double jupiterGravity = 24.8;
  static const double planetX = 14.2;

  static const double dampingMin = 0;
  static const double dampingMax = 0.7;
  static const double dampingDefault = 0.3;

  static const double gravityMin = 0;
  static const double gravityMax = 30;
  static const double gravityDefault = 9.8;

  static const double springConstantMin = 3;
  static const double springConstantMax = 12;
  static const double springConstantDefault = 6;

  static const double leftSpringX = 1.0;
  static const double rightSpringX = 1.3;
  static const double springX = 1.2;

  static const double grabbingDistance = 0.1;
  static const double releaseDistance = 0.12;

  static const double massDensity = 80;
  static const double massHeightRatio = 2.5;
  static const double massRadiusScaling = 4;

  /// ScreenView layoutBounds (PhET joist default for this era).
  static const double layoutWidth = 768;
  static const double layoutHeight = 504;

  /// Model→view px/m. PhET SpringScreenView uses ~397; we use a value that
  /// still fits layoutBounds with CEILING_Y=1.47 (max ≈ originY/1.47).
  static const double mvtScale = 320;
  static const double mvtOffsetX = 48;
  static const double mvtOffsetY = 485;

  /// PhET-like cream simulation background (not gray card / not scaffold white).
  static const int simBackgroundArgb = 0xFFFFF8EE;
}
