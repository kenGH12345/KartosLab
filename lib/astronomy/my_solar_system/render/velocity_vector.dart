/// Model ↔ view conversion for velocity arrows.
///
/// [KEPLER-SECONDARY] `VELOCITY_TO_VIEW_MULTIPLIER`；长度随 zoom 变化是因为 MVT.scale。
library;

import '../model/mss_vec.dart';
import '../my_solar_system_constants.dart';

/// Arrow tip in model space: `position + velocity * VELOCITY_TO_VIEW_MULTIPLIER`.
MssVec velocityTipModel(
  MssVec position,
  MssVec velocity, [
  double multiplier = MySolarSystemConstants.velocityToViewMultiplier,
]) {
  return MssVec(
    position.x + velocity.x * multiplier,
    position.y + velocity.y * multiplier,
  );
}

/// Inverse of [velocityTipModel].
MssVec velocityFromTip(
  MssVec position,
  MssVec tipModel, [
  double multiplier = MySolarSystemConstants.velocityToViewMultiplier,
]) {
  return MssVec(
    (tipModel.x - position.x) / multiplier,
    (tipModel.y - position.y) / multiplier,
  );
}

/// [KEPLER-SECONDARY] `minimumMagnitude` + `snapToZero: false`.
MssVec constrainVelocityMagnitude(
  MssVec velocity, [
  double minMagnitude = MySolarSystemConstants.velocityMinMagnitude,
]) {
  final mag = velocity.magnitude;
  if (mag >= minMagnitude) return velocity.copy();
  if (mag == 0) {
    return MssVec(0, minMagnitude);
  }
  final s = minMagnitude / mag;
  return MssVec(velocity.x * s, velocity.y * s);
}

/// [KEPLER-SECONDARY] VectorNode offscale when |v| < minimumMagnitude.
/// Kept replaceable when solar-system-common is available.
bool isVelocityVectorOffscale(
  MssVec velocity, [
  double minMagnitude = MySolarSystemConstants.velocityMinMagnitude,
]) {
  return velocity.magnitude < minMagnitude;
}
