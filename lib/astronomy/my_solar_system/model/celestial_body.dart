/// Celestial body. Live state owned by the controller.
///
/// Radius: [Kepler二次] `Body.massToRadius`.
/// Overlap: [临时] `|Δr| <= r1+r2`（`isOverlapping` 在 common）。
library;

import 'dart:math' as math;
import 'dart:ui';

import '../my_solar_system_constants.dart';
import 'body_info.dart';
import 'mss_vec.dart';

class CelestialBody {
  CelestialBody({
    required this.index,
    required this.mass,
    required this.position,
    required this.velocity,
    required this.color,
    this.isActive = true,
  });

  final int index;
  double mass;
  MssVec position;
  MssVec velocity;
  MssVec acceleration = MssVec.zero();
  MssVec gravityForce = MssVec.zero();
  Color color;
  bool isActive;
  final List<MssVec> pathPoints = [];

  /// [Kepler二次] Body.massToRadius
  double get radius => massToRadius(mass);

  static double massToRadius(double mass) {
    return math.max(
      MySolarSystemConstants.minBodyRadius,
      MySolarSystemConstants.massToRadiusCoeff *
          math.pow(mass, 1 / 3).toDouble(),
    );
  }

  /// [临时] 替代 `Body.isOverlapping`。
  bool isOverlapping(CelestialBody other) {
    if (!isActive || !other.isActive) return false;
    final dx = position.x - other.position.x;
    final dy = position.y - other.position.y;
    final limit = radius + other.radius;
    return dx * dx + dy * dy <= limit * limit;
  }

  void clearPath() => pathPoints.clear();

  void addPathPoint() {
    pathPoints.add(position.copy());
    final extra =
        pathPoints.length - MySolarSystemConstants.maxPathPoints;
    if (extra > 0) {
      pathPoints.removeRange(0, extra);
    }
  }

  void applyInfo(BodyInfo info) {
    mass = info.mass;
    position = info.position.copy();
    velocity = info.velocity.copy();
    isActive = info.isActive;
    acceleration = MssVec.zero();
    gravityForce = MssVec.zero();
    clearPath();
  }

  /// [TEMPORARY] Body.isOffscreen in common missing.
  bool get isOffscreen =>
      position.magnitude > MySolarSystemConstants.offscreenRadiusAu;

  /// [TEMPORARY] Body.preventCollision — nudge +x until clear of [others].
  void preventCollision(List<CelestialBody> others) {
    var guard = 0;
    while (others.any(isOverlapping) &&
        guard++ < MySolarSystemConstants.preventCollisionMaxIterations) {
      position.x +=
          radius * 2 + MySolarSystemConstants.preventCollisionNudgeAu;
    }
  }
}
