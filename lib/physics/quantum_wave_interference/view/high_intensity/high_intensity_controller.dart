import 'package:flutter/foundation.dart';

import '../../audio/qwi_snapshot_audio.dart';
import '../../constants/qwi_constants.dart';
import '../../data/graph_data.dart';
import '../../data/measurement_plots_state.dart';
import '../../domain/detector_mode.dart';
import '../../domain/slit_configuration.dart';
import '../../domain/source_type.dart';
import '../../domain/time_speed.dart';
import '../../domain/wave_display_mode.dart';
import '../../models/high_intensity_model.dart';
import '../../numerics/analytical_wave_solver.dart';
import '../../numerics/wave_kernel_types.dart';
import '../../render_data/high_intensity/wave_field_render_data.dart';
import '../common/qwi_measurement_plots_mixin.dart';

/// Flutter façade over [HighIntensityModel] — WaveKernel backend only.
class HighIntensityController extends ChangeNotifier with QwiMeasurementPlotsMixin {
  HighIntensityController({
    HighIntensityModel? model,
    QwiSnapshotAudio? snapshotAudio,
  })  : model = model ?? HighIntensityModel(),
        snapshotAudio = snapshotAudio ?? QwiSnapshotAudio();

  final HighIntensityModel model;
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

  HighIntensitySceneModel get scene => model.scene;

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
      _cachedWave = WaveFieldRenderData.sample(scene);
      _waveDirty = false;
      _framesSinceSample = 0;
    }
    return _cachedWave!;
  }

  HiDetectorRenderData get detectorData => HiDetectorRenderData.fromScene(scene);

  HitsHistogramData get hitsHistogram => HitsHistogramData.fromHits(scene.hits.hits);

  void _markWaveDirty() {
    _waveDirty = true;
  }

  void selectSource(SourceType type) {
    model.selectSource(type);
    plots.clearTimeData();
    if (positionPlotVisible) resamplePositionPlot();
    _markWaveDirty();
    notifyListeners();
  }

  void setEmitting(bool on) {
    scene.setEmitting(on);
    _markWaveDirty();
    notifyListeners();
  }

  void toggleEmitting() => setEmitting(!scene.isEmitting);

  void setWavelengthNm(double nm) {
    if (!scene.sourceType.isPhoton) {
      return;
    }
    scene.wavelengthNm = nm.clamp(
      QwiConstants.photonWavelengthPropertyMinNm,
      QwiConstants.photonWavelengthPropertyMaxNm,
    );
    scene.clearScreen();
    if (scene.isEmitting) {
      scene.setEmitting(true);
    }
    _markWaveDirty();
    notifyListeners();
  }

  void setParticleSpeedMps(double speed) {
    if (scene.sourceType.isPhoton) {
      return;
    }
    scene.particleSpeedMps = speed.clamp(scene.speedMinMps, scene.speedMaxMps);
    scene.clearScreen();
    if (scene.isEmitting) {
      scene.setEmitting(true);
    }
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
    if (scene.isEmitting) {
      scene.setEmitting(true);
    }
    _markWaveDirty();
    notifyListeners();
  }

  void setBarrierFractionX(double fraction) {
    scene.solver.barrierFractionX = fraction.clamp(
      QwiConstants.barrierPositionFractionMin,
      QwiConstants.barrierPositionFractionMax,
    );
    scene.clearScreen();
    if (scene.isEmitting) {
      scene.setEmitting(true);
    }
    _markWaveDirty();
    notifyListeners();
  }

  void setScreenBrightness(double b) {
    scene.screenBrightness = b.clamp(0.0, QwiConstants.screenBrightnessMax);
    notifyListeners();
  }

  void setDetectionMode(DetectorMode mode) {
    scene.detectionMode = mode;
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
    if (scene.isEmitting) {
      scene.setEmitting(true);
    }
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

  void stepWall(double wallDt) {
    final beforeHits = scene.hits.length;
    final beforeT = scene.solver.time;
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
    if (scene.solver.time != beforeT || scene.hits.length != beforeHits || plotsDirty) {
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
