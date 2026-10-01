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
import '../numerics/wave_kernel_types.dart';

class _HiSlitSep {
  const _HiSlitSep(this.defaultMm, this.minMm, this.maxMm);

  final double defaultMm;
  final double minMm;
  final double maxMm;

  static _HiSlitSep forType(SourceType t) {
    switch (t) {
      case SourceType.photons:
        return _HiSlitSep(QwiUnits.umToMm(2), QwiUnits.umToMm(1), QwiUnits.umToMm(3));
      case SourceType.electrons:
      case SourceType.neutrons:
        return _HiSlitSep(QwiUnits.nmToMm(2), QwiUnits.nmToMm(1), QwiUnits.nmToMm(3));
      case SourceType.heliumAtoms:
        return _HiSlitSep(QwiUnits.nmToMm(0.30), QwiUnits.nmToMm(0.10), QwiUnits.nmToMm(0.40));
    }
  }
}

class _HiSpeed {
  const _HiSpeed(this.defaultMps, this.minMps, this.maxMps);

  final double defaultMps;
  final double minMps;
  final double maxMps;

  static _HiSpeed forType(SourceType t) {
    switch (t) {
      case SourceType.photons:
        return const _HiSpeed(0, 0, 0);
      case SourceType.electrons:
        return const _HiSpeed(1.1e6, 7e5, 1.5e6);
      case SourceType.neutrons:
        return const _HiSpeed(500, 200, 800);
      case SourceType.heliumAtoms:
        return const _HiSpeed(1200, 400, 2000);
    }
  }
}

class HighIntensitySceneModel {
  HighIntensitySceneModel({
    required this.sourceType,
    required QwiRandom random,
  }) : _random = random {
    final sep = _HiSlitSep.forType(sourceType);
    final spd = _HiSpeed.forType(sourceType);
    slitSeparationMm = sep.defaultMm;
    slitSeparationMinMm = sep.minMm;
    slitSeparationMaxMm = sep.maxMm;
    particleSpeedMps = spd.defaultMps;
    speedMinMps = spd.minMps;
    speedMaxMps = spd.maxMps;
    _configureSolverGeometry();
    solver.applySlitConfiguration(slitConfiguration);
  }

  final SourceType sourceType;
  final QwiRandom _random;
  late final WaveRegionHitSampler _hitSampler = WaveRegionHitSampler(random: _random);

