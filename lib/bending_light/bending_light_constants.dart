/// Constants from PhET `BendingLightConstants.ts` / `BendingLightModel.ts`.
/// Wavelengths in meters unless noted as nm.
class BendingLightConstants {
  BendingLightConstants._();

  static const double speedOfLight = 2.99792458e8;
  static const double wavelengthRed = 650e-9; // m · CHARACTERISTIC_LENGTH
  static const double characteristicLength = wavelengthRed;

  /// nm — VisibleColor.MIN_WAVELENGTH in scenery-phet (380).
  static const double laserMinWavelengthNm = 380;
  static const double laserMaxWavelengthNm = 700;

  static const double maxAngleInWaveMode = 3.0194; // rad

  static const double defaultLaserDistanceFromPivot = 9.225e-6;

  /// Intro beam length when creating tip from polar (`IntroModel` BEAM_LENGTH).
  static const double beamLength = 1e-3;

  /// Prisms: unbounded ray segment length when no hit (`PrismsModel` 2E-4).
  static const double prismUnboundedRayLength = 2e-4;

  static const int maxLightRaySteps = 50;

  static const double prismNodeAlpha = 0.5;

  /// `LightRay.RAY_WIDTH` — view stroke is `modelToViewDeltaX` of this.
  static const double rayWidth = 1.5992063492063494e-7;

  static const double modelWidth = characteristicLength * 62;
  static const double modelHeight = modelWidth * 0.7;

  /// `_.range(400, 700, 10)` — excludes 700.
  static List<double> get whiteLightWavelengthsNm =>
      [for (var w = 400; w < 700; w += 10) w.toDouble()];

  static const double layoutBoundsWidth = 834;
  static const double layoutBoundsHeight = 504;
}
