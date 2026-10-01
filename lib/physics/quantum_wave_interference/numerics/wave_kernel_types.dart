import 'field_sample.dart';

class DecoherenceEvent {
  const DecoherenceEvent({
    required this.time,
    required this.selectedSlit,
    this.clickedDetectorSlit,
  });

  final double time;
  final FieldComponentSource selectedSlit;
  final FieldComponentSource? clickedDetectorSlit;
}

class GaussianPacketReEmission {
  const GaussianPacketReEmission({
    required this.selectedSlit,
    required this.eventTime,
    required this.sourceX,
    required this.centerY,
    required this.width,
    this.timeAdvance = 0,
  });

  final FieldComponentSource selectedSlit;
  final double eventTime;
  final double timeAdvance;
  final double sourceX;
  final double centerY;
  final double width;
}

sealed class WaveSource {
  const WaveSource();
}

class PlaneWaveSource extends WaveSource {
  const PlaneWaveSource({
    required this.waveNumber,
    required this.speed,
    required this.startTime,
    this.edgeTaperDistance,
  });

  final double waveNumber;
  final double speed;
  final double? startTime;
  final double? edgeTaperDistance;
}

class GaussianPacketSource extends WaveSource {
  const GaussianPacketSource({
    required this.isActive,
    required this.waveNumber,
    required this.speed,
    required this.initialCenterX,
    required this.centerY,
    required this.sigmaX0,
    required this.sigmaY0,
    required this.longitudinalSpreadTime,
    required this.transverseSpreadTime,
  });

  final bool isActive;
  final double waveNumber;
  final double speed;
  final double initialCenterX;
  final double centerY;
  final double sigmaX0;
  final double sigmaY0;
  final double longitudinalSpreadTime;
  final double transverseSpreadTime;
}

class WaveSlit {
  const WaveSlit({
    required this.source,
    required this.centerY,
    required this.width,
    required this.isOpen,
    required this.coherenceGroup,
  });

  final FieldComponentSource source;
  final double centerY;
  final double width;
  final bool isOpen;
  final String coherenceGroup;
}

sealed class WaveBarrier {
  const WaveBarrier();
}

class NoBarrier extends WaveBarrier {
  const NoBarrier();
}

class DoubleSlitBarrier extends WaveBarrier {
  const DoubleSlitBarrier({
    required this.barrierX,
    required this.slits,
  });

  final double barrierX;
  final List<WaveSlit> slits;
}

class MeasurementProjection {
  MeasurementProjection({
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.measurementTime,
    this.renormScale = 1,
    this.edgeFeather,
  });

  final double centerX;
  final double centerY;
  final double radius;
  final double? edgeFeather;
  final double measurementTime;

  /// Updated by solver so ∫|ψ|² is preserved after the bite.
  double renormScale;
}

class WaveParameters {
  const WaveParameters({
    required this.source,
    required this.barrier,
    this.projections = const [],
    this.decoherenceEvents = const [],
    this.packetReEmission,
  });

  final WaveSource source;
  final WaveBarrier barrier;
  final List<MeasurementProjection> projections;
  final List<DecoherenceEvent> decoherenceEvents;
  final GaussianPacketReEmission? packetReEmission;
}
