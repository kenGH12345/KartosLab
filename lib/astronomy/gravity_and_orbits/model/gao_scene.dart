/// One orbital scene — port of `GravityAndOrbitsScene.ts` (model half).
library;

import '../gao_constants.dart';
import '../physics/physics_engine.dart';
import 'gao_body.dart';
import 'gao_vec.dart';
import 'mode_config.dart';

class GaoScene {
  GaoScene.fromConfig(ModeConfigResult config)
      : id = config.id,
        defaultZoomScale = config.zoom,
        forceScale = config.forceScale,
        velocityVectorScale = config.velocityVectorScale,
        gridSpacing = config.gridSpacing,
        gridCenter = config.gridCenter.copy(),
        timeInDays = config.timeInDays,
        measuringTapeStart = config.measuringTapeStart?.copy(),
        measuringTapeEnd = config.measuringTapeEnd?.copy(),
        _initialTapeStart = config.measuringTapeStart?.copy(),
        _initialTapeEnd = config.measuringTapeEnd?.copy(),
        engine = GaoPhysicsEngine(
          baseDtValue: config.dt,
          adjustMoonOrbit: config.adjustMoonOrbit,
        ) {
    for (final c in config.bodies) {
      engine.addBody(GaoBody.fromConfig(c));
    }
    zoomLevel = 1;
  }

  final GaoSceneId id;
  final double defaultZoomScale;
  final double forceScale;
  final double velocityVectorScale;
  final double gridSpacing;
  final GaoVec gridCenter;
  final bool timeInDays;
  final GaoVec? measuringTapeStart;
  final GaoVec? measuringTapeEnd;
  final GaoVec? _initialTapeStart;
  final GaoVec? _initialTapeEnd;
  final GaoPhysicsEngine engine;

  double zoomLevel = 1;
  bool active = false;

  List<GaoBody> get bodies => engine.bodies;

  void setTimeSpeed(GaoTimeSpeed speed) => engine.timeSpeed = speed;

  void setGravityEnabled(bool enabled) {
    engine.gravityEnabled = enabled;
    engine.updateForceVectors();
  }

  double stepModel() => engine.stepModel();

  void resetScene() {
    engine.resetAll();
    zoomLevel = 1;
    _restoreMeasuringTape();
  }

  void _restoreMeasuringTape() {
    final start = measuringTapeStart;
    final end = measuringTapeEnd;
    final iStart = _initialTapeStart;
    final iEnd = _initialTapeEnd;
    if (start != null && iStart != null) {
      start.setFrom(iStart);
    }
    if (end != null && iEnd != null) {
      end.setFrom(iEnd);
    }
  }

  void rewind() => engine.rewindAll();

  void clearSimulationTime() => engine.simulationTime = 0;

  void saveRewindPoint() {
    for (final body in bodies) {
      body.saveRewindState();
    }
  }
}
