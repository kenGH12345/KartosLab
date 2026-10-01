import 'dart:math' as math;

import '../constants/qwi_constants.dart';
import '../constants/qwi_units.dart';
import '../data/graph_data.dart';
import '../data/measurement_plots_state.dart';
import '../data/ruler_data.dart';
import '../domain/detector_mode.dart';
import '../domain/display_slit_layout.dart';
import '../domain/hit.dart';
import '../domain/matter_wave.dart' as matter;
import '../domain/probe.dart';
import '../domain/qwi_random.dart';
import '../domain/simulation_clock.dart';
import '../domain/slit_configuration.dart';
import '../domain/snapshot.dart';
import '../domain/source_type.dart';
import '../domain/time_speed.dart';
import '../domain/wave_display_mode.dart';
import '../numerics/analytical_wave_solver.dart';
import '../numerics/field_sample.dart';
import '../numerics/hit_sampler.dart';
import '../numerics/inverse_standard_normal_cdf.dart';
import '../numerics/probe_solver.dart';
import '../numerics/wave_kernel_types.dart';

class ScreenDetectionTimingParameters {
  const ScreenDetectionTimingParameters({
    this.startWeight = 0.30,
    this.peakWeight = 0.50,
    this.endWeight = 0.70,
    this.leadingPower = 1.0,
    this.trailingPower = 1.0,
  });

  final double startWeight;
  final double peakWeight;
  final double endWeight;
  final double leadingPower;
  final double trailingPower;
}

const screenDetectionTimingParameters = ScreenDetectionTimingParameters();

class _SpSlitSep {
  const _SpSlitSep(this.defaultMm, this.minMm, this.maxMm);

  final double defaultMm;
  final double minMm;
  final double maxMm;

  static _SpSlitSep forType(SourceType t) {
    switch (t) {
      case SourceType.photons:
        return _SpSlitSep(QwiUnits.umToMm(2), QwiUnits.umToMm(1), QwiUnits.umToMm(3));
      case SourceType.electrons:
      case SourceType.neutrons:
        return _SpSlitSep(QwiUnits.nmToMm(2), QwiUnits.nmToMm(1), QwiUnits.nmToMm(3));
      case SourceType.heliumAtoms:
        return _SpSlitSep(QwiUnits.nmToMm(0.30), QwiUnits.nmToMm(0.10), QwiUnits.nmToMm(0.40));
    }
  }
}

class _SpSpeed {
  const _SpSpeed(this.defaultMps, this.minMps, this.maxMps);

  final double defaultMps;
  final double minMps;
  final double maxMps;

  static _SpSpeed forType(SourceType t) {
    switch (t) {
      case SourceType.photons:
        return const _SpSpeed(0, 0, 0);
      case SourceType.electrons:
        return const _SpSpeed(1.1e6, 7e5, 1.5e6);
      case SourceType.neutrons:
        return const _SpSpeed(500, 200, 800);
      case SourceType.heliumAtoms:
        return const _SpSpeed(1200, 400, 2000);
    }
  }
}

class SingleParticlesSceneModel {
  SingleParticlesSceneModel({
    required this.sourceType,
    required QwiRandom random,
  }) : _random = random {
    final sep = _SpSlitSep.forType(sourceType);
    final spd = _SpSpeed.forType(sourceType);
    slitSeparationMm = sep.defaultMm;
    slitSeparationMinMm = sep.minMm;
    slitSeparationMaxMm = sep.maxMm;
    particleSpeedMps = spd.defaultMps;
    speedMinMps = spd.minMps;
    speedMaxMps = spd.maxMps;
    waveDisplayMode =
        sourceType.isPhoton ? WaveDisplayMode.electricField : WaveDisplayMode.realPart;
    _configureSolverGeometry();
    solver.applySlitConfiguration(slitConfiguration);
    timeSinceLastEmission = QwiConstants.singleParticlesMinEmissionInterval;
  }

