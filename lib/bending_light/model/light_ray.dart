import 'dart:math' as math;

import '../bending_light_constants.dart';
import 'bl_vec2.dart';
import 'enums.dart';

/// One straight ray segment (`LightRay.ts`) — model/physics only.
class LightRay {
  LightRay({
    required this.trapeziumWidth,
    required this.tail,
    required this.tip,
    required this.indexOfRefraction,
    required this.wavelength,
    required this.wavelengthInVacuum,
    required this.powerFraction,
    required this.colorArgb,
    required this.waveWidth,
    required this.numWavelengthsPhaseOffset,
    required this.extend,
    required this.extendBackwards,
    required this.laserView,
    required this.rayType,
  }) {
    assert(
      wavelengthInVacuum >= 300 && wavelengthInVacuum <= 900,
      'wavelength out of range',
    );
  }

  final double trapeziumWidth;
  final BlVec2 tip;
  final BlVec2 tail;
  final double indexOfRefraction;

  /// Wavelength in medium (meters).
  final double wavelength;

  /// Vacuum wavelength in **nm**.
  final double wavelengthInVacuum;
  final double powerFraction;
  final int colorArgb;
  final double waveWidth;
  final double numWavelengthsPhaseOffset;
  final bool extend;
  final bool extendBackwards;
  final LaserViewEnum laserView;
  final String rayType;

  double time = 0;

  static const double rayWidth = 1.5992063492063494e-7;

  void setTime(double t) => time = t;

  double getSpeed() =>
      BendingLightConstants.speedOfLight / indexOfRefraction;

  double getLength() => tip.distance(tail);

  BlVec2 toVector() => BlVec2(tip.x - tail.x, tip.y - tail.y);

  BlVec2 getUnitVector() {
    final m = tip.distance(tail);
    if (m == 0) return BlVec2.zero;
    return BlVec2((tip.x - tail.x) / m, (tip.y - tail.y) / m);
  }

  double getAngle() => math.atan2(tip.y - tail.y, tip.x - tail.x);

  double getNumberOfWavelengths() => getLength() / wavelength;

  double getFrequency() => getSpeed() / wavelength;

  double getAngularFrequency() => getFrequency() * math.pi * 2;

  double getPhaseOffset() =>
      getAngularFrequency() * time - 2 * math.pi * numWavelengthsPhaseOffset;

  /// `k·x − ω·t + 2π·numWavelengthsPhaseOffset`
  double getCosArg(double distanceAlongRay) {
    final w = getAngularFrequency();
    final k = 2 * math.pi / wavelength;
    return k * distanceAlongRay - w * time + 2 * math.pi * numWavelengthsPhaseOffset;
  }

  BlVec2 getVelocityVector() => getUnitVector() * getSpeed();

  /// Distance-to-segment test for ray mode; wave uses [waveWidth] half-width.
  bool contains(BlVec2 position, {required bool waveMode}) {
    final a = tail;
    final b = tip;
    final ab = b - a;
    final ap = position - a;
    final abLen2 = ab.magnitudeSquared;
    if (abLen2 == 0) return position.distance(a) < 1e-14;
    var t = ap.dot(ab) / abLen2;
    t = t.clamp(0.0, 1.0);
    final closest = a + ab * t;
    final dist2 = position.distanceSquared(closest);
    if (waveMode) {
      final half = waveWidth / 2;
      return dist2 <= half * half;
    }
    return dist2 < 1e-14;
  }

  /// Approximate sensor hit: circle of radius [sensorRadius] at [sensorCenter].
  bool hitsSensorCircle(BlVec2 sensorCenter, double sensorRadius) {
    // Closest point on segment to center
    final a = tail;
    final b = tip;
    final ab = b - a;
    final ap = sensorCenter - a;
    final abLen2 = ab.magnitudeSquared;
    var t = abLen2 == 0 ? 0.0 : ap.dot(ab) / abLen2;
    t = t.clamp(0.0, 1.0);
    final closest = a + ab * t;
    return closest.distance(sensorCenter) <= sensorRadius;
  }
}
