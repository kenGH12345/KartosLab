/// Controller: time, drag, reset/restart. Owns live bodies + engine.
///
/// [已确认] `KeplersLawsModel.ts` step / reset / restart / alwaysCircular
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../keplers_laws_constants.dart';
import '../keplers_laws_colors.dart';
import '../model/body_info.dart';
import '../model/elliptical_orbit_engine.dart';
import '../model/kl_vec.dart';
import '../model/keplers_laws_visible.dart';
import '../model/law_mode.dart';
import '../model/orbit_body.dart';
import '../model/orbital_area.dart';
import '../model/period_tracker.dart';
import '../model/target_orbit.dart';
import '../model/time_speed.dart';

class KeplersLawsController extends ChangeNotifier {
  KeplersLawsController({
    required this.initialLaw,
    this.isAllLaws = false,
  }) : selectedLaw = initialLaw {
    sun = OrbitBody(
      index: 1,
      mass: KeplersLawsConstants.massOfOurSun,
      position: KlVec.zero,
      velocity: KlVec.zero,
    );
    planet = OrbitBody(
      index: 2,
      mass: KeplersLawsConstants.planetMass,
      position: const KlVec(
        KeplersLawsConstants.defaultPlanetX,
        KeplersLawsConstants.defaultPlanetY,
      ),
      velocity: const KlVec(
        KeplersLawsConstants.defaultPlanetVx,
        KeplersLawsConstants.defaultPlanetVy,
      ),
    );
    engine = EllipticalOrbitEngine(sun: sun, planet: planet);
    periodTracker = PeriodTracker(engine);
    engine.refreshMu();
    engine.update();
    minVisitedAxis = engine.a;
    maxVisitedAxis = engine.a;
    _saveStarting();
    lastLaw = selectedLaw;
  }

  final LawMode initialLaw;
  final bool isAllLaws;

  late final OrbitBody sun;
  late final OrbitBody planet;
  late final EllipticalOrbitEngine engine;
  late final PeriodTracker periodTracker;
  final visible = KeplersLawsVisible();

  LawMode selectedLaw;
  late LawMode lastLaw;
  bool alwaysCircular = false;
  int periodDivisions = KeplersLawsConstants.periodDivisionsDefault;
  TargetOrbit targetOrbit = TargetOrbit.none;
  int selectedAxisPower = 1;
  int selectedPeriodPower = 1;
  TimeSpeed timeSpeed = TimeSpeed.normal;
  bool isPlaying = false;
  bool hasPlayed = false;
  double timeYears = 0;
  bool stopwatchRunning = false;
  double stopwatchTime = 0;
  Offset stopwatchOffset = Offset.zero;
  int zoomLevel = KeplersLawsConstants.zoomLevelDefault;
  double zoomScale = KeplersLawsConstants.zoomScaleMax;
  double gravityForceScalePower = KeplersLawsConstants.gravityScalePowerDefault;
  KlVec tapeBase = const KlVec(
    KeplersLawsConstants.tapeBaseX,
    KeplersLawsConstants.tapeBaseY,
  );
  KlVec tapeTip = const KlVec(
    KeplersLawsConstants.tapeTipX,
    KeplersLawsConstants.tapeTipY,
  );
  double minVisitedAxis = 0;
  double maxVisitedAxis = 0;
  bool userHasInteracted = false;
  bool resetting = false;
  bool restarting = false;
  bool steppingForward = false;

  BodyInfo? _startingSun;
  BodyInfo? _startingPlanet;

  bool get hasFirstLawFeatures => isAllLaws || initialLaw == LawMode.first;
  bool get hasSecondLawFeatures => isAllLaws || initialLaw == LawMode.second;
  bool get hasThirdLawFeatures => isAllLaws || initialLaw == LawMode.third;

  bool get isFirstLaw => selectedLaw == LawMode.first;
  bool get isSecondLaw => selectedLaw == LawMode.second;
  bool get isThirdLaw => selectedLaw == LawMode.third;

  bool get isSolarSystem => sun.mass == KeplersLawsConstants.massOfOurSun;

  bool get correctPowersSelected =>
      selectedAxisPower == 3 && selectedPeriodPower == 2;

  double get poweredSemiMajorAxis =>
      mathPow(engine.a, selectedAxisPower);
  double get poweredPeriod => mathPow(engine.T, selectedPeriodPower);

