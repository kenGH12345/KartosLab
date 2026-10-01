import 'dart:math' as math;

/// Normalizes [angle] into `[minAngle, minAngle + 2π)`.
/// Source: `js/common/model/normalizeAngle.ts`
double normalizeAngle(double angle, [double minAngle = 0]) {
  const rangeLength = 2 * math.pi;
  final shifted = angle - minAngle;
  var normalized = shifted % rangeLength;
  if (normalized < 0) {
    normalized = shifted + rangeLength;
    // `%` of negative in Dart can still be negative after one adjust
    // if shifted was already in weird range — match PhET with second pass:
    normalized = normalized % rangeLength;
    if (normalized < 0) normalized += rangeLength;
  }
  if (normalized == rangeLength) {
    normalized = 0;
  }
  return normalized + minAngle;
}
