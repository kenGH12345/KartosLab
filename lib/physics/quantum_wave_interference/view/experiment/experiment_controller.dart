import 'package:flutter/foundation.dart';

import '../../audio/qwi_snapshot_audio.dart';
import '../../constants/qwi_constants.dart';
import '../../domain/detector_mode.dart';
import '../../domain/slit_configuration.dart';
import '../../domain/source_type.dart';
import '../../domain/time_speed.dart';
import '../../models/experiment_model.dart';
import '../../render_data/experiment/detector_render_data.dart';
import '../../render_data/experiment/fraunhofer_render_data.dart';

/// Flutter [ChangeNotifier] façade over pure [ExperimentModel].
///
/// All user actions go through this controller → model → solver → render data.
class ExperimentController extends ChangeNotifier {
  ExperimentController({
    ExperimentModel? model,
    QwiSnapshotAudio? snapshotAudio,
  })  : model = model ?? ExperimentModel(),
        snapshotAudio = snapshotAudio ?? QwiSnapshotAudio();

  final ExperimentModel model;
  final QwiSnapshotAudio snapshotAudio;

  bool graphExpanded = false;
  bool snapshotPanelOpen = false;

  ExperimentSceneModel get scene => model.scene;

  DetectorRenderData get detectorRenderData => DetectorRenderData.fromModel(model);

  FraunhoferRenderData get fraunhoferRenderData => FraunhoferRenderData.fromScene(
        scene,
        visibleHalfWidthM: model.visibleDetectorHalfWidthM,
      );

  void selectSource(SourceType type) {
    model.selectSource(type);
    notifyListeners();
  }

  void setEmitting(bool on) {
    scene.setEmitting(on);
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
    scene.onPhysicsParameterChanged();
    notifyListeners();
  }

  void setParticleSpeedMps(double speed) {
    if (scene.sourceType.isPhoton) {
      return;
    }
    scene.particleSpeedMps = speed.clamp(scene.defaults.speedMinMps, scene.defaults.speedMaxMps);
    scene.onPhysicsParameterChanged();
    notifyListeners();
  }

  void setSourceStrength(double strength) {
    scene.sourceStrength = strength.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setSlitConfiguration(SlitConfiguration config) {
    if (config == SlitConfiguration.noBarrier) {
      return; // Experiment never allows noBarrier
    }
    scene.slitConfiguration = config;
    scene.onPhysicsParameterChanged();
    notifyListeners();
  }

  void setSlitSeparationMm(double mm) {
    scene.slitSeparationMm = mm.clamp(scene.defaults.slitSeparationMinMm, scene.defaults.slitSeparationMaxMm);
    scene.onPhysicsParameterChanged();
    notifyListeners();
  }

  void setScreenDistanceM(double meters) {
    scene.screenDistanceM = meters.clamp(
      QwiConstants.experimentScreenDistanceMinM,
      QwiConstants.experimentScreenDistanceMaxM,
    );
    scene.onPhysicsParameterChanged();
    notifyListeners();
  }

  void setScreenBrightness(double brightness) {
    scene.screenBrightness = brightness.clamp(0.0, QwiConstants.screenBrightnessMax);
    notifyListeners();
  }

  void setDetectionMode(DetectorMode mode) {
    scene.detectionMode = mode;
    notifyListeners();
  }

  void setDetectorScreenScaleIndex(int index) {
    model.setDetectorScreenScaleIndex(index);
    notifyListeners();
  }

  void setGraphZoomLevel(int level) {
    model.graphZoom.setLevel(level);
    notifyListeners();
  }

  void setPlaying(bool playing) {
    model.clock.isPlaying = playing;
    notifyListeners();
  }

  void setTimeSpeed(TimeSpeed speed) {
    // Experiment UI exposes NORMAL + FAST only (PhET TimeControlNode).
    if (speed == TimeSpeed.slow) {
      speed = TimeSpeed.normal;
    }
    model.clock.setSpeed(speed);
    notifyListeners();
  }

  void clearScreen() {
    scene.clearScreen();
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

  void setRulerVisible(bool visible) {
    model.ruler.visible = visible;
    notifyListeners();
  }

  void setRulerPosition(double x, double y) {
    model.ruler.positionX = x;
    model.ruler.positionY = y;
    notifyListeners();
  }

  void setGraphExpanded(bool expanded) {
    graphExpanded = expanded;
    notifyListeners();
  }

  void setSnapshotPanelOpen(bool open) {
    snapshotPanelOpen = open;
    notifyListeners();
  }

  /// Wall-clock tick from Flutter [SimulationClock].
  void stepWall(double wallDt) {
    final before = scene.hits.length;
    model.step(wallDt);
    if (scene.hits.length != before || model.clock.isPlaying) {
      notifyListeners();
    }
  }

  void reset() {
    model.reset();
    graphExpanded = false;
    snapshotPanelOpen = false;
    notifyListeners();
  }

  @override
  void dispose() {
    snapshotAudio.dispose();
    super.dispose();
  }
}