  double? get thirdLawEquationResult {
    if (!engine.allowedOrbit) return null;
    return poweredPeriod / poweredSemiMajorAxis;
  }

  double get timeScale {
    switch (timeSpeed) {
      case TimeSpeed.fast:
        return KeplersLawsConstants.timeSpeedFast;
      case TimeSpeed.normal:
        return KeplersLawsConstants.timeSpeedNormal;
      case TimeSpeed.slow:
        return KeplersLawsConstants.timeSpeedSlow;
    }
  }

  Color areaColor(OrbitalArea area) {
    final colors = KeplersLawsColors.orbitalAreaColors;
    final numAreas = periodDivisions;
    final active = engine.activeAreaIndex;
    var indexDiff = engine.retrograde
        ? area.index - active
        : active - area.index;
    indexDiff = _mod(indexDiff, numAreas);
    var colorIndex = indexDiff;
    if (numAreas < colors.length) {
      colorIndex = (indexDiff * colors.length / numAreas).floor();
    }
    if (indexDiff == numAreas - 1) {
      colorIndex = colors.length - 1;
    }
    return colors[colorIndex];
  }

  int _mod(int v, int n) {
    if (n == 0) return 0;
    return ((v % n) + n) % n;
  }

  void selectLaw(LawMode law) {
    if (!isAllLaws) return;
    visible.saveAndDisable(lastLaw);
    selectedLaw = law;
    visible.restore(law);
    lastLaw = law;
    notifyListeners();
  }

  void setAlwaysCircular(bool value) {
    alwaysCircular = value;
    engine.alwaysCircles = value;
    if (value) {
      engine.reset();
    } else {
      engine.update();
    }
    notifyListeners();
  }

  void setPeriodDivisions(int n) {
    periodDivisions = n.clamp(
      KeplersLawsConstants.periodDivisionsMin,
      KeplersLawsConstants.periodDivisionsMax,
    );
    engine.periodDivisions = periodDivisions;
    engine.resetOrbitalAreas(eraseAreas: isPlaying);
    notifyListeners();
  }

  void setPlaying(bool playing) {
    if (playing && !engine.allowedOrbit) return;
    isPlaying = playing;
    if (playing) userHasInteracted = true;
    notifyListeners();
  }

  void togglePlay() => setPlaying(!isPlaying);

  void setTimeSpeed(TimeSpeed speed) {
    timeSpeed = speed;
    notifyListeners();
  }

  /// Zoom level only. [zoomScale] is animated by the Screen (0.5 s CUBIC_IN_OUT)
  /// unless [resetting] — then the Screen snaps. [已确认 KeplersLawsModel.ts:324-330]
  void setZoomLevel(int level) {
    zoomLevel = level.clamp(
      KeplersLawsConstants.zoomLevelMin,
      KeplersLawsConstants.zoomLevelMax,
    );
    notifyListeners();
  }

  double get targetZoomScale => zoomLevel == 1
      ? KeplersLawsConstants.zoomScaleMin
      : KeplersLawsConstants.zoomScaleMax;

  void setAnimatedZoomScale(double scale) {
    zoomScale = scale;
    notifyListeners();
  }

  void setGravityScalePower(double power) {
    var p = power.clamp(
      KeplersLawsConstants.gravityScalePowerMin,
      KeplersLawsConstants.gravityScalePowerMax,
    );
    if (p.abs() < 0.5) p = 0;
    gravityForceScalePower = p;
    notifyListeners();
  }

  void setTapeBase(KlVec p) {
    tapeBase = p;
    notifyListeners();
  }

  void setTapeTip(KlVec p) {
    tapeTip = p;
    notifyListeners();
  }

  void nudgeTape(Offset viewDelta, Offset Function(KlVec) toView, KlVec Function(Offset) toModel) {
    tapeBase = toModel(toView(tapeBase) + viewDelta);
    tapeTip = toModel(toView(tapeTip) + viewDelta);
    notifyListeners();
  }

  double get gravityArrowScale =>
      math.pow(
            10,
            gravityForceScalePower + KeplersLawsConstants.initialVectorOffscale,
          ).toDouble() *
      KeplersLawsConstants.velocityToViewMultiplier;

  double get velocityArrowScale => KeplersLawsConstants.velocityToViewMultiplier;

