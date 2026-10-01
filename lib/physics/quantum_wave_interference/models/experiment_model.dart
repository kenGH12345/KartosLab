import '../constants/qwi_constants.dart';
import '../constants/qwi_units.dart';
import '../data/graph_data.dart';
import '../data/ruler_data.dart';
import '../domain/detector_mode.dart';
import '../domain/detector_screen_scale.dart';
import '../domain/hit.dart';
import '../domain/matter_wave.dart' as matter;
import '../domain/qwi_random.dart';
import '../domain/simulation_clock.dart';
import '../domain/slit_configuration.dart';
import '../domain/snapshot.dart';
import '../domain/source_type.dart';
import '../domain/time_speed.dart';
import '../numerics/fraunhofer_solver.dart';
import '../numerics/hit_sampler.dart';

class ExperimentSourceDefaults {
  const ExperimentSourceDefaults({
    required this.slitSeparationMm,
    required this.slitSeparationMinMm,
    required this.slitSeparationMaxMm,
    required this.slitWidthMm,
    required this.defaultSpeedMps,
    required this.speedMinMps,
    required this.speedMaxMps,
  });

  final double slitSeparationMm;
  final double slitSeparationMinMm;
  final double slitSeparationMaxMm;
  final double slitWidthMm;
  final double defaultSpeedMps;
  final double speedMinMps;
  final double speedMaxMps;

  static ExperimentSourceDefaults forType(SourceType type) {
    switch (type) {
      case SourceType.photons:
        return const ExperimentSourceDefaults(
          slitSeparationMm: 0.25,
          slitSeparationMinMm: 0.05,
          slitSeparationMaxMm: 0.5,
          slitWidthMm: 0.02,
          defaultSpeedMps: 0,
          speedMinMps: 0,
          speedMaxMps: 0,
        );
      case SourceType.electrons:
        return const ExperimentSourceDefaults(
          slitSeparationMm: 0.001,
          slitSeparationMinMm: 0.0001,
          slitSeparationMaxMm: 0.002,
          slitWidthMm: 6e-5,
          defaultSpeedMps: 6e5,
          speedMinMps: 2e5,
          speedMaxMps: 1e6,
        );
      case SourceType.neutrons:
      case SourceType.heliumAtoms:
        return const ExperimentSourceDefaults(
          slitSeparationMm: 0.001,
          slitSeparationMinMm: 0.0001,
          slitSeparationMaxMm: 0.002,
          slitWidthMm: 6e-5,
          defaultSpeedMps: 600,
          speedMinMps: 200,
          speedMaxMps: 1000,
        );
    }
  }
}

/// Per-source Experiment scene (Fraunhofer backend — no WaveSolver).
class ExperimentSceneModel {
  ExperimentSceneModel({
    required this.sourceType,
    required QwiRandom random,
  })  : _random = random,
        defaults = ExperimentSourceDefaults.forType(sourceType) {
    _resetParameters();
  }

  final SourceType sourceType;
  final ExperimentSourceDefaults defaults;
  final QwiRandom _random;
  late final ExperimentHitSampler _hitSampler = ExperimentHitSampler(random: _random);

  double wavelengthNm = QwiConstants.defaultPhotonWavelengthNm;
  double particleSpeedMps = 0;
  double sourceStrength = QwiConstants.experimentDefaultSourceStrength;
  double slitSeparationMm = 0.25;
  double screenDistanceM = QwiConstants.experimentDefaultScreenDistanceM;
  double screenBrightness = QwiConstants.defaultScreenBrightness;
  SlitConfiguration slitConfiguration = SlitConfiguration.bothOpen;
  DetectorMode detectionMode = DetectorMode.intensity;
  /// Laser / source sticky toggle (`isEmittingProperty`, default false).
  bool isEmitting = false;
  final HitBuffer hits = HitBuffer(maxHits: QwiConstants.maxHits);
  final SnapshotStore snapshots = SnapshotStore(maxSnapshots: QwiConstants.maxSnapshots);
  double hitAccumulator = 0;
  int leftDetectorHits = 0;
  int rightDetectorHits = 0;

  double get slitWidthMm => defaults.slitWidthMm;

  double get effectiveWavelengthM => matter.effectiveWavelengthM(
        sourceType: sourceType,
        photonWavelengthNm: wavelengthNm,
        particleSpeedMps: particleSpeedMps,
      );

  /// Physical half-width of the **full** detector face (meters).
  /// Zoom changes only the visible window — never this value (`DetectorScreenScale.ts`).
  double get fullScreenHalfWidthM => DetectorScreenScale.fullDetectorScreenHalfWidthM;

  double intensityAtPhysicalX(double positionOnScreenM) {
    return FraunhoferSolver.getExactDetectorIntensity(
      FraunhoferOptions(
        positionOnScreenM: positionOnScreenM,
        effectiveWavelengthM: effectiveWavelengthM,
        screenDistanceM: screenDistanceM,
        slitWidthM: QwiUnits.mmToM(slitWidthMm),
        slitSeparationM: QwiUnits.mmToM(slitSeparationMm),
        slitSetting: slitConfiguration,
      ),
    );
  }

  IntensityGraphData intensityGraph({int samples = 200}) {
    final half = fullScreenHalfWidthM;
    final positions = <double>[];
    final intensities = <double>[];
    for (var i = 0; i < samples; i++) {
      final t = (i + 0.5) / samples;
      final y = (t - 0.5) * 2 * half;
      positions.add(y / half); // normalized [-1,1]
      intensities.add(intensityAtPhysicalX(y));
    }
    return IntensityGraphData(positions: positions, intensities: intensities);
  }

