/// Controller: PEFRL + Lab preset state machine.
///
/// [MSS-SOURCE] `MySolarSystemModel` / `LabModel` / `CenterOfMass`
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../config/mss_scenario.dart';
import '../config/mss_scenario_manager.dart';
import '../config/simulation_config.dart';
import '../my_solar_system_colors.dart';
import '../my_solar_system_constants.dart';
import '../model/body_info.dart';
import '../model/celestial_body.dart';
import '../model/center_of_mass.dart';
import '../model/mss_vec.dart';
import '../model/time_speed.dart';
import '../render/constrain_drag_point.dart';
import '../render/mss_mvt.dart';
import '../render/velocity_vector.dart';
import '../solver/numerical_engine.dart';

class MySolarSystemController extends ChangeNotifier {
  MySolarSystemController({
    required this.isLab,
    MssScenario? initialScenario,
    List<MssScenario> catalog = const [],
    this.config = SimulationConfig.instance,
  }) : catalog = List.unmodifiable(catalog) {
    final scenario = initialScenario ?? MssScenarioManager.sunPlanetFallback();
    _slotCount = isLab
        ? MySolarSystemConstants.labBodiesMax
        : MySolarSystemConstants.introBodiesFixed;
    _defaultScenarioId = scenario.scenarioId;
    _slotDefaults = [
      BodyInfo(
        mass: 250,
        position: MssVec(0, 0),
        velocity: MssVec(0, -2.3446),
      ),
      BodyInfo(
        mass: 25,
        position: MssVec(2, 0),
        velocity: MssVec(0, 23.4457),
      ),
      if (isLab) ...[
        for (final b in MssScenarioManager.labInactiveSlots())
          BodyInfo(
            mass: b.mass,
            position: b.position.copy(),
            velocity: b.velocity.copy(),
            isActive: true,
          ),
      ],
    ];
    bodies = _allocateSlots();
    engine = NumericalEngine(activeBodies);
    loadScenario(scenario);
  }

  final bool isLab;
  final List<MssScenario> catalog;
  final SimulationConfig config;

  late final List<CelestialBody> bodies;
  late final NumericalEngine engine;
  late final int _slotCount;
  late final String _defaultScenarioId;
  late final List<BodyInfo> _slotDefaults;

  bool isPlaying = false;
  double timeYears = 0;
  int zoomLevel = MySolarSystemConstants.zoomLevelDefault;
  TimeSpeed timeSpeed = TimeSpeed.normal;
  String currentScenarioId = 'sun_planet';
  bool addingPathPoints = true;
  bool isAnyBodyCollided = false;
  bool _changingNumberOfBodies = false;

  // Visibility — [KEPLER-SECONDARY] parent defaults + [MSS-SOURCE] CoM/MoreData
  bool velocityVisible = true;
  bool gravityVisible = false;
  bool pathVisible = true;
  bool gridVisible = false;
  bool measuringTapeVisible = false;
  bool centerOfMassVisible = false;
  bool moreDataVisible = false;

  double gravityForceScalePower =
      MySolarSystemConstants.gravityScalePowerDefault;

  MssVec tapeBase = MssVec(
    MySolarSystemConstants.tapeDefaultBaseX,
    MySolarSystemConstants.tapeDefaultBaseY,
  );
  MssVec tapeTip = MssVec(
    MySolarSystemConstants.tapeDefaultTipX,
    MySolarSystemConstants.tapeDefaultTipY,
  );

  int? draggingBodyIndex;
  bool draggingVelocity = false;

  List<BodyInfo> _starting = [];

  List<CelestialBody> get activeBodies =>
      [for (final b in bodies) if (b.isActive) b];

  int get numberOfActiveBodies => activeBodies.length;

  double get zoomScale => config.zoomScaleForLevel(zoomLevel);

