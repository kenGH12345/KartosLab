import 'dart:math' as math;

import 'complex.dart';
import 'field_sample.dart';
import 'fresnel_aperture_transfer.dart';
import 'wave_kernel_types.dart';
import 'wave_math.dart';

class GaussianPacketState {
  const GaussianPacketState({
    required this.centerX,
    required this.sigmaX,
    required this.sigmaY,
    required this.normalization,
    required this.chirpX,
    required this.chirpY,
  });

  final double centerX;
  final double sigmaX;
  final double sigmaY;
  final double normalization;
  final double chirpX;
  final double chirpY;
}

double getClosestYOnSlit(double y, WaveSlit slit) {
  final halfWidth = slit.width / 2;
  final yMin = slit.centerY - halfWidth;
  final yMax = slit.centerY + halfWidth;
  return math.max(yMin, math.min(yMax, y));
}

/// Port of `WavePropagation.evaluateUndecoheredSample`.
FieldSample evaluateUndecoheredSample(WaveParameters parameters, double x, double y, double t) {
  final source = parameters.source;
  final barrier = parameters.barrier;

  if (parameters.packetReEmission != null && source is GaussianPacketSource) {
    return _evaluateGaussianPacketReEmissionSample(source, parameters.packetReEmission!, x, y, t);
  }

  if (barrier is NoBarrier) {
    final component = _evaluateSourceComponent(source, FieldComponentSource.incident, 'incident', x, y, x, t);
    return component != null ? FieldValueSample([component]) : const UnreachedSample();
  }

  if (barrier is DoubleSlitBarrier) {
    return _evaluateDoubleSlitSample(source, barrier, x, y, t);
  }

  return const UnreachedSample();
}

FieldSample _evaluateGaussianPacketReEmissionSample(
  GaussianPacketSource source,
  GaussianPacketReEmission reEmission,
  double x,
  double y,
  double t,
) {
  if (!source.isActive || t < reEmission.eventTime - kWaveEpsilon || x < reEmission.sourceX - kWaveEpsilon) {
    return const UnreachedSample();
  }

  final localTime = t - reEmission.eventTime + math.max(0.0, reEmission.timeAdvance);
  final localSource = GaussianPacketSource(
    isActive: source.isActive,
    waveNumber: source.waveNumber,
    speed: source.speed,
    initialCenterX: source.initialCenterX,
    centerY: reEmission.centerY,
    sigmaX0: source.sigmaX0,
    sigmaY0: source.sigmaY0,
    longitudinalSpreadTime: source.longitudinalSpreadTime,
    transverseSpreadTime: source.transverseSpreadTime,
  );
  final slit = WaveSlit(
    source: reEmission.selectedSlit,
    centerY: reEmission.centerY,
    width: reEmission.width,
    isOpen: true,
    coherenceGroup: reEmission.selectedSlit.name,
  );
  final xPastSource = x - reEmission.sourceX;

  if (xPastSource <= kWaveEpsilon) {
    if ((y - reEmission.centerY).abs() > reEmission.width / 2) {
      return const UnreachedSample();
    }
    final component = _evaluateSourceComponent(
      localSource,
      reEmission.selectedSlit,
      reEmission.selectedSlit.name,
      0,
      y,
      0,
      localTime,
    );
    return component != null ? FieldValueSample([component]) : const UnreachedSample();
  }

  final closestApertureY = getClosestYOnSlit(y, slit);
  final dyToAperture = y - closestApertureY;
  final distanceFromAperture = math.sqrt(xPastSource * xPastSource + dyToAperture * dyToAperture);
  final component = _evaluateDiffractedComponent(
    localSource,
    slit,
    0,
    xPastSource,
    y,
    distanceFromAperture,
    closestApertureY,
    localTime,
  );
  if (component != null) {
    return FieldValueSample([component]);
  }
  return _isPathReachable(localSource, distanceFromAperture, localTime)
      ? const FieldValueSample([])
      : const UnreachedSample();
}

