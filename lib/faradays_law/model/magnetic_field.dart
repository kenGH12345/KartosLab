import 'dart:ui' show Offset;

import '../faradays_law_constants.dart';
import 'magnet_orientation.dart';

/// Calibrated B at a coil center — `Coil.updateMagneticField`.
///
/// Near field (`r² < 1`): `B = sign * 2`
/// Far field: `B = sign * (3·dx² − r²) / r⁴`
/// where distances are normalized by [FaradaysLawConstants.nearFieldRadius].
double magneticFieldAtCoil({
  required Offset coilPosition,
  required Offset magnetPosition,
  required MagnetOrientation orientation,
}) {
  final sign = orientation.magneticFieldSign;
  final near = FaradaysLawConstants.nearFieldRadius;
  final dxWorld = magnetPosition.dx - coilPosition.dx;
  final dyWorld = magnetPosition.dy - coilPosition.dy;
  final rSquared = (dxWorld * dxWorld + dyWorld * dyWorld) / (near * near);

  if (rSquared < 1) {
    return sign * 2;
  }

  final dx = dxWorld / near;
  return sign * (3 * dx * dx - rSquared) / (rSquared * rSquared);
}