  final SourceType sourceType;
  final QwiRandom _random;
  late final WaveRegionHitSampler _hitSampler = WaveRegionHitSampler(random: _random);
  final ProbeSolver _probeSolver = const ProbeSolver();

  final SingleParticleWaveSolver solver = SingleParticleWaveSolver(
    regionWidth: 1.0,
    regionHeight: QwiConstants.waveRegionHeight / QwiConstants.waveRegionWidth,
  );

  double wavelengthNm = QwiConstants.defaultPhotonWavelengthNm;
  double particleSpeedMps = 0;
  double speedMinMps = 0;
  double speedMaxMps = 0;
  double slitSeparationMm = 0;
  double slitSeparationMinMm = 0;
  double slitSeparationMaxMm = 0;
  double screenBrightness = QwiConstants.defaultScreenBrightness;
  late WaveDisplayMode waveDisplayMode;
  SlitConfiguration slitConfiguration = SlitConfiguration.bothOpen;
  final DetectorMode detectionMode = DetectorMode.hits;
  final HitBuffer hits = HitBuffer(maxHits: QwiConstants.maxHits);
  final SnapshotStore snapshots = SnapshotStore(maxSnapshots: QwiConstants.maxSnapshots);
  final DetectorProbe detectorProbe = DetectorProbe();

  bool autoRepeat = false;
  bool isEmitting = false;
  bool probeVisible = false;
  double timeSinceLastEmission = 0;
  double targetDetectionTime = double.infinity;
  double targetOnSlitDetectionTime = double.infinity;
  double deterministicOnSlitArrivalTime = QwiConstants.wavePacketTraversalTime;
  bool hasCreatedPacketDecoherenceEvent = false;
  int leftDetectorHits = 0;
  int rightDetectorHits = 0;

  bool get isPacketActive => solver.packetActive;
  bool get isProbeAvailable => slitConfiguration == SlitConfiguration.noBarrier;
  bool get isMaxHitsReached => hits.isAtMax;

  /// Instantaneous detector PDF (max-normalized), empty when no active packet.
  List<double> get detectorPdf {
    if (!solver.packetActive) {
      return List<double>.filled(solver.gridHeight, 0);
    }
    return solver.getDetectorProbabilityDistribution();
  }

  double get effectiveWavelengthM => matter.effectiveWavelengthM(
        sourceType: sourceType,
        photonWavelengthNm: wavelengthNm,
        particleSpeedMps: particleSpeedMps,
      );

  double get effectiveWaveSpeedMps =>
      sourceType.isPhoton ? QwiConstants.speedOfLight : particleSpeedMps;

  /// PhET `BaseSceneModel.getPhysicalDt` — visual dt → physical seconds for stopwatch.
  double getPhysicalDt(double visualDt) {
    _configureSolverGeometry();
    final displayPropagationSpeed = solver.displayPropagationSpeed;
    final effectiveWaveSpeed = effectiveWaveSpeedMps;
    if (visualDt <= 0 ||
        !displayPropagationSpeed.isFinite ||
        !effectiveWaveSpeed.isFinite ||
        displayPropagationSpeed <= 0 ||
        effectiveWaveSpeed <= 0) {
      return 0;
    }
    return displayPropagationSpeed * visualDt / effectiveWaveSpeed;
  }

  void setWaveDisplayMode(WaveDisplayMode mode) {
    if (sourceType.isPhoton && !mode.isAllowedForPhotons()) {
      return;
    }
    if (!sourceType.isPhoton && !mode.isAllowedForMatter()) {
      return;
    }
    waveDisplayMode = mode;
  }

