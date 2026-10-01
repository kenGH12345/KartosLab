import '../model/bl_vec2.dart';

/// Intersection of a ray with a prism surface (`Intersection.ts`).
class Intersection {
  const Intersection(this.unitNormal, this.point);

  final BlVec2 unitNormal;
  final BlVec2 point;
}

/// Immutable propagation ray for prisms (`ColoredRay.ts`).
class ColoredRay {
  ColoredRay({
    required this.tail,
    required this.directionUnitVector,
    required this.power,
    required this.wavelength,
    required this.mediumIndexOfRefraction,
    required this.frequency,
  });

  final BlVec2 tail;
  final BlVec2 directionUnitVector;
  final double power;

  /// Wavelength in meters (in current medium context as stored by PhET).
  final double wavelength;
  final double mediumIndexOfRefraction;
  final double frequency;

  /// Vacuum wavelength from frequency: c/f
  double getBaseWavelength(double speedOfLight) => speedOfLight / frequency;
}