FieldSample _evaluateDoubleSlitSample(
  WaveSource source,
  DoubleSlitBarrier barrier,
  double x,
  double y,
  double t,
) {
  if (x < barrier.barrierX - kWaveEpsilon) {
    final component = _evaluateSourceComponent(source, FieldComponentSource.incident, 'incident', x, y, x, t);
    return component != null ? FieldValueSample([component]) : const UnreachedSample();
  }

  final openSlits = barrier.slits.where((s) => s.isOpen).toList();
  if (openSlits.isEmpty) {
    return (x - barrier.barrierX).abs() <= kWaveEpsilon ? const AbsorbedSample() : const BlockedSample();
  }

  if ((x - barrier.barrierX).abs() <= kWaveEpsilon) {
    WaveSlit? slit;
    for (final candidate in openSlits) {
      if ((y - candidate.centerY).abs() <= candidate.width / 2) {
        slit = candidate;
        break;
      }
    }
    if (slit == null) {
      return const AbsorbedSample();
    }
    final component = _evaluateSourceComponent(
      source,
      slit.source,
      slit.coherenceGroup,
      barrier.barrierX,
      y,
      barrier.barrierX,
      t,
    );
    return component != null ? FieldValueSample([component]) : const UnreachedSample();
  }

  final components = <FieldComponent>[];
  var hasReachablePath = false;

  for (final slit in openSlits) {
    final xPastBarrier = x - barrier.barrierX;
    final closestApertureY = getClosestYOnSlit(y, slit);
    final dyToAperture = y - closestApertureY;
    final distanceFromAperture = math.sqrt(xPastBarrier * xPastBarrier + dyToAperture * dyToAperture);
    final reachPathLength = barrier.barrierX + distanceFromAperture;
    final component = _evaluateDiffractedComponent(
      source,
      slit,
      barrier.barrierX,
      xPastBarrier,
      y,
      reachPathLength,
      closestApertureY,
      t,
    );
    if (component != null) {
      hasReachablePath = true;
      components.add(component);
    } else if (_isPathReachable(source, reachPathLength, t)) {
      hasReachablePath = true;
      components.add(
        FieldComponent(
          source: slit.source,
          coherenceGroup: slit.coherenceGroup,
          value: Complex.zero,
        ),
      );
    }
  }

  if (components.isNotEmpty) {
    return FieldValueSample(components);
  }
  return hasReachablePath ? const FieldValueSample([]) : const UnreachedSample();
}

FieldComponent? _evaluateDiffractedComponent(
  WaveSource source,
  WaveSlit slit,
  double barrierX,
  double xPastBarrier,
  double y,
  double reachPathLength,
  double closestApertureY,
  double t,
) {
  if (xPastBarrier <= kWaveEpsilon) {
    return null;
  }

  if (source is PlaneWaveSource) {
    final sourceEnvelope = _getPlaneEmissionEnvelope(source, reachPathLength, t);
    if (sourceEnvelope <= 0) {
      return null;
    }
    final barrierPhase = source.waveNumber * barrierX - source.waveNumber * source.speed * t;
    final apertureTransfer = getFresnelApertureTransfer(
      waveNumber: source.waveNumber,
      xPastBarrier: xPastBarrier,
      y: y,
      slit: slit,
    );
    return FieldComponent(
      source: slit.source,
      coherenceGroup: slit.coherenceGroup,
      support: sourceEnvelope * apertureTransfer.support,
      value: polarTimesComplex(sourceEnvelope, barrierPhase, apertureTransfer.value),
    );
  }

  if (source is! GaussianPacketSource || !source.isActive) {
    return null;
  }

  final state = getGaussianPacketState(source, t);
  final nearAperture = xPastBarrier <= math.max(kWaveEpsilon, slit.width * kNearApertureXFraction);
  if (nearAperture && (y - closestApertureY).abs() <= kWaveEpsilon) {
    return _evaluateSourceComponent(source, slit.source, slit.coherenceGroup, barrierX, y, barrierX, t);
  }

  final longitudinalDelta = reachPathLength - state.centerX;
  final normalizedPath = longitudinalDelta / state.sigmaX;
  if (normalizedPath * normalizedPath > 64) {
    return null;
  }
  final transverseDelta = closestApertureY - source.centerY;
  final normalizedTransverse = transverseDelta / state.sigmaY;
  if (normalizedTransverse * normalizedTransverse > 64) {
    return null;
  }

  final envelope = state.normalization *
      math.exp(-0.5 * normalizedPath * normalizedPath) *
      math.exp(-0.5 * normalizedTransverse * normalizedTransverse);
  final apertureLongitudinalDelta = barrierX - state.centerX;
  final phase = source.waveNumber * barrierX -
      source.waveNumber * source.speed * t +
      state.chirpX * apertureLongitudinalDelta * apertureLongitudinalDelta +
      state.chirpY * transverseDelta * transverseDelta;
  final apertureTransfer = getFresnelApertureTransfer(
    waveNumber: source.waveNumber,
    xPastBarrier: xPastBarrier,
    y: y,
    slit: slit,
  );

  return FieldComponent(
    source: slit.source,
    coherenceGroup: slit.coherenceGroup,
    support: envelope * apertureTransfer.support,
    value: polarTimesComplex(envelope, phase, apertureTransfer.value),
  );
}

