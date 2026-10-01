/// Screen-level model — port of `GravityAndOrbitsModel.ts`.
library;

import '../gao_constants.dart';
import 'gao_scene.dart';
import 'mode_config.dart';

class GaoModel {
  GaoModel({required this.isModelScreen})
      : showMassCheckbox = !isModelScreen,
        showMeasuringTape = !isModelScreen {
    final configs = buildSceneConfigs(isModelScreen: isModelScreen);
    scenes = [for (final c in configs) GaoScene.fromConfig(c)];
    sceneIndex = 0;
    scenes[0].active = true;
    _syncSceneFlags();
  }

  final bool isModelScreen;
  final bool showMassCheckbox;
  final bool showMeasuringTape;

  late final List<GaoScene> scenes;
  int sceneIndex = 0;

  bool showGravityForce = false;
  bool showVelocity = false;
  bool showPath = false;
  bool showGrid = false;
  bool showMass = false;
  bool showMeasuringTapeFlag = false;
  bool isPlaying = false;
  bool gravityEnabled = true;
  GaoTimeSpeed timeSpeed = GaoTimeSpeed.normal;

  GaoScene get scene => scenes[sceneIndex];

  void selectScene(int index) {
    if (index < 0 || index >= scenes.length) return;
    scenes[sceneIndex].active = false;
    sceneIndex = index;
    scenes[sceneIndex].active = true;
    _syncSceneFlags();
  }

  void selectSceneById(GaoSceneId id) {
    final i = scenes.indexWhere((s) => s.id == id);
    if (i >= 0) selectScene(i);
  }

  void setPlaying(bool playing) => isPlaying = playing;

  void setTimeSpeed(GaoTimeSpeed speed) {
    timeSpeed = speed;
    for (final s in scenes) {
      s.setTimeSpeed(speed);
    }
  }

  void setGravityEnabled(bool enabled) {
    gravityEnabled = enabled;
    for (final s in scenes) {
      s.setGravityEnabled(enabled);
    }
  }

  void setShowPath(bool value) {
    if (value && !showPath) {
      scene.engine.clearPaths();
    }
    showPath = value;
  }

  /// Wall-clock step from SimulationClock (capped at 1s like source).
  void step(double wallDt) {
    assert(wallDt.isFinite);
    for (final body in scene.bodies) {
      if (body.isCollided) {
        body.clockTicksSinceExplosion += 1;
      }
    }
    if (isPlaying) {
      scene.stepModel();
    }
  }

  /// Paused single-frame step (`stepClockWhilePaused` → EventTimer at 60fps).
  void stepWhilePaused() {
    scene.stepModel();
  }

  void rewind() => scene.rewind();

  void resetAll() {
    showGravityForce = false;
    showVelocity = false;
    showPath = false;
    showGrid = false;
    showMass = false;
    showMeasuringTapeFlag = false;
    isPlaying = false;
    timeSpeed = GaoTimeSpeed.normal;
    gravityEnabled = true;
    sceneIndex = 0;
    for (var i = 0; i < scenes.length; i++) {
      scenes[i].active = i == 0;
      scenes[i].resetScene();
      scenes[i].setTimeSpeed(GaoTimeSpeed.normal);
      scenes[i].setGravityEnabled(true);
    }
  }

  void resetActiveScene() => scene.resetScene();

  void _syncSceneFlags() {
    scene.setTimeSpeed(timeSpeed);
    scene.setGravityEnabled(gravityEnabled);
  }
}