  double get timeSpeedScale {
    switch (timeSpeed) {
      case TimeSpeed.fast:
        return MySolarSystemConstants.timeSpeedFast;
      case TimeSpeed.normal:
        return MySolarSystemConstants.timeSpeedNormal;
      case TimeSpeed.slow:
        return MySolarSystemConstants.timeSpeedSlow;
    }
  }

  double get velocityArrowScale => config.velocityToViewMultiplier;

  double get gravityArrowScale =>
      config.gravityArrowScale(gravityForceScalePower);

  CenterOfMassState get centerOfMass =>
      CenterOfMassState.fromBodies(activeBodies);

  /// [MSS-SOURCE] following ⇔ |r|<1 && |v|<0.01
  bool get isFollowingCenterOfMass {
    final com = centerOfMass;
    return com.position.magnitude < config.followComPositionMax &&
        com.velocity.magnitude < config.followComSpeedMax;
  }

  bool get showFollowCenterOfMassButton => !isFollowingCenterOfMass;

  /// [MSS-SOURCE] bodiesAreReturnable = any offscreen OR any collided
  bool get bodiesAreReturnable {
    if (isAnyBodyCollided) return true;
    for (final b in activeBodies) {
      if (b.isOffscreen) return true;
    }
    return false;
  }

  /// [KEPLER-SECONDARY] log10(|F|) < 3.2 - scalePower
  bool get isAnyGravityForceOffscale {
    if (!gravityVisible) return false;
    for (final b in activeBodies) {
      final mag = b.gravityForce.magnitude;
      if (mag <= 0) return true;
      final magnitudeLog = math.log(mag) / math.ln10;
      if (magnitudeLog <
          MySolarSystemConstants.gravityOffscaleLogThreshold -
              gravityForceScalePower) {
        return true;
      }
    }
    return false;
  }

  bool get showOffscaleMessage => gravityVisible && isAnyGravityForceOffscale;

  List<MssScenario> get comboScenarios => [
        for (final s in catalog)
          if (s.comboVisible) s,
      ];

  MssScenario get comboSelection {
    if (currentScenarioId == 'custom') {
      for (final s in catalog) {
        if (s.scenarioId == 'custom') return s;
      }
      return const MssScenario(
        scenarioId: 'custom',
        name: 'Custom',
        comboVisible: true,
        bodies: [],
      );
    }
    for (final s in comboScenarios) {
      if (s.scenarioId == currentScenarioId) return s;
    }
    return comboScenarios.first;
  }

  /// Unified Lab → CUSTOM. [MSS-SOURCE] LabModel.userInteractingEmitter
  void markUserInteraction() {
    if (isLab && currentScenarioId != 'custom') {
      currentScenarioId = 'custom';
    }
  }

  void loadScenario(MssScenario scenario) {
    if (scenario.scenarioId == 'custom' && scenario.bodies.isEmpty) {
      currentScenarioId = 'custom';
      notifyListeners();
      return;
    }
    // [MSS-SOURCE] LabModel link — not visibility/zoom/tape/speed
    currentScenarioId = scenario.scenarioId;
    isPlaying = false;
    timeYears = 0;
    isAnyBodyCollided = false;
    _applyBodyInfo(scenario.bodies);
    engine.update(activeBodies);
    for (final b in bodies) {
      b.clearPath();
    }
    if (isLab &&
        scenario.scenarioId != 'custom' &&
        !scenario.scenarioId.startsWith('orbital_system_')) {
      followCenterOfMass();
    }
    gravityForceScalePower = MySolarSystemConstants.gravityScalePowerDefault;
    if (scenario.gravityForceScalePower != null) {
      gravityForceScalePower = scenario.gravityForceScalePower!;
    }
    _saveStarting();
    notifyListeners();
  }

  void selectOrbitalSystem(MssScenario scenario) => loadScenario(scenario);

  void _applyBodyInfo(List<BodyInfo> infos) {
    for (var i = 0; i < bodies.length; i++) {
      if (i < infos.length) {
        bodies[i].applyInfo(infos[i]);
      } else {
        bodies[i].isActive = false;
        bodies[i].clearPath();
      }
    }
  }

