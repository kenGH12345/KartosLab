/// PhET MotionConstants — js/motion/MotionConstants.ts
class MotionConstants {
  MotionConstants._();

  /// Model meters → view pixels for background translation.
  static const double positionScale = 10;

  /// Max friction coefficient (unitless; can exceed 1 by design).
  static const double maxFriction = 0.5;

  /// Max speed (m/s) before pusher falls.
  static const double maxSpeed = 40;

  static const double gravity = 9.8;

  /// Kinetic friction magnitude factor vs μmg (PhET MotionModel.getFrictionForce).
  static const double kineticFrictionFactor = 0.75;

  static const double appliedForceMin = -500;
  static const double appliedForceMax = 500;

  static const double velocityThreshold = 1e-12;

  /// Manual step and SimulationClock fps assumption.
  static const double dt = 1 / 60;

  static const int maxStack = 3;

  /// Default μ on Friction / Acceleration screens.
  static const double defaultFrictionHalf = maxFriction / 2; // 0.25

  static const double pusherHomePosition = -16; // m

  /// Pusher stand-up delay after falling (seconds).
  static const double fallenStandUpDelay = 2.0;
}

/// PhET Net Force constants — js/netforce/model/NetForceModel.ts + Cart.ts
class NetForceConstants {
  NetForceConstants._();

  static const double knotSpacing = 80;
  static const double blueKnotOffset = 62;
  static const double redKnotOffset = 680;
  static const double gameLength = 458; // stopper placement
  static const double widthToWheel = 55;
  static const double winThreshold = gameLength - widthToWheel; // 403

  /// Velocity integration coefficient (no explicit cart mass).
  static const double velocityCoeff = 0.003;

  /// Position integration coefficient.
  static const double positionCoeff = 60.0;

  static const double pullerForceSmall = 50;
  static const double pullerForceMedium = 100;
  static const double pullerForceLarge = 150;

  static const int knotsPerSide = 4;
  static const double knotY = 285;

  static const double speedMax = 6;
  static const double forceDisplayMax = 350;
}

/// PhET roundSymmetric — used so friction/applied share precision.
double roundSymmetric(double n) =>
    n < 0 ? -(-n).roundToDouble() : n.roundToDouble();
