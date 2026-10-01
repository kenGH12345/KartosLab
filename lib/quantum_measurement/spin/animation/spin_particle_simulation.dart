/// Animated spin particles + measurement-device crossing (SingleParticleCollection).
library;

import 'dart:math' as math;

import '../model/spin_model.dart';
import '../transform/spin_view_transform.dart';

const maxParticleLifetimeSeconds = 4.0;
const particleSpeed = 1.0;
/// Hidden dwell through SG body — longer than free flight so redirect feels paced.
const sgTransitSpeed = 0.38;
const maxParticleCreationRate = 5.0;
const pathReachThreshold = 0.03;
const maxContinuousParticles = 80;

/// Quadratic entrance→exit sample matching SternGerlachNode decoration curves.
SpinVec2 _sgCurvePoint(SpinVec2 entrance, SpinVec2 exit, double t) {
  final u = t.clamp(0.0, 1.0);
  return SpinVec2(
    entrance.x + (exit.x - entrance.x) * u,
    entrance.y + (exit.y - entrance.y) * u * u,
  );
}

double _sgCurveDuration(SpinVec2 entrance, SpinVec2 exit) {
  final dx = exit.x - entrance.x;
  final dy = exit.y - entrance.y;
  // Chord × factor ≈ arc length of the quadratic decoration path.
  final approxLen = math.sqrt(dx * dx + dy * dy) * 1.2;
  return approxLen / sgTransitSpeed;
}

/// View state for one MeasurementDevice (MD0 / MD1 / MD2).
class SpinMdState {
  SpinMdState({required this.modelX, this.active = false});

  /// Measurement line X in model space (`isParticleBehind` compares x).
  double modelX;
  bool active;

  /// Bloch angles of last measured spin (XZ plane → polar/azimuthal).
  double polar = 0;
  double azimuthal = 0;

  /// PhET: state vector starts hidden until first measurement flash settles.
  bool stateVectorVisible = false;

  /// Camera fill: idle black; flash → particleColor #C0C for 500ms.
  bool cameraFlash = false;
  double _cameraFlashLeft = 0;
  double _vectorRevealLeft = 0;

  void triggerMeasurement({required double polar, required double azimuthal}) {
    this.polar = polar;
    this.azimuthal = azimuthal;
    stateVectorVisible = false;
    cameraFlash = true;
    _cameraFlashLeft = 0.5;
    _vectorRevealLeft = 0.1;
  }

  void tick(double dt) {
    if (_vectorRevealLeft > 0) {
      _vectorRevealLeft -= dt;
      if (_vectorRevealLeft <= 0) {
        stateVectorVisible = true;
      }
    }
    if (_cameraFlashLeft > 0) {
      _cameraFlashLeft -= dt;
      if (_cameraFlashLeft <= 0) {
        cameraFlash = false;
      }
    }
  }

  void reset() {
    polar = 0;
    azimuthal = 0;
    stateVectorVisible = false;
    cameraFlash = false;
    _cameraFlashLeft = 0;
    _vectorRevealLeft = 0;
  }

  /// True while flash / vector-reveal timers are running (keeps ticker alive).
  bool get isAnimating => _cameraFlashLeft > 0 || _vectorRevealLeft > 0;
}

class SpinParticle {
  SpinParticle({
    required this.position,
    required this.start,
    required this.end,
    required this.isSpinUp,
    required this.stageCompleted,
    required this.prepPolar,
    required this.prepAzimuthal,
    this.speed = particleSpeed,
  }) : velocity = (end - start).withMagnitude(speed);

  SpinVec2 position;
  SpinVec2 start;
  SpinVec2 end;
  SpinVec2 velocity;
  double speed;
  double lifetime = 0;
  final List<bool> isSpinUp;
  final List<bool> stageCompleted;

  /// Prepared state (MD0).
  final double prepPolar;
  final double prepAzimuthal;

  /// Per-device: was particle still behind this MD on previous frame?
  final List<bool> behindMd = [true, true, true];

  /// Hidden while inside an SG body (no visible in-box trajectory).
  bool visible = true;

  /// Curved entrance→exit transit (particle not drawn).
  bool inSgTransit = false;
  SpinVec2? transitEntrance;
  SpinVec2? transitExit;
  double transitT = 0;
  double transitDuration = 1;

  /// Which SG transit just finished: 0 = SG0, 1 = SG1/SG2.
  int transitSgIndex = 0;

  void updatePath(
    SpinVec2 newStart,
    SpinVec2 newEnd, {
    double extraTime = 0,
    double speed = particleSpeed,
  }) {
    start = newStart;
    end = newEnd;
    this.speed = speed;
    position = start;
    velocity = (end - start).withMagnitude(speed);
    if (extraTime > 0) step(extraTime);
  }

