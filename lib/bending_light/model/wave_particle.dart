import 'dart:math' as math;

import '../physics/wave_math.dart';
import 'bl_vec2.dart';
import 'light_ray.dart';

/// One canvas wave particle (`WaveParticle.ts` + `propagateParticles`).
class WaveParticleState {
  const WaveParticleState({
    required this.position,
    required this.angle,
    required this.width,
    required this.height,
    required this.colorArgb,
  });

  final BlVec2 position;
  final double angle;
  final double width;
  final double height;
  final int colorArgb;
}

/// Particles along a ray. Spacing is the medium wavelength. Phase comes from
/// [LightRay.getPhaseOffset], not a free-running animation.
List<WaveParticleState> waveParticlesFor(LightRay ray, {required bool incident}) {
  final wavelength = ray.wavelength;
  if (wavelength <= 0 || !wavelength.isFinite) return const [];
  final dir = ray.getUnitVector();
  final angle = ray.getAngle();
  final total = ray.getPhaseOffset() / (2 * math.pi);
  var phaseDiff = _frac(total) * wavelength;
  late double tailX;
  late double tailY;
  if (incident) {
    tailX = ray.tail.x;
    tailY = ray.tail.y;
  } else {
    final distance = ray.trapeziumWidth / 2 * math.cos(angle);
    phaseDiff = _mod(distance + phaseDiff, wavelength);
    tailX = ray.tail.x - dir.x * ray.trapeziumWidth / 2 * math.cos(angle);
    tailY = ray.tail.y - dir.y * ray.trapeziumWidth / 2 * math.cos(angle);
  }
  final count = math.min((ray.getLength() / wavelength).ceil(), 150) + 1;
  if (count <= 0 || count > 200) return const [];
  return [
    for (var j = 0; j < count; j++)
      WaveParticleState(
        position: BlVec2(
          tailX + dir.x * (j * wavelength + phaseDiff),
          tailY + dir.y * (j * wavelength + phaseDiff),
        ),
        angle: angle,
        width: ray.waveWidth,
        height: wavelength,
        colorArgb: ray.colorArgb,
      ),
  ];
}

/// Perpendicular offset of the wave graphic, in model meters.
/// Magnitude is [WaveMath.waveMagnitude] times half the beam width.
BlVec2 waveOffsetAt(LightRay ray, double distanceAlongRay) {
  final mag = WaveMath.waveMagnitude(
    powerFraction: ray.powerFraction,
    cosArgument: ray.getCosArg(distanceAlongRay),
  );
  final angle = ray.getAngle() + math.pi / 2;
  final amp = mag * ray.waveWidth / 2;
  return BlVec2(amp * math.cos(angle), amp * math.sin(angle));
}

double _frac(double v) {
  final f = v % 1;
  return f < 0 ? f + 1 : f;
}

double _mod(double v, double m) {
  if (m == 0) return 0;
  final r = v % m;
  return r < 0 ? r + m : r;
}
