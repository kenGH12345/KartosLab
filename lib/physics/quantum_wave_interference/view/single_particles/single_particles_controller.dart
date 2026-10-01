import 'package:flutter/foundation.dart';

import '../../audio/qwi_snapshot_audio.dart';
import '../../constants/qwi_constants.dart';
import '../../data/graph_data.dart';
import '../../data/measurement_plots_state.dart';
import '../../domain/detector_mode.dart';
import '../../domain/probe.dart';
import '../../domain/slit_configuration.dart';
import '../../domain/source_type.dart';
import '../../domain/time_speed.dart';
import '../../domain/wave_display_mode.dart';
import '../../models/single_particles_model.dart';
import '../../numerics/analytical_wave_solver.dart';
import '../../numerics/wave_kernel_types.dart';
import '../../render_data/high_intensity/wave_field_render_data.dart';
import '../common/qwi_measurement_plots_mixin.dart';

/// Flutter façade over [SingleParticlesModel] — Gaussian packet backend only.
class SingleParticlesController extends ChangeNotifier with QwiMeasurementPlotsMixin {
  SingleParticlesController({
    SingleParticlesModel? model,
    QwiSnapshotAudio? snapshotAudio,
  })  : model = model ?? SingleParticlesModel(),
        snapshotAudio = snapshotAudio ?? QwiSnapshotAudio();

  final SingleParticlesModel model;
  final QwiSnapshotAudio snapshotAudio;

  WaveFieldRenderData? _cachedWave;
  /// PhET `isGraphVisibleProperty` — default Screen (false).
  bool graphVisible = false;
  bool snapshotPanelOpen = false;
  bool measuringTapeVisible = false;
  bool stopwatchVisible = false;
  bool timePlotVisible = false;
  bool positionPlotVisible = false;
  bool _waveDirty = true;
  int _framesSinceSample = 0;

  SingleParticlesSceneModel get scene => model.scene;

  @override
  MeasurementPlotsState get plots => model.plots;

  @override
  AnalyticalWaveSolver get plotSolver => scene.solver;

  @override
  WaveSource createPlotSource() => scene.solver.createSource();

  @override
  WaveDisplayMode get plotDisplayMode => scene.waveDisplayMode;

  @override
  double get plotRegionWidth => scene.solver.regionWidth;

  @override
  double get plotRegionHeight => scene.solver.regionHeight;

  WaveFieldRenderData get waveField {
    if (_cachedWave == null || _waveDirty) {
      _cachedWave = WaveFieldRenderData.sampleSp(scene);
      _waveDirty = false;
      _framesSinceSample = 0;
    }
    return _cachedWave!;
  }

  HiDetectorRenderData get detectorData {
    final sp = SpDetectorRenderData.fromScene(scene);
    return HiDetectorRenderData(
      pdf: sp.pdf,
      hits: sp.hits,
      formationFactor: 1,
      brightness: sp.brightness,
      isEmitting: sp.isPacketActive,
      sourceType: sp.sourceType,
      wavelengthNm: sp.wavelengthNm,
      detectionMode: DetectorMode.hits,
    );
  }

  HitsHistogramData get hitsHistogram => HitsHistogramData.fromHits(scene.hits.hits);

  void _markWaveDirty() => _waveDirty = true;

  void selectSource(SourceType type) {
    model.selectSource(type);
    plots.clearTimeData();
    if (positionPlotVisible) resamplePositionPlot();
    _markWaveDirty();
    notifyListeners();
  }

  void fireOnce() {
    scene.fireOnce();
    _markWaveDirty();
    notifyListeners();
  }

  void setAutoRepeat(bool on) {
    scene.setAutoRepeat(on);
    _markWaveDirty();
    notifyListeners();
  }

  void setWavelengthNm(double nm) {
    if (!scene.sourceType.isPhoton) {
      return;
    }
    scene.wavelengthNm = nm.clamp(
      QwiConstants.photonWavelengthPropertyMinNm,
      QwiConstants.photonWavelengthPropertyMaxNm,
    );
    scene.clearScreen();
    _markWaveDirty();
    notifyListeners();
  }

  void setParticleSpeedMps(double speed) {
    if (scene.sourceType.isPhoton) {
      return;
    }
    scene.particleSpeedMps = speed.clamp(scene.speedMinMps, scene.speedMaxMps);
    scene.clearScreen();
    _markWaveDirty();
    notifyListeners();
  }

  void setSlitConfiguration(SlitConfiguration config) {
    scene.setSlitConfiguration(config);
    _markWaveDirty();
    notifyListeners();
  }

  void setSlitSeparationMm(double mm) {
    scene.slitSeparationMm = mm.clamp(scene.slitSeparationMinMm, scene.slitSeparationMaxMm);
    scene.clearScreen();
    _markWaveDirty();
    notifyListeners();
  }

  void setBarrierFractionX(double fraction) {
    scene.solver.barrierFractionX = fraction.clamp(
      QwiConstants.barrierPositionFractionMin,
      QwiConstants.barrierPositionFractionMax,
    );
    _markWaveDirty();
    notifyListeners();
  }

  void setScreenBrightness(double b) {
    scene.screenBrightness = b.clamp(0.0, QwiConstants.screenBrightnessMax);
    notifyListeners();
  }