FieldComponent? _evaluateSourceComponent(
  WaveSource source,
  FieldComponentSource componentSource,
  String coherenceGroup,
  double x,
  double y,
  double pathLength,
  double t,
) {
  if (source is PlaneWaveSource) {
    final sourceEnvelope = _getPlaneEmissionEnvelope(source, pathLength, t);
    if (sourceEnvelope <= 0) {
      return null;
    }
    final phase = source.waveNumber * pathLength - source.waveNumber * source.speed * t;
    return FieldComponent(
      source: componentSource,
      coherenceGroup: coherenceGroup,
      support: sourceEnvelope,
      value: Complex.polar(sourceEnvelope, phase),
    );
  }

  if (source is! GaussianPacketSource || !source.isActive) {
    return null;
  }

  final state = getGaussianPacketState(source, t);
  final longitudinalDelta = pathLength - state.centerX;
  final normalizedPath = longitudinalDelta / state.sigmaX;
  if (normalizedPath * normalizedPath > 64) {
    return null;
  }
  final transverseDelta = y - source.centerY;
  final normalizedTransverse = transverseDelta / state.sigmaY;
  if (componentSource == FieldComponentSource.incident && normalizedTransverse * normalizedTransverse > 64) {
    return null;
  }

  final longitudinalEnvelope = math.exp(-0.5 * normalizedPath * normalizedPath);
  final transverseEnvelope = math.exp(-0.5 * normalizedTransverse * normalizedTransverse);
  final envelope = state.normalization * longitudinalEnvelope * transverseEnvelope;
  final phase = source.waveNumber * pathLength -
      source.waveNumber * source.speed * t +
      state.chirpX * longitudinalDelta * longitudinalDelta +
      state.chirpY * transverseDelta * transverseDelta;

  return FieldComponent(
    source: componentSource,
    coherenceGroup: coherenceGroup,
    support: envelope,
    value: Complex.polar(envelope, phase),
  );
}

GaussianPacketState getGaussianPacketState(GaussianPacketSource source, double t) {
  final longitudinalSpreadTime = math.max(source.longitudinalSpreadTime, kWaveEpsilon);
  final transverseSpreadTime = math.max(source.transverseSpreadTime, kWaveEpsilon);
  final spreadX = t / longitudinalSpreadTime;
  final spreadY = t / transverseSpreadTime;
  final sigmaX = source.sigmaX0 * math.sqrt(1 + spreadX * spreadX);
  final sigmaY = source.sigmaY0 * math.sqrt(1 + spreadY * spreadY);
  return GaussianPacketState(
    centerX: source.initialCenterX + source.speed * t,
    sigmaX: sigmaX,
    sigmaY: sigmaY,
    normalization: math.sqrt(source.sigmaX0 / sigmaX * source.sigmaY0 / sigmaY),
    chirpX: spreadX / (2 * sigmaX * sigmaX),
    chirpY: spreadY / (2 * sigmaY * sigmaY),
  );
}

double _getPlaneEmissionEnvelope(PlaneWaveSource source, double pathLength, double t) {
  if (source.startTime == null || source.speed <= 0) {
    return 0;
  }
  final emissionTime = t - pathLength / source.speed;
  if (emissionTime + kWaveEpsilon < source.startTime!) {
    return 0;
  }
  final taperTime = (source.edgeTaperDistance ?? 0) / source.speed;
  if (taperTime <= 0) {
    return 1;
  }
  return smoothStep(0, taperTime, emissionTime - source.startTime!);
}

bool _isPathReachable(WaveSource source, double pathLength, double t) {
  if (source is GaussianPacketSource) {
    return source.isActive;
  }
  if (source is PlaneWaveSource) {
    return _getPlaneEmissionEnvelope(source, pathLength, t) > 0;
  }
  return false;
}