  void _configureSolverGeometry() {
    final lambda = effectiveWavelengthM == 0
        ? QwiUnits.nmToM(QwiConstants.defaultPhotonWavelengthNm)
        : effectiveWavelengthM;
    solver.regionWidth = lambda * QwiConstants.displayWavelengths;
    solver.regionHeight = solver.regionWidth * QwiConstants.waveRegionHeight / QwiConstants.waveRegionWidth;
    solver.waveNumber = 2 * math.pi * QwiConstants.displayWavelengths / solver.regionWidth;
    final layout = DisplaySlitLayout.compute(
      slitSeparation: slitSeparationMm,
      slitSeparationMin: slitSeparationMinMm,
      slitSeparationMax: slitSeparationMaxMm,
      regionHeight: solver.regionHeight,
    );
    solver.slitSeparationDisplay = layout.displaySlitSeparation;
    solver.slitWidthDisplay = layout.displaySlitWidth;
    final defaultSpeed = _SpSpeed.forType(sourceType).defaultMps;
    solver.displaySpeedScale =
        sourceType.isPhoton || defaultSpeed == 0 ? 1.0 : particleSpeedMps / defaultSpeed;
  }

  double sampleScreenDetectionWeight() {
    final p = screenDetectionTimingParameters;
    for (var i = 0; i < 100; i++) {
      final weight = p.startWeight + _random.nextDouble() * (p.endWeight - p.startWeight);
      late final double density;
      if (weight <= p.peakWeight) {
        final u = (weight - p.startWeight) / (p.peakWeight - p.startWeight);
        density = math.pow(u.clamp(0.0, 1.0), p.leadingPower).toDouble();
      } else {
        final u = (p.endWeight - weight) / (p.endWeight - p.peakWeight);
        density = math.pow(u.clamp(0.0, 1.0), p.trailingPower).toDouble();
      }
      if (_random.nextDouble() < density) {
        return weight;
      }
    }
    return p.peakWeight;
  }

  /// Port of `sampleDetectionDelayToTargetX`.
  double sampleDetectionDelayToTargetX(double targetX, double sourceX) {
    final propagationSpeed = solver.displayPropagationSpeed;
    if (propagationSpeed <= 0) {
      return QwiConstants.wavePacketTraversalTime;
    }
    final sigmaX0 = QwiConstants.wavePacketSigmaXFraction * solver.regionWidth;
    final initialCenterX = -QwiConstants.wavePacketStartOffsetSigmas * sigmaX0;
    final detectionWeight = sampleScreenDetectionWeight();
    final sampledCenterOffset = inverseStandardNormalCdf(detectionWeight) * sigmaX0;
    return (targetX - sourceX - initialCenterX + sampledCenterOffset) / propagationSpeed;
  }

  double sampleDetectionTime() => sampleDetectionDelayToTargetX(solver.regionWidth, 0);

  double getDeterministicSlitArrivalTime() {
    final propagationSpeed = solver.displayPropagationSpeed;
    if (propagationSpeed <= 0) {
      return QwiConstants.wavePacketTraversalTime;
    }
    final sigmaX0 = QwiConstants.wavePacketSigmaXFraction * solver.regionWidth;
    final initialCenterX = -QwiConstants.wavePacketStartOffsetSigmas * sigmaX0;
    return (solver.barrierFractionX * solver.regionWidth - initialCenterX) / propagationSpeed;
  }

  void emitPacket() {
    if (solver.packetActive || hits.isAtMax) {
      return;
    }
    if (timeSinceLastEmission < QwiConstants.singleParticlesMinEmissionInterval) {
      return;
    }
    _configureSolverGeometry();
    solver.applySlitConfiguration(slitConfiguration);
    solver.startPacket();
    isEmitting = true;
    timeSinceLastEmission = 0;
    detectorProbe.reset();
    hasCreatedPacketDecoherenceEvent = false;
    targetDetectionTime = sampleDetectionTime();
    deterministicOnSlitArrivalTime = getDeterministicSlitArrivalTime();
    targetOnSlitDetectionTime = sampleDetectionDelayToTargetX(
      solver.barrierFractionX * solver.regionWidth,
      0,
    );
  }

  /// Fire once (manual emitter) — sets emitting and emits if idle.
  void fireOnce() {
    if (hits.isAtMax || solver.packetActive) {
      return;
    }
    isEmitting = true;
    emitPacket();
  }