  List<CelestialBody> _allocateSlots() {
    return [
      for (var i = 0; i < _slotCount; i++)
        CelestialBody(
          index: i + 1,
          mass: _slotDefaults[i].mass,
          position: _slotDefaults[i].position.copy(),
          velocity: _slotDefaults[i].velocity.copy(),
          color: MySolarSystemColors.bodyColor(i + 1),
          isActive: i < 2,
        ),
    ];
  }

  void setNumberOfActiveBodies(int n) {
    if (!isLab) return;
    final target = n.clamp(
      MySolarSystemConstants.labBodiesMin,
      MySolarSystemConstants.labBodiesMax,
    );
    if (target == numberOfActiveBodies) return;
    isPlaying = false;
    markUserInteraction();
    _changingNumberOfBodies = true;
    var guard = 0;
    while (numberOfActiveBodies != target && guard++ < _slotCount) {
      if (target > numberOfActiveBodies) {
        addNextBody();
      } else {
        removeLastBody();
      }
    }
    _changingNumberOfBodies = false;
    notifyListeners();
  }

  void addNextBody() {
    CelestialBody? newBody;
    for (final b in bodies) {
      if (!b.isActive) {
        newBody = b;
        break;
      }
    }
    if (newBody == null) return;
    final slot = newBody.index - 1;
    newBody.applyInfo(_slotDefaults[slot]);
    newBody.isActive = false;
    newBody.preventCollision(activeBodies);
    newBody.isActive = true;
    if (!_changingNumberOfBodies) {
      isPlaying = false;
      markUserInteraction();
    }
    isAnyBodyCollided = false;
    engine.update(activeBodies);
    _saveStarting();
    if (!_changingNumberOfBodies) notifyListeners();
  }

  void removeLastBody() {
    if (numberOfActiveBodies <= MySolarSystemConstants.labBodiesMin) return;
    final last = activeBodies.last;
    last.isActive = false;
    last.clearPath();
    if (!_changingNumberOfBodies) {
      isPlaying = false;
      markUserInteraction();
    }
    isAnyBodyCollided = false;
    engine.update(activeBodies);
    _saveStarting();
    if (!_changingNumberOfBodies) notifyListeners();
  }

  void stepOnce(double dt) {
    dt *= timeSpeedScale;
    final numberOfSteps =
        (dt * MySolarSystemConstants.desiredStepsPerSecond).ceil().clamp(1, 1000);
    dt /= numberOfSteps;
    dt *= MySolarSystemConstants.engineTimeScale;
    engine.bodies = activeBodies;
    for (var i = 0; i < numberOfSteps; i++) {
      final notify = i == numberOfSteps - 1;
      final before = numberOfActiveBodies;
      engine.run(dt, notifyPropertyListeners: notify);
      engine.checkCollisions();
      if (numberOfActiveBodies < before) isAnyBodyCollided = true;
      timeYears += dt * MySolarSystemConstants.modelToViewTime;
      if (addingPathPoints && pathVisible) {
        for (final body in activeBodies) {
          body.addPathPoint();
        }
      }
    }
    notifyListeners();
  }

  void tick(double dt) {
    if (isPlaying) stepOnce(dt);
  }

  void play() {
    isPlaying = true;
    notifyListeners();
  }

  void pause() {
    isPlaying = false;
    notifyListeners();
  }

  void togglePlay() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void stepForward() {
    isPlaying = false;
    stepOnce(MySolarSystemConstants.stepButtonDt);
  }

  void restart() {
    isPlaying = false;
    timeYears = 0;
    isAnyBodyCollided = false;
    _applyBodyInfo(_starting);
    engine.update(activeBodies);
    for (final b in bodies) {
      b.clearPath();
    }
    notifyListeners();
  }

  void returnBodies() => restart();

