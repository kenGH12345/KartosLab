import 'dart:math' as math;
import 'dart:ui' show Offset;

import '../../clb_constants.dart';

/// Simple XYZ triple for MVT / circuit geometry (model meters).
class ModelVector3 {
  const ModelVector3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  ModelVector3 operator +(ModelVector3 o) =>
      ModelVector3(x + o.x, y + o.y, z + o.z);

  ModelVector3 operator -(ModelVector3 o) =>
      ModelVector3(x - o.x, y - o.y, z - o.z);

  ModelVector3 plusXYZ(double dx, double dy, double dz) =>
      ModelVector3(x + dx, y + dy, z + dz);
}

/// 3D model → 2D view — `scenery-phet/.../YawPitchModelViewTransform3.js`
///
/// Model axes: +x right, +y down, +z away from viewer (PhET comment).
class YawPitchMvt {
  YawPitchMvt({
    this.scale = ClbConstants.mvtScale,
    this.pitch = ClbConstants.mvtPitchRad,
    this.yaw = ClbConstants.mvtYawRad,
  });

  final double scale;
  final double pitch;
  final double yaw;

  /// `modelToViewPosition` — js:65-69
  Offset modelToViewPosition(double x, double y, double z) {
    // setPolar(z * sin(pitch), yaw) → (r·cos(yaw), r·sin(yaw))
    final r = z * math.sin(pitch);
    final vx = x + r * math.cos(yaw);
    final vy = y + r * math.sin(yaw);
    return Offset(vx * scale, vy * scale);
  }

  /// `modelToViewXYZ` — js:81-83
  Offset modelToViewXYZ(double x, double y, double z) =>
      modelToViewPosition(x, y, z);

  Offset modelToViewVector3(ModelVector3 p) =>
      modelToViewPosition(p.x, p.y, p.z);

  /// `modelToViewDelta` — js:92-95
  Offset modelToViewDelta(double x, double y, double z) {
    final origin = modelToViewPosition(0, 0, 0);
    return modelToViewPosition(x, y, z) - origin;
  }

  /// `modelToViewDeltaXYZ` — js:107-108
  Offset modelToViewDeltaXYZ(double xDelta, double yDelta, double zDelta) =>
      modelToViewDelta(xDelta, yDelta, zDelta);

  /// `viewToModelXY` — js:157-158 (z = 0)
  ModelVector3 viewToModelXY(double x, double y) =>
      ModelVector3(x / scale, y / scale, 0);

  /// Inverse of the 2D scale part for planar deltas.
  Offset viewToModelDeltaXY(double dx, double dy) =>
      Offset(dx / scale, dy / scale);

  /// Model shapes in the xy plane have no depth — `modelToViewShape` (scale only).
  Offset modelToViewShapeXY(double x, double y) => Offset(x * scale, y * scale);
}