  void setAutoRepeat(bool on) {
    autoRepeat = on;
    if (on && !solver.packetActive && !hits.isAtMax) {
      isEmitting = true;
    } else if (!on && !solver.packetActive) {
      isEmitting = false;
    }
  }

  void endPacket({required bool fromProbeSuccess}) {
    solver.endPacket();
    solver.packetReEmission = null;
    if (!autoRepeat) {
      isEmitting = false;
    }
    targetDetectionTime = double.infinity;
    targetOnSlitDetectionTime = double.infinity;
    hasCreatedPacketDecoherenceEvent = false;
    if (!fromProbeSuccess) {
      // screen hit already added by detectPacket
    }
  }

  void detectPacket() {
    if (!solver.packetActive) {
      return;
    }
    final pdf = solver.getDetectorProbabilityDistribution();
    hits.tryAdd(_hitSampler.sampleHit(pdf));
    endPacket(fromProbeSuccess: false);
  }

  DecoherenceEvent? createDecoherenceEventForSlitConfiguration(
    SlitConfiguration config,
    double time,
  ) {
    if (!config.hasAnyDetector) {
      return null;
    }
    final topOpen = config.isTopSlitOpen;
    final bottomOpen = config.isBottomSlitOpen;
    late final FieldComponentSource selectedSlit;
    if (topOpen && !bottomOpen) {
      selectedSlit = FieldComponentSource.topSlit;
    } else if (bottomOpen && !topOpen) {
      selectedSlit = FieldComponentSource.bottomSlit;
    } else if (topOpen && bottomOpen) {
      selectedSlit =
          _random.nextDouble() < 0.5 ? FieldComponentSource.topSlit : FieldComponentSource.bottomSlit;
    } else {
      return null;
    }

    final clicked = selectedSlit == FieldComponentSource.topSlit && config.hasDetectorOnTop
        ? FieldComponentSource.topSlit
        : selectedSlit == FieldComponentSource.bottomSlit && config.hasDetectorOnBottom
            ? FieldComponentSource.bottomSlit
            : null;

    return DecoherenceEvent(
      time: time,
      selectedSlit: selectedSlit,
      clickedDetectorSlit: clicked,
    );
  }

  void addDecoherenceEvent(DecoherenceEvent event) {
    solver.decoherenceEvents = [...solver.decoherenceEvents, event];
  }

  GaussianPacketReEmission createPacketReEmission(
    FieldComponentSource selectedSlit,
    double eventTime,
  ) {
    final centerY = selectedSlit == FieldComponentSource.topSlit
        ? solver.slitSeparationDisplay / 2
        : -solver.slitSeparationDisplay / 2;
    return GaussianPacketReEmission(
      selectedSlit: selectedSlit,
      eventTime: eventTime,
      sourceX: solver.barrierFractionX * solver.regionWidth,
      centerY: centerY,
      width: solver.slitWidthDisplay,
      timeAdvance: getPacketReEmissionTimeAdvance(eventTime),
    );
  }

  double getPacketReEmissionTimeAdvance(double eventTime) {
    final propagationSpeed = solver.displayPropagationSpeed;
    if (propagationSpeed <= 0) {
      return 0;
    }
    final baseAdvance = QwiConstants.wavePacketReEmissionTimeAdvanceSigmas *
        QwiConstants.wavePacketSigmaXFraction *
        solver.regionWidth /
        propagationSpeed;
    return math.max(0.0, baseAdvance + eventTime - deterministicOnSlitArrivalTime);
  }

  void startPacketReEmission(FieldComponentSource selectedSlit, double eventTime) {
    if (selectedSlit == FieldComponentSource.topSlit) {
      leftDetectorHits++;
    } else if (selectedSlit == FieldComponentSource.bottomSlit) {
      rightDetectorHits++;
    }
    solver.decoherenceEvents = [];
    final reEmission = createPacketReEmission(selectedSlit, eventTime);
    solver.packetReEmission = reEmission;
    targetDetectionTime = eventTime +
        math.max(
          0.0,
          sampleDetectionDelayToTargetX(solver.regionWidth, reEmission.sourceX) -
              reEmission.timeAdvance,
        );
  }