  void resetAll() {
    moreDataVisible = false;
    centerOfMassVisible = false;
    gravityVisible = false;
    gridVisible = false;
    measuringTapeVisible = false;
    velocityVisible = true;
    pathVisible = true;
    zoomLevel = MySolarSystemConstants.zoomLevelDefault;
    timeSpeed = TimeSpeed.normal;
    gravityForceScalePower = MySolarSystemConstants.gravityScalePowerDefault;
    tapeBase = MssVec(
      MySolarSystemConstants.tapeDefaultBaseX,
      MySolarSystemConstants.tapeDefaultBaseY,
    );
    tapeTip = MssVec(
      MySolarSystemConstants.tapeDefaultTipX,
      MySolarSystemConstants.tapeDefaultTipY,
    );
    isAnyBodyCollided = false;
    if (isLab) currentScenarioId = 'custom';
    MssScenario? found;
    for (final s in catalog) {
      if (s.scenarioId == _defaultScenarioId) {
        found = s;
        break;
      }
    }
    loadScenario(found ?? MssScenarioManager.sunPlanetFallback());
  }

  void setTimeSpeed(TimeSpeed speed) {
    timeSpeed = speed;
    notifyListeners();
  }

  void clearSimulation() {
    timeYears = 0;
    for (final b in bodies) {
      b.clearPath();
    }
    notifyListeners();
  }

  void clearTime() => clearSimulation();

  void setZoomLevel(int level) {
    zoomLevel = level.clamp(
      MySolarSystemConstants.zoomLevelMin,
      MySolarSystemConstants.zoomLevelMax,
    );
    notifyListeners();
  }

  void zoomIn() => setZoomLevel(zoomLevel + 1);
  void zoomOut() => setZoomLevel(zoomLevel - 1);

  void setGravityForceScalePower(double power) {
    var p = power.clamp(
      MySolarSystemConstants.gravityScalePowerMin,
      MySolarSystemConstants.gravityScalePowerMax,
    );
    gravityForceScalePower = p;
    notifyListeners();
  }

  // ── Visibility ───────────────────────────────────────────────────────────

  void setMoreDataVisible(bool v) {
    moreDataVisible = v;
    notifyListeners();
  }

  void setCenterOfMassVisible(bool v) {
    centerOfMassVisible = v;
    notifyListeners();
  }

  void setGravityVisible(bool v) {
    gravityVisible = v;
    notifyListeners();
  }

  void setGridVisible(bool v) {
    gridVisible = v;
    notifyListeners();
  }

  void setMeasuringTapeVisible(bool v) {
    measuringTapeVisible = v;
    notifyListeners();
  }

  void setVelocityVisible(bool v) {
    velocityVisible = v;
    notifyListeners();
  }

  void setPathVisible(bool v) {
    pathVisible = v;
    if (!v) {
      for (final b in bodies) {
        b.clearPath();
      }
    }
    notifyListeners();
  }

  // ── Mass / position / velocity edits ──────────────────────────────────────

  /// [MSS-SOURCE] mass edit does NOT pause; Lab → CUSTOM.
  void setBodyMass(int index, double mass) {
    final body = bodies[index];
    body.mass = config.clampMassUi(mass);
    markUserInteraction();
    engine.bodies = activeBodies;
    engine.updateForces();
    _saveStarting();
    notifyListeners();
  }

  void setBodyPositionComponent(int index, {double? x, double? y}) {
    final body = bodies[index];
    isPlaying = false;
    if (x != null) {
      body.position.x = x.clamp(
        MySolarSystemConstants.positionXMin,
        MySolarSystemConstants.positionXMax,
      );
    }
    if (y != null) {
      body.position.y = y.clamp(
        MySolarSystemConstants.positionYMin,
        MySolarSystemConstants.positionYMax,
      );
    }
    body.clearPath();
    markUserInteraction();
    engine.bodies = activeBodies;
    engine.updateForces();
    _saveStarting();
    notifyListeners();
  }

