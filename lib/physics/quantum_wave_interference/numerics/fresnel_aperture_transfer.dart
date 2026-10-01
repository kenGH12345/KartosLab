import 'dart:math' as math;

import 'complex.dart';
import 'wave_kernel_types.dart';
import 'wave_math.dart';

/// Port of `FresnelApertureTransfer.ts`.
class ApertureTransfer {
  const ApertureTransfer({required this.value, required this.support});

  final Complex value;
  final double support;
}

const double _apertureBlendSlitWidthFraction = 0.5;
const double _apertureBlendWavelengthFraction = 0.25;

/// Abramowitz–Stegun style Fresnel integral approximation → (C, S) as Complex(real=C, imag=S).
void _setFresnelIntegral(double x, List<double> out) {
  final sign = x < 0 ? -1.0 : 1.0;
  final ax = x.abs();
  if (ax < kWaveEpsilon) {
    out[0] = 0;
    out[1] = 0;
    return;
  }
  final phase = 0.5 * math.pi * ax * ax;
  final sinPhase = math.sin(phase);
  final cosPhase = math.cos(phase);
  final f = (1 + 0.926 * ax) / (2 + 1.792 * ax + 3.104 * ax * ax);
  final g = 1 / (2 + 4.142 * ax + 3.492 * ax * ax + 6.67 * ax * ax * ax);
  out[0] = sign * (0.5 + f * sinPhase - g * cosPhase);
  out[1] = sign * (0.5 - f * cosPhase - g * sinPhase);
}

ApertureTransfer getFresnelApertureTransfer({
  required double waveNumber,
  required double xPastBarrier,
  required double y,
  required WaveSlit slit,
}) {
  final halfWidth = slit.width / 2;
  final yMin = slit.centerY - halfWidth;
  final yMax = slit.centerY + halfWidth;
  final nearApertureX = math.max(kWaveEpsilon, slit.width * kNearApertureXFraction);
  final apertureMaskReal = (y - slit.centerY).abs() <= halfWidth ? 1.0 : 0.0;
  final apertureMaskSupport = apertureMaskReal;

  if (xPastBarrier <= nearApertureX) {
    return ApertureTransfer(value: Complex(apertureMaskReal, 0), support: apertureMaskSupport);
  }

  final wavelength = 2 * math.pi / waveNumber;
  final uScale = math.sqrt(2 / (wavelength * xPastBarrier));
  final uMin = (yMin - y) * uScale;
  final uMax = (yMax - y) * uScale;

  final uMinC = <double>[0, 0];
  final uMaxC = <double>[0, 0];
  _setFresnelIntegral(uMin, uMinC);
  _setFresnelIntegral(uMax, uMaxC);

  final apertureIntegralReal = uMaxC[0] - uMinC[0];
  final apertureIntegralImag = uMaxC[1] - uMinC[1];

  // Fine-tuned magnitude 0.57 — PhET issue #152.
  final transfer = polarTimesComplex(
    0.57,
    waveNumber * xPastBarrier - math.pi / 4,
    Complex(apertureIntegralReal, apertureIntegralImag),
  );

  final apertureBlendDistance = math.max(
    nearApertureX,
    math.min(slit.width * _apertureBlendSlitWidthFraction, wavelength * _apertureBlendWavelengthFraction),
  );

  if (xPastBarrier < apertureBlendDistance) {
    final blend = smoothStep(nearApertureX, apertureBlendDistance, xPastBarrier);
    final blended = Complex(
      apertureMaskReal + (transfer.real - apertureMaskReal) * blend,
      0 + (transfer.imaginary - 0) * blend,
    );
    return ApertureTransfer(
      value: blended,
      support: apertureMaskSupport + (1 - apertureMaskSupport) * blend,
    );
  }

  return ApertureTransfer(value: transfer, support: 1);
}