  /// Port of `createPacketDecoherenceEventIfNeeded`.
  void createPacketDecoherenceEventIfNeeded() {
    if (hasCreatedPacketDecoherenceEvent ||
        !slitConfiguration.hasBarrier ||
        !slitConfiguration.hasAnyDetector) {
      return;
    }
    if (solver.time < targetOnSlitDetectionTime) {
      return;
    }
    final event =
        createDecoherenceEventForSlitConfiguration(slitConfiguration, targetOnSlitDetectionTime);
    if (event != null) {
      final clicked = event.clickedDetectorSlit;
      if (clicked != null) {
        startPacketReEmission(clicked, targetOnSlitDetectionTime);
      } else {
        addDecoherenceEvent(event);
      }
    }
    hasCreatedPacketDecoherenceEvent = true;
  }

  double computeProbeProbability() {
    if (!solver.packetActive || !isProbeAvailable) {
      return 0;
    }
    return _probeSolver.computeProbability(
      parameters: solver.createKernelParameters(solver.createSource()),
      time: solver.time,
      regionWidth: solver.regionWidth,
      regionHeight: solver.regionHeight,
      gridWidth: solver.gridWidth,
      gridHeight: solver.gridHeight,
      probe: detectorProbe,
    );
  }

  void performDetectorMeasurement() {
    if (detectorProbe.state != ProbeState.ready) {
      return;
    }
    if (!isProbeAvailable) {
      return;
    }
    if (!solver.packetActive) {
      detectorProbe.probability = 0;
      detectorProbe.state = ProbeState.notDetected;
      return;
    }
    final p = computeProbeProbability();
    detectorProbe.probability = p;
    final detected = _probeSolver.detect(random: _random, probability: p);
    if (detected) {
      detectorProbe.state = ProbeState.detected;
      endPacket(fromProbeSuccess: true);
    } else {
      detectorProbe.state = ProbeState.notDetected;
      solver.applyMeasurementProjection(
        centerNormX: detectorProbe.normalizedX,
        centerNormY: detectorProbe.normalizedY,
        radiusNorm: detectorProbe.radius,
      );
    }
  }

  void setSlitConfiguration(SlitConfiguration config) {
    slitConfiguration = config;
    solver.applySlitConfiguration(config);
    if (config != SlitConfiguration.noBarrier) {
      probeVisible = false;
    }
    clearScreen();
  }

  void clearScreen() {
    hits.clear();
    leftDetectorHits = 0;
    rightDetectorHits = 0;
    if (solver.packetActive) {
      solver.endPacket();
    }
    solver.packetReEmission = null;
    solver.decoherenceEvents = [];
    solver.measurementProjections = [];
    detectorProbe.probability = 0;
    if (!autoRepeat) {
      isEmitting = false;
    }
    timeSinceLastEmission = QwiConstants.singleParticlesMinEmissionInterval;
    targetDetectionTime = double.infinity;
    targetOnSlitDetectionTime = double.infinity;
    deterministicOnSlitArrivalTime = QwiConstants.wavePacketTraversalTime;
    hasCreatedPacketDecoherenceEvent = false;
  }

  void step(double dt) {
    if (dt <= 0) {
      return;
    }
    timeSinceLastEmission += dt;
    _configureSolverGeometry();
    solver.applySlitConfiguration(slitConfiguration);

    if (solver.packetActive) {
      solver.step(dt);
      createPacketDecoherenceEventIfNeeded();
      if (isProbeAvailable && detectorProbe.state == ProbeState.ready) {
        detectorProbe.probability = computeProbeProbability();
      }
      if (solver.packetActive && solver.time >= targetDetectionTime) {
        detectPacket();
      }
    } else {
      if (isProbeAvailable) {
        detectorProbe.probability = 0;
      }
    }

    // Auto-repeat / continuous emit gate (matches TS step).
    if (isEmitting &&
        !solver.packetActive &&
        timeSinceLastEmission >= QwiConstants.singleParticlesMinEmissionInterval &&
        !hits.isAtMax) {
      emitPacket();
    }
  }

