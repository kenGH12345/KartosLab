import '../vector_addition_constants.dart';

/// Angle convention conversions — mirrors PhET `VectorAdditionUtils.ts`.
///
/// Model / Polar base ground truth remains **signed** degrees in [-180, 180].
/// Display unsigned uses (0, 360] mapping with **0 → 0** (not 360).
class AngleConventionUtils {
  AngleConventionUtils._();

  /// PhET `signedToUnsignedDegrees`.
  /// Note: 0 maps to 0, *not* 360.
  static double signedToUnsignedDegrees(double signedDegrees) {
    assert(
      signedDegrees >= VectorAdditionConstants.signedAngleMin &&
          signedDegrees <= VectorAdditionConstants.signedAngleMax,
      'invalid signedDegrees: $signedDegrees',
    );
    return signedDegrees >= 0 ? signedDegrees : signedDegrees + 360;
  }

  /// PhET `unsignedToSignedDegrees`.
  /// Note: 0 and 360 both map to 0 — sim never displays 360.
  static double unsignedToSignedDegrees(double unsignedDegrees) {
    assert(
      unsignedDegrees >= 0 && unsignedDegrees <= 360,
      'invalid unsignedDegrees: $unsignedDegrees',
    );
    return unsignedDegrees <= 180 ? unsignedDegrees : unsignedDegrees - 360;
  }

  static int signedToUnsignedInt(int signed) =>
      signedToUnsignedDegrees(signed.toDouble()).round();

  static int unsignedToSignedInt(int unsigned) =>
      unsignedToSignedDegrees(unsigned.toDouble()).round();
}
