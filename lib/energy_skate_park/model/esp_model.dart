import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/measurement_tools.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/model/gravity_magnitude.dart';
import 'package:kratos/energy_skate_park/model/premade_tracks.dart';
import 'package:kratos/energy_skate_park/model/skater.dart';
import 'package:kratos/energy_skate_park/model/skater_state.dart';
import 'package:kratos/energy_skate_park/model/track.dart';
import 'package:kratos/energy_skate_park/solver/physics_solver.dart';

/// Base model semantics from EnergySkateParkModel.ts (clock + tracks + friction).
class EspModel {
  EspModel({
    Skater? skater,
    List<Track>? tracks,
    this.friction = EspConstants.defaultFriction,
    this.isStickingToTrack = true,
  })  : skater = skater ?? Skater(),
        tracks = tracks ?? [] {
    physicsSolver = PhysicsSolver(
      getFriction: () => friction,
      getIsStickingToTrack: () => isStickingToTrack,
      getPhysicalTracks: getPhysicalTracks,
    );
  }

  final Skater skater;
  final List<Track> tracks;

  double friction;
  bool isStickingToTrack;
  bool paused = false;
  bool slow = false;

  /// Draggable measurement tools (Stopwatch / Measuring Tape).
  final MeasurementTools tools = MeasurementTools();

  bool get stopwatchVisible => tools.stopwatchVisible;
  set stopwatchVisible(bool v) => tools.stopwatchVisible = v;

  double get stopwatchTime => tools.stopwatchTime;
  set stopwatchTime(double v) => tools.stopwatchTime = v;

  bool get measuringTapeVisible => tools.measuringTapeVisible;
  set measuringTapeVisible(bool v) => tools.measuringTapeVisible = v;

  EspVec get measuringTapeBase => tools.measuringTapeBase;
  set measuringTapeBase(EspVec v) => tools.measuringTapeBase = v;

  EspVec get measuringTapeTip => tools.measuringTapeTip;
  set measuringTapeTip(EspVec v) => tools.measuringTapeTip = v;

  double get measuringTapeDistance => tools.measuringTapeDistanceMeters;

  late final PhysicsSolver physicsSolver;

  double _eventAccumulator = 0;
  int _modelIterations = 0;

  /// Gravity magnitude (positive) → signed gravity on skater.
  /// Range [1, 26] = abs(MIN_GRAVITY)..abs(MAX_GRAVITY); updates PE immediately.
  set gravityMagnitude(double g) {
    skater.gravityMagnitude = GravityMagnitude.clamp(g);
    skater.updateEnergy();
  }

  double get gravityMagnitude => skater.gravityMagnitude;

  List<Track> getPhysicalTracks() {
    final physicalTracks = <Track>[];
    for (final track in tracks) {
      if (track.physical) physicalTracks.add(track);
    }
    return physicalTracks;
  }

  /// Wall-clock step: accumulate → fire fixed 1/60 s steps (EventTimer semantics).
  void step(double wallDt) {
    if (paused) return;
    _eventAccumulator += wallDt;
    final frameDt = EspConstants.dt;
    while (_eventAccumulator >= frameDt) {
      _eventAccumulator -= frameDt;
      constantStep();
    }
  }

  void constantStep() {
    if (paused || skater.userControlled) return;

    _modelIterations++;
    // Slow: step every 3rd EventTimer tick (PhET TimeSpeed.SLOW).
    if (slow && _modelIterations % 3 != 0) return;

    final skaterState = skater.toSkaterState();
    final updated = physicsSolver.stepModel(EspConstants.dt, skaterState);
    skater.setFromSkaterState(updated);

    if (skater.track == null && skater.positionY == 0) {
      if (skater.velocityX > 0) skater.direction = 'right';
      if (skater.velocityX < 0) skater.direction = 'left';
    }

    if (stopwatchVisible) {
      tools.stopwatchTime += EspConstants.dt;
    }

    onAfterPhysicsStep(EspConstants.dt, updated);
  }

  /// Hook for SaveSampleModel / Graphs sampling (PhET stepModel override).
  void onAfterPhysicsStep(double dt, SkaterState updated) {}

  void manualStep() {
    final skaterState = skater.toSkaterState();
    final result = physicsSolver.stepModel(EspConstants.dt, skaterState);
    skater.setFromSkaterState(result);
    if (stopwatchVisible) {
      tools.stopwatchTime += EspConstants.dt;
    }
    onAfterPhysicsStep(EspConstants.dt, result);
  }

  void resetStopwatch() => tools.resetStopwatch();

  void reset() {
    friction = EspConstants.defaultFriction;
    isStickingToTrack = true;
    paused = false;
    slow = false;
    _eventAccumulator = 0;
    _modelIterations = 0;
    tools.resetAll();
    skater.reset();
    for (final track in tracks) {
      track.updateSplines();
    }
  }

  /// Convenience: single physical parabola scene.
  factory EspModel.withParabola() {
    final track = PremadeTracks.createParabola(physical: true);
    return EspModel(tracks: [track]);
  }
}