  void setBodyVelocityComponent(int index, {double? vx, double? vy}) {
    final body = bodies[index];
    isPlaying = false;
    if (vx != null) {
      body.velocity.x = vx.clamp(
        MySolarSystemConstants.velocityComponentMin,
        MySolarSystemConstants.velocityComponentMax,
      );
    }
    if (vy != null) {
      body.velocity.y = vy.clamp(
        MySolarSystemConstants.velocityComponentMin,
        MySolarSystemConstants.velocityComponentMax,
      );
    }
    for (final b in bodies) {
      b.clearPath();
    }
    markUserInteraction();
    engine.bodies = activeBodies;
    engine.updateForces();
    _saveStarting();
    notifyListeners();
  }

  // ── CoM ──────────────────────────────────────────────────────────────────

  /// [MSS-SOURCE] only subtract CoM velocity (preset load).
  void followCenterOfMass() {
    final com = centerOfMass;
    for (final b in activeBodies) {
      b.velocity.subtract(com.velocity);
    }
    engine.bodies = activeBodies;
    engine.updateForces();
  }

  /// [MSS-SOURCE] pause → shift r/v → clear paths → maybe resume.
  void followAndCenterCenterOfMass() {
    final wasPlaying = isPlaying;
    isPlaying = false;
    final com = centerOfMass;
    for (final b in activeBodies) {
      b.clearPath();
      b.position.subtract(com.position);
      b.velocity.subtract(com.velocity);
    }
    engine.bodies = activeBodies;
    engine.updateForces();
    if (wasPlaying) isPlaying = true;
    notifyListeners();
  }

  // ── Drag ─────────────────────────────────────────────────────────────────

  void beginBodyPositionDrag(int index) {
    draggingBodyIndex = index;
    draggingVelocity = false;
    isPlaying = false;
    bodies[index].clearPath();
    markUserInteraction();
    notifyListeners();
  }

  void beginBodyVelocityDrag(int index) {
    draggingBodyIndex = index;
    draggingVelocity = true;
    isPlaying = false;
    markUserInteraction();
    notifyListeners();
  }

  void updateBodyPosition(
    int index,
    MssVec proposed, {
    required Size canvasSize,
    required MssMvt mvt,
  }) {
    final body = bodies[index];
    final rView = mvt
        .toViewDelta(body.radius)
        .clamp(config.bodyViewRadiusMin, config.bodyViewRadiusMax);
    final next = constrainDragPoint(
      modelPoint: proposed,
      canvasSize: canvasSize,
      mvt: mvt,
      bodyRadiusView: rView,
    );
    body.position.setFrom(next);
    engine.bodies = activeBodies;
    engine.updateForces();
    notifyListeners();
  }

  void updateBodyVelocityFromViewTip(
    int index,
    Offset localView, {
    required MssMvt mvt,
  }) {
    final body = bodies[index];
    final tip = mvt.toModel(localView);
    final raw = velocityFromTip(body.position, tip);
    body.velocity.setFrom(constrainVelocityMagnitude(raw));
    engine.bodies = activeBodies;
    engine.updateForces();
    notifyListeners();
  }

  void endBodyDrag() {
    draggingBodyIndex = null;
    draggingVelocity = false;
    _saveStarting();
    notifyListeners();
  }

  // ── Tape ─────────────────────────────────────────────────────────────────

  void setTapeBase(MssVec p) {
    tapeBase = p;
    notifyListeners();
  }

  void setTapeTip(MssVec p) {
    tapeTip = p;
    notifyListeners();
  }

  double get tapeDistance => tapeBase.distance(tapeTip);

  void _saveStarting() {
    _starting = [
      for (final b in bodies)
        BodyInfo(
          mass: b.mass,
          position: b.position.copy(),
          velocity: b.velocity.copy(),
          isActive: b.isActive,
        ),
    ];
  }
}
