import 'dart:math' as math;

import '../constants/qwi_constants.dart';
import '../domain/slit_configuration.dart';
import 'field_sample.dart';
import 'wave_kernel.dart';
import 'wave_kernel_types.dart';
import 'wave_math.dart';

/// Shared analytical solver state for HI / SP wave-region screens.
class AnalyticalWaveSolver {
  AnalyticalWaveSolver({
    this.gridWidth = QwiConstants.defaultWaveSolverGridSize,
    this.gridHeight = QwiConstants.defaultWaveSolverGridSize,
    this.regionWidth = 1.0,
    this.regionHeight = 1.0,
  });

  final int gridWidth;
  final int gridHeight;
  double regionWidth;
  double regionHeight;

  double time = 0;
  double waveNumber = 1;
  double waveSpeed = 1;
  double displaySpeedScale = 1;
  double barrierFractionX = QwiConstants.defaultBarrierPositionFraction;
  double slitSeparationDisplay = 0.2;
  double slitWidthDisplay = 0.05;
  bool isTopSlitOpen = true;
  bool isBottomSlitOpen = true;
  bool isTopSlitDecoherent = false;
  bool isBottomSlitDecoherent = false;
  bool isSourceOn = false;
  List<DecoherenceEvent> decoherenceEvents = [];
  List<MeasurementProjection> measurementProjections = [];
  GaussianPacketReEmission? packetReEmission;

  void step(double dt) {
    if (dt > 0) {
      time += dt;
    }
  }

  void reset() {
    time = 0;
    decoherenceEvents = [];
    measurementProjections = [];
    packetReEmission = null;
    isSourceOn = false;
  }

  double get barrierX => barrierFractionX * regionWidth;

  WaveBarrier buildBarrier() {
    if (!isTopSlitOpen && !isBottomSlitOpen && decoherenceEvents.isEmpty) {
      // Caller sets NoBarrier via setNoBarrier.
    }
    final halfSep = slitSeparationDisplay / 2;
    final sharedGroup = (isTopSlitDecoherent || isBottomSlitDecoherent) ? null : 'both';
    return DoubleSlitBarrier(
      barrierX: barrierX,
      slits: [
        WaveSlit(
          source: FieldComponentSource.topSlit,
          centerY: halfSep,
          width: slitWidthDisplay,
          isOpen: isTopSlitOpen,
          coherenceGroup: sharedGroup ?? 'topSlit',
        ),
        WaveSlit(
          source: FieldComponentSource.bottomSlit,
          centerY: -halfSep,
          width: slitWidthDisplay,
          isOpen: isBottomSlitOpen,
          coherenceGroup: sharedGroup ?? 'bottomSlit',
        ),
      ],
    );
  }

  bool noBarrier = false;

  void applySlitConfiguration(SlitConfiguration config) {
    noBarrier = config == SlitConfiguration.noBarrier;
    if (noBarrier) {
      isTopSlitOpen = false;
      isBottomSlitOpen = false;
      isTopSlitDecoherent = false;
      isBottomSlitDecoherent = false;
      return;
    }
    isTopSlitOpen = config.isTopSlitOpen;
    isBottomSlitOpen = config.isBottomSlitOpen;
    isTopSlitDecoherent = config.hasDetectorOnTop;
    isBottomSlitDecoherent = config.hasDetectorOnBottom;
  }

  WaveParameters createKernelParameters(
    WaveSource source, {
    bool includeDecoherenceEvents = true,
    List<MeasurementProjection>? projections,
  }) {
    return WaveParameters(
      source: source,
      barrier: noBarrier ? const NoBarrier() : buildBarrier(),
      decoherenceEvents: includeDecoherenceEvents
          ? List<DecoherenceEvent>.from(decoherenceEvents)
          : const [],
      projections: projections ?? List<MeasurementProjection>.from(measurementProjections),
      packetReEmission: packetReEmission,
    );
  }

  /// Instantaneous detector PDF at x = regionWidth, max-normalized.
  List<double> computeInstantaneousDetectorDistribution(WaveSource source, {int? sampleCount}) {
    final n = sampleCount ?? gridHeight;
    final distribution = List<double>.filled(n, 0);
    if (source is PlaneWaveSource && source.startTime == null) {
      return distribution;
    }
    if (source is GaussianPacketSource && !source.isActive) {
      return distribution;
    }

    final parameters = createKernelParameters(source);
    final dy = regionHeight / n;
    var maxProb = 0.0;
    for (var iy = 0; iy < n; iy++) {
      final y = (iy + 0.5) * dy - regionHeight / 2;
      final prob = computeSampleIntensity(evaluateSample(parameters, regionWidth, y, time));
      distribution[iy] = prob;
      maxProb = math.max(maxProb, prob);
    }
    if (maxProb > 0) {
      for (var i = 0; i < n; i++) {
        distribution[i] /= maxProb;
      }
    }
    return distribution;
  }