  bool get isGravityOffscale {
    if (!visible.gravityVisible) return false;
    final mag = planet.gravityForce.magnitude;
    if (mag <= 0) return true;
    final magnitudeLog = math.log(mag) / math.ln10;
    return magnitudeLog < 3.2 - gravityForceScalePower;
  }

  void noteVisitedAxis() {
    if (!engine.allowedOrbit) return;
    if (engine.a < minVisitedAxis) minVisitedAxis = engine.a;
    if (engine.a > maxVisitedAxis) maxVisitedAxis = engine.a;
  }

  void setPeriodTracking(bool running) {
    periodTracker.setRunning(running, timeYears);
    notifyListeners();
  }

  void setStopwatchRunning(bool running) {
    stopwatchRunning = running;
    notifyListeners();
  }

  void nudgeStopwatch(Offset delta) {
    stopwatchOffset += delta;
    notifyListeners();
  }

  void resetStopwatchTime() {
    stopwatchTime = 0;
    stopwatchRunning = false;
    notifyListeners();
  }

  void bump() => notifyListeners();

  void setTargetOrbit(TargetOrbit orbit) {
    targetOrbit = orbit;
    notifyListeners();
  }

  void setAxisPower(int p) {
    selectedAxisPower = p.clamp(1, 3);
    notifyListeners();
  }

  void setPeriodPower(int p) {
    selectedPeriodPower = p.clamp(1, 3);
    notifyListeners();
  }

  void beginUserPosition() {
    planet.userIsControllingPosition = true;
    isPlaying = false;
    hasPlayed = false;
    userHasInteracted = true;
    notifyListeners();
  }

  void endUserPosition() {
    planet.userIsControllingPosition = false;
    _saveStarting();
    engine.update();
    notifyListeners();
  }

  void beginUserVelocity() {
    planet.userIsControllingVelocity = true;
    isPlaying = false;
    hasPlayed = false;
    userHasInteracted = true;
    notifyListeners();
  }

  void endUserVelocity() {
    planet.userIsControllingVelocity = false;
    _saveStarting();
    engine.update();
    notifyListeners();
  }

  void setPlanetPosition(KlVec p) {
    var point = p;
    final escapeR = engine.escapeRadius;
    if (escapeR > 0 && point.magnitude > escapeR) {
      point = point.normalized().times(escapeR);
    }
    planet.position = point;
    engine.update();
    noteVisitedAxis();
    notifyListeners();
  }

  void setPlanetVelocity(KlVec v) {
    var vel = v;
    final mag = vel.magnitude;
    if (mag < KeplersLawsConstants.velocityMinMagnitude) {
      vel = vel.normalized().times(KeplersLawsConstants.velocityMinMagnitude);
    }
    if (engine.escapeSpeed > 0 && mag > engine.escapeSpeed) {
      vel = vel.normalized().times(engine.escapeSpeed);
    }
    planet.velocity = vel;
    engine.update();
    noteVisitedAxis();
    notifyListeners();
  }

  void setSunMass(double mass) {
    var m = mass.clamp(
      0.5 * KeplersLawsConstants.massOfOurSun,
      2 * KeplersLawsConstants.massOfOurSun,
    );
    final rel =
        (m - KeplersLawsConstants.massOfOurSun).abs() /
        KeplersLawsConstants.massOfOurSun;
    if (rel < KeplersLawsConstants.starMassSnapTolerance) {
      m = KeplersLawsConstants.massOfOurSun;
    }
    sun.mass = m;
    engine.update();
    noteVisitedAxis();
    notifyListeners();
  }

  void beginUserMass() {
    sun.userIsControllingMass = true;
    isPlaying = false;
    hasPlayed = false;
    userHasInteracted = true;
    notifyListeners();
  }

  void endUserMass() {
    sun.userIsControllingMass = false;
    _saveStarting();
    notifyListeners();
  }