  void beginSgTransit({
    required SpinVec2 entrance,
    required SpinVec2 exit,
    required int sgIndex,
  }) {
    inSgTransit = true;
    visible = false;
    transitEntrance = entrance;
    transitExit = exit;
    transitT = 0;
    transitDuration = _sgCurveDuration(entrance, exit);
    transitSgIndex = sgIndex;
    position = entrance;
    velocity = SpinVec2.zero;
    start = entrance;
    end = exit;
  }

  void step(double dt) {
    lifetime += dt;
    if (inSgTransit) {
      final entrance = transitEntrance!;
      final exit = transitExit!;
      transitT += dt / transitDuration;
      if (transitT >= 1) {
        transitT = 1;
        position = exit;
        inSgTransit = false;
        visible = true;
      } else {
        position = _sgCurvePoint(entrance, exit, transitT);
      }
      return;
    }
    position = position + velocity.scaled(dt);
  }
}

class SpinParticleSimulation {
  SpinParticleSimulation({
    required this.model,
    this.meters = const SpinApparatusMeters(),
  }) {
    _syncMdGeometry();
  }

  final SpinModel model;
  final SpinApparatusMeters meters;
  final List<SpinParticle> particles = [];
  double _fractionalEmission = 0;

  /// MD0 (source→SG0), MD1 (after SG0), MD2 (after SG1/2).
  late final List<SpinMdState> measurementDevices = [
    SpinMdState(modelX: 0, active: true),
    SpinMdState(modelX: 0, active: true),
    SpinMdState(modelX: 0, active: false),
  ];

  void _syncMdGeometry() {
    // SpinModel.ts positions
    measurementDevices[0].modelX =
        (meters.sourceExit.x + meters.entrance(meters.sg0).x) / 2;
    measurementDevices[1].modelX =
        (meters.topExit(meters.sg0).x + meters.entrance(meters.sg1).x) / 2;
    measurementDevices[2].modelX =
        (meters.topExit(meters.sg1).x + meters.topExit(meters.sg1).x + 0.5) / 2;

    final single = model.sourceMode == SourceMode.single;
    final multi = !model.experiment.usingSingleApparatus;
    measurementDevices[0].active = single;
    measurementDevices[1].active = single;
    measurementDevices[2].active = single && multi;
  }

  void clear() {
    particles.clear();
    _fractionalEmission = 0;
    for (final d in measurementDevices) {
      d.reset();
    }
  }

  ({double polar, double azimuthal}) _prepAngles() {
    if (model.isCustom) {
      return (polar: math.pi * (1 - model.alphaSquared), azimuthal: 0.0);
    }
    switch (model.spinState) {
      case SpinDirection.zPlus:
        return (polar: 0.0, azimuthal: 0.0);
      case SpinDirection.zMinus:
        return (polar: math.pi, azimuthal: 0.0);
      case SpinDirection.xPlus:
        return (polar: math.pi / 2, azimuthal: 0.0);
    }
  }

  ({double polar, double azimuthal}) _collapseAngles({
    required bool isUp,
    required bool isZ,
  }) {
    if (isZ) {
      return (polar: isUp ? 0.0 : math.pi, azimuthal: 0.0);
    }
    return (polar: math.pi / 2, azimuthal: isUp ? 0.0 : math.pi);
  }

  void fireSingle() {
    _syncMdGeometry();
    final results = model.fireSingleParticle();
    if (results.isEmpty) return;
    final prep = _prepAngles();
    final up0 = results[0];
    // Visible flight only to SG entrance — in-box path is hidden transit.
    particles.add(
      SpinParticle(
        position: meters.sourceExit,
        start: meters.sourceExit,
        end: meters.entrance(meters.sg0),
        isSpinUp: [false, up0, results.length > 1 ? results[1] : up0],
        stageCompleted: [false, false, false],
        prepPolar: prep.polar,
        prepAzimuthal: prep.azimuthal,
      ),
    );
  }

  void _createFromOutcome(List<bool> results) {
    if (results.isEmpty) return;
    final prep = _prepAngles();
    final up0 = results[0];
    particles.add(
      SpinParticle(
        position: meters.sourceExit,
        start: meters.sourceExit,
        end: meters.entrance(meters.sg0),
        isSpinUp: [false, up0, results.length > 1 ? results[1] : up0],
        stageCompleted: [false, false, false],
        prepPolar: prep.polar,
        prepAzimuthal: prep.azimuthal,
      ),
    );
  }