  FieldSample sampleAt(WaveSource source, double x, double y, [double? t]) {
    return evaluateSample(createKernelParameters(source), x, y, t ?? time);
  }
}

/// High Intensity continuous-wave solver with time-averaged detector PDF.
class HighIntensityWaveSolver extends AnalyticalWaveSolver {
  HighIntensityWaveSolver({super.gridWidth, super.gridHeight, super.regionWidth, super.regionHeight});

  double? sourceOnTime;
  final List<double> _accumulator = [];
  int _accumulatorCount = 0;

  double get displayPropagationSpeed =>
      (regionWidth / QwiConstants.highIntensityDisplayTraversalTime) * displaySpeedScale;

  PlaneWaveSource createSource() {
    return PlaneWaveSource(
      waveNumber: waveNumber,
      speed: displayPropagationSpeed,
      startTime: isSourceOn ? (sourceOnTime ?? time) : null,
      edgeTaperDistance: regionWidth / gridWidth * 4, // EDGE_TAPER_CELLS ≈ 4
    );
  }

  @override
  void step(double dt) {
    super.step(dt);
    if (dt <= 0) {
      return;
    }
    if (isSourceOn) {
      final instant = computeInstantaneousDetectorDistribution(createSource());
      if (_accumulator.length != instant.length) {
        _accumulator
          ..clear()
          ..addAll(List<double>.filled(instant.length, 0));
      }
      for (var i = 0; i < instant.length; i++) {
        _accumulator[i] += instant[i];
      }
      _accumulatorCount++;
    } else if (_accumulatorCount > 0) {
      _accumulator.clear();
      _accumulatorCount = 0;
    }
  }

  void setSourceOn(bool on) {
    if (!isSourceOn && on) {
      sourceOnTime = time;
      _accumulator.clear();
      _accumulatorCount = 0;
    } else if (isSourceOn && !on) {
      _accumulator.clear();
      _accumulatorCount = 0;
      sourceOnTime = null;
    }
    isSourceOn = on;
  }

  /// Time-averaged, max-normalized detector PDF.
  List<double> getDetectorProbabilityDistribution({int? sampleCount}) {
    final n = sampleCount ?? gridHeight;
    if (_accumulatorCount == 0 || _accumulator.length != n) {
      return List<double>.filled(n, 0);
    }
    var maxProb = 0.0;
    final out = List<double>.filled(n, 0);
    for (var i = 0; i < n; i++) {
      final avg = _accumulator[i] / _accumulatorCount;
      out[i] = avg;
      maxProb = math.max(maxProb, avg);
    }
    if (maxProb > 0) {
      for (var i = 0; i < n; i++) {
        out[i] /= maxProb;
      }
    }
    return out;
  }

  @override
  void reset() {
    super.reset();
    sourceOnTime = null;
    _accumulator.clear();
    _accumulatorCount = 0;
  }
}

/// Single-particle Gaussian packet solver.
class SingleParticleWaveSolver extends AnalyticalWaveSolver {
  SingleParticleWaveSolver({super.gridWidth, super.gridHeight, super.regionWidth, super.regionHeight});

  /// PhET `MEASUREMENT_BITE_EDGE_FEATHER_PIXELS = 5`.
  static const double measurementBiteEdgeFeatherPixels = 5;

  bool packetActive = false;

  double get displayPropagationSpeed =>
      (regionWidth / QwiConstants.wavePacketTraversalTime) * displaySpeedScale;

  double get measurementBiteEdgeFeather =>
      measurementBiteEdgeFeatherPixels / QwiConstants.waveRegionWidth * regionWidth;