  /// [已确认] stepOnce: dt *= speed * engineTimeScale; run; time += dt * modelToViewTime
  void stepOnce(double dt, {bool usingStepForwardButton = false}) {
    steppingForward = usingStepForwardButton;
    var scaled = dt * timeScale * KeplersLawsConstants.engineTimeScale;
    engine.run(scaled);
    scaled *= KeplersLawsConstants.modelToViewTime;
    timeYears += scaled;
    if (timeYears > 0) hasPlayed = true;
    if (stopwatchRunning) stopwatchTime += scaled;
    periodTracker.onTime(timeYears, engine.T);
    if (periodTracker.tracingPath) {
      periodTracker.periodTraceEnd = moduloBetweenDown(
        engine.nu,
        periodTracker.periodTraceStart,
        periodTracker.periodTraceStart + 2 * math.pi,
      );
    }
    noteVisitedAxis();
    steppingForward = false;
    notifyListeners();
  }

  void stepForwardButton() {
    if (!engine.allowedOrbit) return;
    userHasInteracted = true;
    stepOnce(1 / 8, usingStepForwardButton: true);
  }

  /// Called by SimulationClock with wall dt (seconds).
  /// [已确认] KeplersLawsModel.step: periodTracker.step(dt) 用墙钟秒，不乘 modelToViewTime
  void tick(double dt) {
    if (isPlaying) {
      stepOnce(dt);
    }
    periodTracker.step(dt);
    if (periodTracker.trackingState == TrackingState.fading) {
      notifyListeners();
    }
  }

  /// [已确认] restart: pause, time=0, load startingBodyInfo
  void restart() {
    restarting = true;
    isPlaying = false;
    timeYears = 0;
    hasPlayed = false;
    stopwatchTime = 0;
    _load(_startingSun!, _startingPlanet!);
    engine.update();
    restarting = false;
    notifyListeners();
  }

  /// [已确认] reset
  void reset() {
    resetting = true;
    isPlaying = false;
    hasPlayed = false;
    timeYears = 0;
    timeSpeed = TimeSpeed.normal;
    zoomLevel = KeplersLawsConstants.zoomLevelDefault;
    zoomScale = KeplersLawsConstants.zoomScaleMax;
    gravityForceScalePower = KeplersLawsConstants.gravityScalePowerDefault;
    tapeBase = const KlVec(
      KeplersLawsConstants.tapeBaseX,
      KeplersLawsConstants.tapeBaseY,
    );
    tapeTip = const KlVec(
      KeplersLawsConstants.tapeTipX,
      KeplersLawsConstants.tapeTipY,
    );
    selectedLaw = initialLaw;
    lastLaw = initialLaw;
    periodDivisions = KeplersLawsConstants.periodDivisionsDefault;
    engine.periodDivisions = periodDivisions;
    selectedAxisPower = 1;
    selectedPeriodPower = 1;
    alwaysCircular = false;
    engine.alwaysCircles = false;
    periodTracker.reset();
    targetOrbit = TargetOrbit.none;
    stopwatchRunning = false;
    stopwatchTime = 0;
    stopwatchOffset = Offset.zero;
    userHasInteracted = false;
    visible.hardReset();
    sun.mass = KeplersLawsConstants.massOfOurSun;
    sun.position = KlVec.zero;
    sun.velocity = KlVec.zero;
    planet.mass = KeplersLawsConstants.planetMass;
    planet.position = const KlVec(
      KeplersLawsConstants.defaultPlanetX,
      KeplersLawsConstants.defaultPlanetY,
    );
    planet.velocity = const KlVec(
      KeplersLawsConstants.defaultPlanetVx,
      KeplersLawsConstants.defaultPlanetVy,
    );
    engine.reset();
    minVisitedAxis = engine.a;
    maxVisitedAxis = engine.a;
    _saveStarting();
    resetting = false;
    notifyListeners();
  }

  void _saveStarting() {
    _startingSun = BodyInfo(
      mass: sun.mass,
      position: sun.position,
      velocity: sun.velocity,
    );
    _startingPlanet = BodyInfo(
      mass: planet.mass,
      position: planet.position,
      velocity: planet.velocity,
    );
  }

  void _load(BodyInfo sunInfo, BodyInfo planetInfo) {
    engine.internalPropertyMutation = true;
    sun.mass = sunInfo.mass;
    sun.position = sunInfo.position;
    sun.velocity = sunInfo.velocity;
    planet.mass = planetInfo.mass;
    planet.position = planetInfo.position;
    planet.velocity = planetInfo.velocity;
    engine.update();
    engine.internalPropertyMutation = false;
  }
}

double mathPow(double b, int p) {
  var r = 1.0;
  for (var i = 0; i < p; i++) {
    r *= b;
  }
  return r;
}
