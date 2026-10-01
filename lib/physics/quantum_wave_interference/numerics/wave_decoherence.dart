import 'dart:math' as math;

import 'complex.dart';
import 'field_sample.dart';
import 'wave_kernel_types.dart';
import 'wave_math.dart';
import 'wave_propagation.dart';

const double planeWaveDecoherenceBandDuration = 0.2;

DecoherenceEvent? _getDecoherenceEventAtPassTime(List<DecoherenceEvent> events, double passTime) {
  for (var i = events.length - 1; i >= 0; i--) {
    if (events[i].time <= passTime + kWaveEpsilon) {
      return events[i];
    }
  }
  return null;
}

class _DecoherenceChain {
  const _DecoherenceChain({required this.event, required this.strength});

  final DecoherenceEvent event;
  final double strength;
}

_DecoherenceChain? _getPlaneWaveDecoherenceChainAtPassTime(List<DecoherenceEvent> events, double passTime) {
  for (var i = events.length - 1; i >= 0; i--) {
    final event = events[i];
    if (passTime < event.time - kWaveEpsilon) {
      continue;
    }
    if (passTime > event.time + planeWaveDecoherenceBandDuration + kWaveEpsilon) {
      return null;
    }

    var chainStartTime = event.time;
    for (var j = i - 1; j >= 0; j--) {
      final previousEvent = events[j];
      if (previousEvent.selectedSlit != event.selectedSlit ||
          chainStartTime - previousEvent.time > planeWaveDecoherenceBandDuration + kWaveEpsilon) {
        break;
      }
      chainStartTime = previousEvent.time;
    }

    var chainEndTime = event.time + planeWaveDecoherenceBandDuration;
    var lastEventTime = event.time;
    for (var j = i + 1; j < events.length; j++) {
      final nextEvent = events[j];
      if (nextEvent.selectedSlit != event.selectedSlit ||
          nextEvent.time - lastEventTime > planeWaveDecoherenceBandDuration + kWaveEpsilon) {
        break;
      }
      lastEventTime = nextEvent.time;
      chainEndTime = nextEvent.time + planeWaveDecoherenceBandDuration;
    }

    return _DecoherenceChain(
      event: event,
      strength: _getPlaneWaveDecoherenceChainStrength(passTime, chainStartTime, chainEndTime),
    );
  }
  return null;
}

double _getPlaneWaveDecoherenceChainStrength(double passTime, double chainStartTime, double chainEndTime) {
  if (passTime <= chainStartTime + kWaveEpsilon || passTime >= chainEndTime - kWaveEpsilon) {
    return 0;
  }
  final half = planeWaveDecoherenceBandDuration / 2;
  final lead = smoothStep(chainStartTime, chainStartTime + half, passTime);
  final trail = 1 - smoothStep(chainEndTime - half, chainEndTime, passTime);
  return lead * trail;
}

_DecoherenceChain? _getPlaneWaveComponentDecoherenceChain(
  FieldComponent component,
  List<DecoherenceEvent> events,
  DoubleSlitBarrier barrier,
  PlaneWaveSource source,
  double x,
  double y,
  double t,
) {
  if (component.source != FieldComponentSource.topSlit && component.source != FieldComponentSource.bottomSlit) {
    return null;
  }
  WaveSlit? slit;
  for (final s in barrier.slits) {
    if (s.source == component.source) {
      slit = s;
      break;
    }
  }
  if (slit == null) {
    return null;
  }
  final closestY = getClosestYOnSlit(y, slit);
  final dy = y - closestY;
  final xPast = x - barrier.barrierX;
  final distance = math.sqrt(xPast * xPast + dy * dy);
  final passTime = t - distance / source.speed;
  return _getPlaneWaveDecoherenceChainAtPassTime(events, passTime);
}

/// Port of `WaveDecoherence.applyDecoherenceEvent` (model-facing).
FieldSample applyDecoherenceEvent(
  FieldSample sample,
  WaveParameters parameters,
  double x,
  double y,
  double t,
) {
  final events = parameters.decoherenceEvents;
  final barrier = parameters.barrier;

  if (sample is! FieldValueSample ||
      events.isEmpty ||
      barrier is! DoubleSlitBarrier ||
      x < barrier.barrierX - kWaveEpsilon) {
    return sample;
  }

  final source = parameters.source;
  final isPacketProjection = source is GaussianPacketSource;
  final packetEvent = isPacketProjection ? _getDecoherenceEventAtPassTime(events, t) : null;

  final components = sample.components.map((component) {
    if (component.source == FieldComponentSource.topSlit || component.source == FieldComponentSource.bottomSlit) {
      DecoherenceEvent? event = packetEvent;
      var planeWaveDecoherenceStrength = 1.0;

      if (event == null && source is PlaneWaveSource && source.speed > 0) {
        final chain = _getPlaneWaveComponentDecoherenceChain(component, events, barrier, source, x, y, t);
        if (chain != null) {
          event = chain.event;
          planeWaveDecoherenceStrength = chain.strength;
        }
      }

      if (event == null) {
        return component;
      }
      if (event.selectedSlit == component.source) {
        return component;
      }

      final scale = 1 - planeWaveDecoherenceStrength;
      return FieldComponent(
        source: component.source,
        coherenceGroup: component.coherenceGroup,
        value: Complex(component.value.real * scale, component.value.imaginary * scale),
        support: component.support == null ? null : component.support! * scale,
      );
    }
    return component;
  }).toList();

  return FieldValueSample(components);
}
