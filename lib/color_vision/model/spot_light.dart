import 'dart:ui';

/// A spotlight source that emits photons of a specific color.
///
/// [color] is the light color (e.g. red, green, blue, or white).
/// [intensity] ranges 0-100 and controls photon emission count.
class SpotLight {
  final double x;
  final double y;
  final Color color;
  final double intensity; // 0-100

  const SpotLight({
    required this.x,
    required this.y,
    required this.color,
    this.intensity = 100,
  });

  SpotLight copyWith({double? x, double? y, Color? color, double? intensity}) {
    return SpotLight(
      x: x ?? this.x,
      y: y ?? this.y,
      color: color ?? this.color,
      intensity: intensity ?? this.intensity,
    );
  }
}