  bool takeSnapshot() {
    return snapshots.tryAdd(
      QwiSnapshot(
        snapshotNumber: snapshots.length + 1,
        hits: List<DetectorHit>.from(hits.hits),
        detectionMode: DetectorMode.hits,
        sourceType: sourceType,
        wavelengthNm: wavelengthNm,
        slitSeparationMm: slitSeparationMm,
        screenDistanceM: 0,
        screenHalfWidthM: 0,
        effectiveWavelengthM: effectiveWavelengthM,
        slitSetting: slitConfiguration,
        envelopeCategory: 'brightestAtCenter',
        isEmitting: isEmitting,
        brightness: screenBrightness,
        intensity: 1,
        slitWidthMm: 0,
        intensityDistribution: List<double>.from(detectorPdf),
      ),
    );
  }

  void reset() {
    wavelengthNm = QwiConstants.defaultPhotonWavelengthNm;
    final sep = _SpSlitSep.forType(sourceType);
    final spd = _SpSpeed.forType(sourceType);
    slitSeparationMm = sep.defaultMm;
    particleSpeedMps = spd.defaultMps;
    speedMinMps = spd.minMps;
    speedMaxMps = spd.maxMps;
    screenBrightness = QwiConstants.defaultScreenBrightness;
    slitConfiguration = SlitConfiguration.bothOpen;
    waveDisplayMode =
        sourceType.isPhoton ? WaveDisplayMode.electricField : WaveDisplayMode.realPart;
    autoRepeat = false;
    isEmitting = false;
    probeVisible = false;
    timeSinceLastEmission = QwiConstants.singleParticlesMinEmissionInterval;
    targetDetectionTime = double.infinity;
    targetOnSlitDetectionTime = double.infinity;
    deterministicOnSlitArrivalTime = QwiConstants.wavePacketTraversalTime;
    hasCreatedPacketDecoherenceEvent = false;
    leftDetectorHits = 0;
    rightDetectorHits = 0;
    detectorProbe.resetFully();
    clearScreen();
    snapshots.clear();
    solver.reset();
  }
}

class SingleParticlesModel {
  SingleParticlesModel({QwiRandom? random}) : random = random ?? SeededQwiRandom(1) {
    scenes = {
      for (final t in SourceType.values) t: SingleParticlesSceneModel(sourceType: t, random: this.random),
    };
    activeSource = SourceType.photons;
  }

  final QwiRandom random;
  late final Map<SourceType, SingleParticlesSceneModel> scenes;
  late SourceType activeSource;
  final SimulationClock clock = SimulationClock(speedFactors: TimeSpeedFactors.singleParticles);
  final MeasuringTapeState measuringTape = MeasuringTapeState();
  final QwiStopwatchState stopwatch = QwiStopwatchState();
  final MeasurementPlotsState plots = MeasurementPlotsState();
  final GraphZoomState graphZoom = GraphZoomState(level: 6);

  SingleParticlesSceneModel get scene => scenes[activeSource]!;

  void selectSource(SourceType type) => activeSource = type;

  void step(double wallDt) {
    final dt = clock.advance(wallDt);
    if (dt > 0) {
      scene.step(dt);
      final physicalDt = scene.getPhysicalDt(dt);
      if (physicalDt > 0) {
        stopwatch.step(physicalDt);
      }
    }
  }

  void stepOnce() {
    final dt = clock.stepOnce();
    scene.step(dt);
    final physicalDt = scene.getPhysicalDt(dt);
    if (physicalDt > 0) {
      stopwatch.step(physicalDt);
    }
  }

  void reset() {
    for (final s in scenes.values) {
      s.reset();
    }
    activeSource = SourceType.photons;
    clock.reset();
    measuringTape.reset();
    stopwatch.reset();
    plots.reset();
    graphZoom.reset(defaultLevel: 6);
  }
}