  GaussianPacketSource createSource() {
    final sigmaX0 = QwiConstants.wavePacketSigmaXFraction * regionWidth;
    final sigmaY0 = QwiConstants.wavePacketSigmaYFraction * regionHeight;
    final speed = displayPropagationSpeed;
    return GaussianPacketSource(
      isActive: packetActive,
      waveNumber: waveNumber,
      speed: speed,
      initialCenterX: -QwiConstants.wavePacketStartOffsetSigmas * sigmaX0,
      centerY: 0,
      sigmaX0: sigmaX0,
      sigmaY0: sigmaY0,
      longitudinalSpreadTime:
          QwiConstants.wavePacketLongitudinalSpreadTraversals * QwiConstants.wavePacketTraversalTime,
      transverseSpreadTime:
          QwiConstants.wavePacketTransverseSpreadTraversals * QwiConstants.wavePacketTraversalTime,
    );
  }

  void startPacket() {
    packetActive = true;
    isSourceOn = true;
    time = 0;
    packetReEmission = null;
    decoherenceEvents = [];
    measurementProjections = [];
  }

  void endPacket() {
    packetActive = false;
    isSourceOn = false;
  }

  /// Port of `SingleParticleSolver.applyMeasurementProjection`.
  void applyMeasurementProjection({
    required double centerNormX,
    required double centerNormY,
    required double radiusNorm,
  }) {
    measurementProjections.add(
      MeasurementProjection(
        centerX: centerNormX * regionWidth,
        centerY: (centerNormY - 0.5) * regionHeight,
        radius: radiusNorm * regionWidth,
        edgeFeather: measurementBiteEdgeFeather,
        measurementTime: time,
        renormScale: 1,
      ),
    );
    updateMeasurementProjectionRenormScales();
  }

  /// Preserves total integrated intensity after the bite (PhET grid sum).
  void updateMeasurementProjectionRenormScales([double? t]) {
    final evalT = t ?? time;
    if (measurementProjections.isEmpty || !packetActive) {
      return;
    }
    for (final p in measurementProjections) {
      p.renormScale = 1;
    }
    MeasurementProjection? lastActive;
    for (final p in measurementProjections) {
      if (evalT + kWaveEpsilon >= p.measurementTime) {
        lastActive = p;
      }
    }
    if (lastActive == null) {
      return;
    }

    final source = createSource();
    final unprojected = createKernelParameters(source, projections: const []);
    final projected = createKernelParameters(source);
    var unprojectedTotal = 0.0;
    var projectedTotal = 0.0;
    for (var ix = 0; ix < gridWidth; ix++) {
      final x = (ix + 0.5) / gridWidth * regionWidth;
      for (var iy = 0; iy < gridHeight; iy++) {
        final y = (iy + 0.5) / gridHeight * regionHeight - regionHeight / 2;
        unprojectedTotal += computeSampleIntensity(evaluateSample(unprojected, x, y, evalT));
        projectedTotal += computeSampleIntensity(evaluateSample(projected, x, y, evalT));
      }
    }
    lastActive.renormScale = projectedTotal > kWaveEpsilon && unprojectedTotal > kWaveEpsilon
        ? math.sqrt(unprojectedTotal / projectedTotal)
        : 1;
  }

  /// Integrated |ψ|² over the wave region (for tests).
  double integrateProbabilityDensity({List<MeasurementProjection>? projections}) {
    final source = createSource();
    final params = createKernelParameters(source, projections: projections);
    var total = 0.0;
    for (var ix = 0; ix < gridWidth; ix++) {
      final x = (ix + 0.5) / gridWidth * regionWidth;
      for (var iy = 0; iy < gridHeight; iy++) {
        final y = (iy + 0.5) / gridHeight * regionHeight - regionHeight / 2;
        total += computeSampleIntensity(evaluateSample(params, x, y, time));
      }
    }
    return total;
  }

  List<double> getDetectorProbabilityDistribution({int? sampleCount}) {
    updateMeasurementProjectionRenormScales();
    return computeInstantaneousDetectorDistribution(createSource(), sampleCount: sampleCount);
  }

  @override
  void reset() {
    super.reset();
    packetActive = false;
  }
}

/// Formation factor for HI intensity display (eased exponential).
double stepDetectorPatternFormation(double current, double dt) {
  if (current >= 1) {
    return 1;
  }
  final eased = math.pow(current, 1 / QwiConstants.detectorPatternFormationEasePower).toDouble();
  final nextEased = 1 - (1 - eased) * math.exp(-dt / QwiConstants.detectorPatternFormationTimeConstant);
  var next = math.pow(nextEased, QwiConstants.detectorPatternFormationEasePower).toDouble();
  if (next >= QwiConstants.detectorPatternFormationSnapToComplete) {
    next = 1;
  }
  return next;
}