  void setWaveDisplayMode(WaveDisplayMode mode) {
    scene.setWaveDisplayMode(mode);
    plots.clearTimeData();
    if (positionPlotVisible) resamplePositionPlot();
    _markWaveDirty();
    notifyListeners();
  }

  void setGraphZoom(int level) {
    model.graphZoom.setLevel(level);
    notifyListeners();
  }

  void setPlaying(bool playing) {
    model.clock.isPlaying = playing;
    notifyListeners();
  }

  void setTimeSpeed(TimeSpeed speed) {
    model.clock.setSpeed(speed);
    notifyListeners();
  }

  void stepOnce() {
    model.stepOnce();
    if (timePlotVisible) stepTimePlotIfNeeded(allowSample: true);
    if (positionPlotVisible) resamplePositionPlot();
    _markWaveDirty();
    notifyListeners();
  }

  void clearScreen() {
    scene.clearScreen();
    _markWaveDirty();
    notifyListeners();
  }

  bool takeSnapshot() {
    final ok = scene.takeSnapshot();
    if (ok) {
      snapshotAudio.playSnapshotCaptured();
    }
    notifyListeners();
    return ok;
  }

  void deleteSnapshot(int index) {
    scene.snapshots.deleteAt(index);
    notifyListeners();
  }

  void setGraphVisible(bool v) {
    graphVisible = v;
    notifyListeners();
  }

  void setMeasuringTapeVisible(bool v) {
    measuringTapeVisible = v;
    model.measuringTape.visible = v;
    notifyListeners();
  }

  void setStopwatchVisible(bool v) {
    stopwatchVisible = v;
    model.stopwatch.visible = v;
    notifyListeners();
  }

  void notifyStopwatchChanged() => notifyListeners();

  void notifyPlotsChanged() {
    if (positionPlotVisible) resamplePositionPlot();
    notifyListeners();
  }

  void setTimePlotVisible(bool v) {
    timePlotVisible = v;
    notifyListeners();
  }

  void setPositionPlotVisible(bool v) {
    positionPlotVisible = v;
    if (v) resamplePositionPlot();
    notifyListeners();
  }

  void notifyTapeChanged() => notifyListeners();

  void setSnapshotPanelOpen(bool open) {
    snapshotPanelOpen = open;
    notifyListeners();
  }

  void setProbeVisible(bool v) {
    if (!scene.isProbeAvailable && v) {
      return;
    }
    scene.probeVisible = v;
    notifyListeners();
  }

  void moveProbe(double normX, double normY) {
    scene.detectorProbe.normalizedX = normX.clamp(0.0, 1.0);
    scene.detectorProbe.normalizedY = normY.clamp(0.0, 1.0);
    _onProbeGeometryChanged();
    notifyListeners();
  }

  void performProbeDetect() {
    scene.performDetectorMeasurement();
    _markWaveDirty();
    notifyListeners();
  }

  void performProbeDetectOrReset() {
    if (scene.detectorProbe.state == ProbeState.ready) {
      performProbeDetect();
    } else {
      _resetProbeMeasurementState();
      notifyListeners();
    }
  }

  void setProbeRadius(double r) {
    scene.detectorProbe.radius = r.clamp(0.04, 0.35);
    _onProbeGeometryChanged();
    notifyListeners();
  }

  /// Source: moving/resizing after Detect invalidates result → auto-reset to ready.
  void _onProbeGeometryChanged() {
    if (scene.detectorProbe.state != ProbeState.ready) {
      _resetProbeMeasurementState();
    } else if (scene.isPacketActive && scene.isProbeAvailable) {
      scene.detectorProbe.probability = scene.computeProbeProbability();
    }
  }

  void _resetProbeMeasurementState() {
    final p = (scene.isPacketActive && scene.isProbeAvailable)
        ? scene.computeProbeProbability()
        : 0.0;
    scene.detectorProbe.resetMeasurementState(recomputedProbability: p);
  }

  void stepWall(double wallDt) {
    final beforeHits = scene.hits.length;
    final beforeT = scene.solver.time;
    final beforeActive = scene.isPacketActive;
    model.step(wallDt);
    final dt = model.clock.lastDt;
    var plotsDirty = false;
    if (timePlotVisible && dt > 0) {
      plotsDirty = stepTimePlotIfNeeded(allowSample: true) || plotsDirty;
    }
    if (positionPlotVisible && dt > 0) {
      resamplePositionPlot();
      plotsDirty = true;
    }
    if (scene.solver.time != beforeT ||
        scene.hits.length != beforeHits ||
        scene.isPacketActive != beforeActive ||
        plotsDirty) {
      _framesSinceSample++;
      if (_framesSinceSample >= 2 || !model.clock.isPlaying) {
        _markWaveDirty();
      }
      notifyListeners();
    }
  }

  void resampleWave() {
    _markWaveDirty();
    // ignore: unnecessary_statements
    waveField;
    notifyListeners();
  }

  void reset() {
    model.reset();
    graphVisible = false;
    snapshotPanelOpen = false;
    measuringTapeVisible = false;
    stopwatchVisible = false;
    timePlotVisible = false;
    positionPlotVisible = false;
    _markWaveDirty();
    notifyListeners();
  }

  @override
  void dispose() {
    snapshotAudio.dispose();
    super.dispose();
  }
}
