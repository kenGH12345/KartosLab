import 'dart:math' as math;

import '../bending_light_constants.dart';
import 'bl_vec2.dart';
import 'enums.dart';
import 'laser_color.dart';

/// Laser model (`Laser.ts`).
class Laser {
  Laser({
    required double Function() wavelengthGetter,
    required double distanceFromPivot,
    required double angle,
    required this.topLeftQuadrant,
  }) : _wavelengthGetter = wavelengthGetter {
    pivot = BlVec2.zero;
    emissionPoint = BlVec2.polar(distanceFromPivot, angle);
    _initialPivot = pivot;
    _initialEmission = emissionPoint;
  }

  final double Function() _wavelengthGetter;
  final bool topLeftQuadrant;

  late BlVec2 pivot;
  late BlVec2 emissionPoint;
  late BlVec2 _initialPivot;
  late BlVec2 _initialEmission;

  bool on = false;
  bool wave = false;
  ColorModeEnum colorMode = ColorModeEnum.singleColor;

  LaserColor get color => LaserColor(_wavelengthGetter());

  void reset() {
    pivot = _initialPivot;
    emissionPoint = _initialEmission;
    on = false;
    wave = false;
    colorMode = ColorModeEnum.singleColor;
  }

  void translate(double deltaX, double deltaY) {
    // Order matters (#221): pivot then emission
    pivot = pivot.plusXY(deltaX, deltaY);
    emissionPoint = emissionPoint.plusXY(deltaX, deltaY);
  }

  BlVec2 getDirectionUnitVector() {
    final magnitude = pivot.distance(emissionPoint);
    if (magnitude == 0) return BlVec2.zero;
    return BlVec2(
      (pivot.x - emissionPoint.x) / magnitude,
      (pivot.y - emissionPoint.y) / magnitude,
    );
  }

  void setAngle(double angle) {
    final dist = pivot.distance(emissionPoint);
    emissionPoint = BlVec2(
      dist * math.cos(angle) + pivot.x,
      dist * math.sin(angle) + pivot.y,
    );
  }

  /// `direction.angle + π`
  double getAngle() => getDirectionUnitVector().angle + math.pi;

  double getDistanceFromPivot() => pivot.distance(emissionPoint);

  double getWavelength() => color.wavelength;

  double getFrequency() =>
      BendingLightConstants.speedOfLight / getWavelength();

  void setWave(bool value) {
    wave = value;
    if (wave &&
        getAngle() > BendingLightConstants.maxAngleInWaveMode &&
        topLeftQuadrant) {
      setAngle(BendingLightConstants.maxAngleInWaveMode);
    }
  }
}