  HitsHistogramData hitsHistogram() => HitsHistogramData.fromHits(hits.hits);

  void clearScreen() {
    hits.clear();
    hitAccumulator = 0;
    leftDetectorHits = 0;
    rightDetectorHits = 0;
  }

  void onPhysicsParameterChanged() => clearScreen();

  void setEmitting(bool value) {
    if (hits.isAtMax && value) {
      return;
    }
    isEmitting = value;
  }

  void step(double dt) {
    if (dt <= 0 || dt > 0.5) {
      return;
    }
    if (!isEmitting || detectionMode != DetectorMode.hits || hits.isAtMax) {
      return;
    }
    final rate = QwiConstants.experimentMaxEmissionRate * sourceStrength;
    hitAccumulator += rate * dt;
    final detectorsActive = slitConfiguration.hasAnyDetector;
    while (hitAccumulator >= 1 && !hits.isAtMax) {
      hitAccumulator -= 1;
      final hit = _hitSampler.sampleHit(
        fullScreenHalfWidthM: fullScreenHalfWidthM,
        intensityOptions: (x) => FraunhoferOptions(
          positionOnScreenM: x,
          effectiveWavelengthM: effectiveWavelengthM,
          screenDistanceM: screenDistanceM,
          slitWidthM: QwiUnits.mmToM(slitWidthMm),
          slitSeparationM: QwiUnits.mmToM(slitSeparationMm),
          slitSetting: slitConfiguration,
        ),
      );
      if (!hits.tryAdd(hit)) {
        break;
      }
      // PhET: detectorSide = random < 0.5 ? left : right; count if that side has a detector.
      if (detectorsActive) {
        final throughLeft = _random.nextDouble() < 0.5;
        if (throughLeft && slitConfiguration.hasDetectorOnTop) {
          leftDetectorHits++;
        } else if (!throughLeft && slitConfiguration.hasDetectorOnBottom) {
          rightDetectorHits++;
        }
      }
    }
    if (hits.isAtMax) {
      isEmitting = false;
    }
  }

  bool takeSnapshot() {
    return snapshots.tryAdd(
      QwiSnapshot(
        snapshotNumber: snapshots.length + 1,
        hits: List<DetectorHit>.from(hits.hits),
        detectionMode: detectionMode,
        sourceType: sourceType,
        wavelengthNm: wavelengthNm,
        slitSeparationMm: slitSeparationMm,
        screenDistanceM: screenDistanceM,
        screenHalfWidthM: fullScreenHalfWidthM,
        effectiveWavelengthM: effectiveWavelengthM,
        slitSetting: slitConfiguration,
        envelopeCategory: 'brightestAtCenter',
        isEmitting: isEmitting,
        brightness: screenBrightness,
        intensity: sourceStrength,
        slitWidthMm: slitWidthMm,
        intensityDistribution: const [],
      ),
    );
  }

  void _resetParameters() {
    wavelengthNm = QwiConstants.defaultPhotonWavelengthNm;
    particleSpeedMps = defaults.defaultSpeedMps;
    sourceStrength = QwiConstants.experimentDefaultSourceStrength;
    slitSeparationMm = defaults.slitSeparationMm;
    screenDistanceM = QwiConstants.experimentDefaultScreenDistanceM;
    screenBrightness = QwiConstants.defaultScreenBrightness;
    slitConfiguration = SlitConfiguration.bothOpen;
    detectionMode = DetectorMode.intensity;
    isEmitting = false;
  }

  void reset() {
    _resetParameters();
    clearScreen();
    snapshots.clear();
  }
}

/// Top-level Experiment screen model — independent of HI/SP.
class ExperimentModel {
  ExperimentModel({QwiRandom? random}) : random = random ?? SeededQwiRandom(1) {
    scenes = {
      for (final t in SourceType.values) t: ExperimentSceneModel(sourceType: t, random: this.random),
    };
    activeSource = SourceType.photons;
  }

  final QwiRandom random;
  late final Map<SourceType, ExperimentSceneModel> scenes;
  late SourceType activeSource;
  final SimulationClock clock = SimulationClock(speedFactors: TimeSpeedFactors.experiment);
  final DetectorRulerState ruler = DetectorRulerState();
  final GraphZoomState graphZoom = GraphZoomState();

  /// Index into [DetectorScreenScale.options]; default 0 = ±20 mm full view.
  int detectorScreenScaleIndex = DetectorScreenScale.defaultScaleIndex;

  ExperimentSceneModel get scene => scenes[activeSource]!;

  double get visibleDetectorHalfWidthM =>
      DetectorScreenScale.visibleHalfWidthMeters(detectorScreenScaleIndex);

  void selectSource(SourceType type) => activeSource = type;

  void setDetectorScreenScaleIndex(int index) {
    detectorScreenScaleIndex = index.clamp(0, DetectorScreenScale.options.length - 1);
    ruler.scaleHalfWidthMm = DetectorScreenScale.options[detectorScreenScaleIndex].maxMM;
  }

  void step(double wallDt) {
    final dt = clock.advance(wallDt);
    if (dt > 0) {
      scene.step(dt);
    }
  }

  void reset() {
    for (final s in scenes.values) {
      s.reset();
    }
    activeSource = SourceType.photons;
    clock.reset();
    ruler.reset();
    graphZoom.reset();
    detectorScreenScaleIndex = DetectorScreenScale.defaultScaleIndex;
    ruler.scaleHalfWidthMm = DetectorScreenScale.options[detectorScreenScaleIndex].maxMM;
  }
}