  void _onCrossedMd(SpinParticle particle, int index) {
    final md = measurementDevices[index];
    if (!md.active) return;

    late final double polar;
    late final double azimuthal;
    if (index == 0) {
      polar = particle.prepPolar;
      azimuthal = particle.prepAzimuthal;
    } else if (index == 1) {
      final a = _collapseAngles(
        isUp: particle.isSpinUp[1],
        isZ: model.sternGerlachs[0].isZOriented,
      );
      polar = a.polar;
      azimuthal = a.azimuthal;
    } else {
      final sg = particle.isSpinUp[1]
          ? model.sternGerlachs[1]
          : model.sternGerlachs[2];
      final a = _collapseAngles(
        isUp: particle.isSpinUp[2],
        isZ: sg.isZOriented,
      );
      polar = a.polar;
      azimuthal = a.azimuthal;
    }
    md.triggerMeasurement(polar: polar, azimuthal: azimuthal);
  }

  /// After hidden SG transit ends at the exit hole — continue smoothly outward.
  void _continueAfterSgExit(SpinParticle particle) {
    final exit = particle.transitExit!;
    final single = model.experiment.usingSingleApparatus;

    if (particle.transitSgIndex == 0) {
      if (single) {
        particle.updatePath(
          exit,
          exit + SpinApparatusMeters.horizontalEndpoint,
        );
      } else {
        final end = particle.isSpinUp[1]
            ? meters.entrance(meters.sg1)
            : meters.entrance(meters.sg2);
        particle.updatePath(exit, end);
      }
      particle.stageCompleted[0] = true;
    } else {
      particle.updatePath(
        exit,
        exit + SpinApparatusMeters.horizontalEndpoint,
      );
      particle.stageCompleted[2] = true;
    }
  }

  void _decideDestiny(SpinParticle particle) {
    if (particle.inSgTransit) return;

    final blockedMode = model.sternGerlachs[0].blockingMode;
    if (particle.stageCompleted[0] &&
        blockedMode != BlockingMode.noBlocker &&
        !model.experiment.usingSingleApparatus) {
      final exit = particle.isSpinUp[1]
          ? meters.topExit(meters.sg0)
          : meters.bottomExit(meters.sg0);
      final blocker = exit + SpinApparatusMeters.blockerOffset;
      if ((blockedMode == BlockingMode.blockUp && particle.isSpinUp[1] ||
              blockedMode == BlockingMode.blockDown && !particle.isSpinUp[1]) &&
          particle.position.x > blocker.x) {
        particles.remove(particle);
        return;
      }
    }

    if (particle.position.x <= particle.end.x - pathReachThreshold) return;

    final single = model.experiment.usingSingleApparatus;

    if (!particle.stageCompleted[0]) {
      // Arrived at SG0 entrance → hide and curve to chosen exit.
      final up0 = particle.isSpinUp[1];
      final entrance = meters.entrance(meters.sg0);
      final exit =
          up0 ? meters.topExit(meters.sg0) : meters.bottomExit(meters.sg0);
      particle.beginSgTransit(
        entrance: entrance,
        exit: exit,
        sgIndex: 0,
      );
    } else if (!single && !particle.stageCompleted[1]) {
      // Arrived at SG1/SG2 entrance → hidden transit through second SG.
      final sg = particle.isSpinUp[1] ? meters.sg1 : meters.sg2;
      final entrance = meters.entrance(sg);
      final up1 = particle.isSpinUp[2];
      final exit = up1 ? meters.topExit(sg) : meters.bottomExit(sg);
      particle.beginSgTransit(
        entrance: entrance,
        exit: exit,
        sgIndex: 1,
      );
      particle.stageCompleted[1] = true;
    }
  }

  void step(double dt) {
    _syncMdGeometry();

    if (model.sourceMode == SourceMode.continuous) {
      final rate = model.particleAmount * maxParticleCreationRate;
      var whole = (rate * dt).floor();
      _fractionalEmission += rate * dt - whole;
      if (_fractionalEmission >= 1) {
        whole++;
        _fractionalEmission -= 1;
      }
      for (var i = 0; i < whole; i++) {
        if (particles.length >= maxContinuousParticles) break;
        _createFromOutcome(model.fireSingleParticle());
      }
    }

    for (final p in List<SpinParticle>.from(particles)) {
      final wasInTransit = p.inSgTransit;
      p.step(dt);
      // Emerged from SG this frame — attach outgoing path before destiny.
      if (wasInTransit && !p.inSgTransit) {
        _continueAfterSgExit(p);
      }
      _decideDestiny(p);

      // Crossing: was behind before step && now not (SingleParticleCollection.ts)
      for (var i = 0; i < measurementDevices.length; i++) {
        final mdX = measurementDevices[i].modelX;
        final wasBehind = p.behindMd[i];
        final nowBehind = p.position.x < mdX;
        if (wasBehind && !nowBehind) {
          _onCrossedMd(p, i);
        }
        p.behindMd[i] = nowBehind;
      }

      if (p.lifetime > maxParticleLifetimeSeconds) {
        particles.remove(p);
      }
    }

    for (final d in measurementDevices) {
      d.tick(dt);
    }
  }
}