  final HighIntensityWaveSolver solver = HighIntensityWaveSolver(
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
  SlitConfiguration slitConfiguration = SlitConfiguration.bothOpen;
  DetectorMode detectionMode = DetectorMode.intensity;
  late WaveDisplayMode waveDisplayMode =
      sourceType.isPhoton ? WaveDisplayMode.electricField : WaveDisplayMode.realPart;
  final HitBuffer hits = HitBuffer(maxHits: QwiConstants.maxHits);
  final SnapshotStore snapshots = SnapshotStore(maxSnapshots: QwiConstants.maxSnapshots);
  double hitAccumulator = 0;
  double detectorPatternFormationFactor = 0;
  bool isEmitting = false;
  double? nextDecoherenceEventTime;
  int leftDetectorHits = 0;
  int rightDetectorHits = 0;
  static const int maxDecoherenceEventsPerFrame = 64;

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

  void _configureSolverGeometry() {
    // Display region: DISPLAY_WAVELENGTHS × default λ across width.
    final lambda = effectiveWavelengthM == 0
        ? QwiUnits.nmToM(QwiConstants.defaultPhotonWavelengthNm)
        : effectiveWavelengthM;
    solver.regionWidth = lambda * QwiConstants.displayWavelengths;
    solver.regionHeight = solver.regionWidth * QwiConstants.waveRegionHeight / QwiConstants.waveRegionWidth;
    solver.waveNumber = 2 * math.pi / (lambda == 0 ? 1 : lambda) * (solver.regionWidth / (lambda * QwiConstants.displayWavelengths));
    // Simpler: waveNumber in display coords so DISPLAY_WAVELENGTHS fit.
    solver.waveNumber = 2 * math.pi * QwiConstants.displayWavelengths / solver.regionWidth;
    final layout = DisplaySlitLayout.compute(
      slitSeparation: slitSeparationMm,
      slitSeparationMin: slitSeparationMinMm,
      slitSeparationMax: slitSeparationMaxMm,
      regionHeight: solver.regionHeight,
    );
    solver.slitSeparationDisplay = layout.displaySlitSeparation;
    solver.slitWidthDisplay = layout.displaySlitWidth;
    final defaultSpeed = _HiSpeed.forType(sourceType).defaultMps;
    solver.displaySpeedScale = sourceType.isPhoton || defaultSpeed == 0
        ? 1.0
        : particleSpeedMps / defaultSpeed;
  }

  void setEmitting(bool on) {
    isEmitting = on;
    solver.setSourceOn(on);
    if (on) {
      detectorPatternFormationFactor = 0;
    } else {
      nextDecoherenceEventTime = null;
      solver.decoherenceEvents = [];
    }
  }

  void setSlitConfiguration(SlitConfiguration config) {
    slitConfiguration = config;
    solver.applySlitConfiguration(config);
    clearScreen();
  }

  void clearScreen() {
    hits.clear();
    hitAccumulator = 0;
    detectorPatternFormationFactor = 0;
    nextDecoherenceEventTime = null;
    leftDetectorHits = 0;
    rightDetectorHits = 0;
    solver.reset();
    if (isEmitting) {
      solver.setSourceOn(true);
    }
  }

  void step(double dt) {
    if (dt <= 0) {
      return;
    }
    _configureSolverGeometry();
    solver.applySlitConfiguration(slitConfiguration);
    solver.step(dt);
    stepDecoherenceEvents(dt);

    if (isEmitting && detectionMode == DetectorMode.intensity) {
      detectorPatternFormationFactor = stepDetectorPatternFormation(detectorPatternFormationFactor, dt);
    }

    if (detectionMode == DetectorMode.hits && isEmitting && !hits.isAtMax) {
      final hasSlitDet = slitConfiguration.hasAnyDetector;
      final rate = hasSlitDet
          ? QwiConstants.highIntensityDetectorHitRateWithSlitDetectors
          : QwiConstants.highIntensityDetectorHitRate;
      final pdf = solver.getDetectorProbabilityDistribution();
      final reached = pdf.any((v) => v > 1e-6);
      if (reached) {
        hitAccumulator += rate * dt;
        while (hitAccumulator >= 1 && !hits.isAtMax) {
          hitAccumulator -= 1;
          hits.tryAdd(_hitSampler.sampleHit(pdf));
        }
      }
    }
  }

  /// Port of `HighIntensitySceneModel.stepDecoherenceEvents`.
  void stepDecoherenceEvents(double dt) {
    if (!isEmitting || dt <= 0 || dt > 0.5) {
      return;
    }
    if (!slitConfiguration.hasBarrier || !slitConfiguration.hasAnyDetector) {
      nextDecoherenceEventTime = null;
      return;
    }

    final currentTime = solver.time;
    final propagationSpeed = solver.displayPropagationSpeed;
    if (propagationSpeed <= 0) {
      return;
    }
    final sourceOnTime = solver.sourceOnTime;
    if (sourceOnTime == null) {
      return;
    }

    final slitArrivalTime =
        sourceOnTime + solver.barrierFractionX * solver.regionWidth / propagationSpeed;
    if (currentTime < slitArrivalTime) {
      return;
    }

    if (nextDecoherenceEventTime == null || nextDecoherenceEventTime! < slitArrivalTime) {
      nextDecoherenceEventTime = slitArrivalTime;
    }

    var eventsCreated = 0;
    final interval = 1 / QwiConstants.highIntensitySlitDetectorEventRate;
    while (nextDecoherenceEventTime! <= currentTime && eventsCreated < maxDecoherenceEventsPerFrame) {
      final event = createDecoherenceEventForSlitConfiguration(slitConfiguration, nextDecoherenceEventTime!);
      if (event != null) {
        addDecoherenceEvent(event);
      }
      nextDecoherenceEventTime = nextDecoherenceEventTime! + interval;
      eventsCreated++;
    }

    if (eventsCreated == 0) {
      pruneDecoherenceEvents();
    } else if (eventsCreated >= maxDecoherenceEventsPerFrame) {
      nextDecoherenceEventTime = currentTime + interval;
    }
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
    if (event.clickedDetectorSlit == FieldComponentSource.topSlit) {
      leftDetectorHits++;
    } else if (event.clickedDetectorSlit == FieldComponentSource.bottomSlit) {
      rightDetectorHits++;
    }
    pruneDecoherenceEvents();
  }

  void pruneDecoherenceEvents() {
    final propagationSpeed = solver.displayPropagationSpeed;
    final visibleHistoryDuration =
        propagationSpeed > 0 ? solver.regionWidth / propagationSpeed + 0.25 : 2.0;
    final removeBeforeTime = solver.time - visibleHistoryDuration - 0.1;
    solver.decoherenceEvents =
        solver.decoherenceEvents.where((e) => e.time >= removeBeforeTime).toList();
  }

  List<double> get detectorPdf => solver.getDetectorProbabilityDistribution();

  bool takeSnapshot() {
    final pdf = detectionMode == DetectorMode.intensity ? detectorPdf : <double>[];
    return snapshots.tryAdd(
      QwiSnapshot(
        snapshotNumber: snapshots.length + 1,
        hits: List<DetectorHit>.from(hits.hits),
        detectionMode: detectionMode,
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
        intensityDistribution: pdf,
      ),
    );
  }

  void setWaveDisplayMode(WaveDisplayMode mode) {
    if (sourceType.isPhoton && !mode.isAllowedForPhotons()) {
      return;
    }
    if (sourceType.isMatter && !mode.isAllowedForMatter()) {
      return;
    }
    waveDisplayMode = mode;
  }

  void reset() {
    wavelengthNm = QwiConstants.defaultPhotonWavelengthNm;
    final sep = _HiSlitSep.forType(sourceType);
    final spd = _HiSpeed.forType(sourceType);
    slitSeparationMm = sep.defaultMm;
    particleSpeedMps = spd.defaultMps;
    screenBrightness = QwiConstants.defaultScreenBrightness;
    slitConfiguration = SlitConfiguration.bothOpen;
    detectionMode = DetectorMode.intensity;
    waveDisplayMode = sourceType.isPhoton ? WaveDisplayMode.electricField : WaveDisplayMode.realPart;
    isEmitting = false;
    nextDecoherenceEventTime = null;
    leftDetectorHits = 0;
    rightDetectorHits = 0;
    clearScreen();
    snapshots.clear();
  }
}

class HighIntensityModel {
  HighIntensityModel({QwiRandom? random}) : random = random ?? SeededQwiRandom(1) {
    scenes = {
      for (final t in SourceType.values) t: HighIntensitySceneModel(sourceType: t, random: this.random),
    };
    activeSource = SourceType.photons;
  }

  final QwiRandom random;
  late final Map<SourceType, HighIntensitySceneModel> scenes;
  late SourceType activeSource;
  final SimulationClock clock = SimulationClock(speedFactors: TimeSpeedFactors.highIntensity);
  final MeasuringTapeState measuringTape = MeasuringTapeState();
  final QwiStopwatchState stopwatch = QwiStopwatchState();
  final MeasurementPlotsState plots = MeasurementPlotsState();
  final GraphZoomState graphZoom = GraphZoomState(level: 3);

  HighIntensitySceneModel get scene => scenes[activeSource]!;

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
    graphZoom.reset(defaultLevel: 3);
  }
}
