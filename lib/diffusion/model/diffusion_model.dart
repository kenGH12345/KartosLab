import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../diffusion_constants.dart';
import 'collision_detector.dart';
import 'container.dart';
import 'diffusion_data.dart';
import 'particle.dart';
import 'particle_flow_rate.dart';
import 'settings.dart';

enum DiffusionTimeSpeed { normal, slow }

/// Top-level Diffusion model — gas-properties DiffusionModel @ 7a52c48.
///
/// No Ideal Gas Law. Clock → particles → collision → statistics → notify.
class DiffusionModel extends ChangeNotifier {
  DiffusionModel({math.Random? random, bool autoTick = true})
      : _random = random ?? math.Random() {
    _collisionDetector = DiffusionCollisionDetector(
      container: container,
      particles1: particles1,
      particles2: particles2,
    );
    // ParticleFlowRate(dividerX, particles) — DiffusionModel.ts @ 7a52c48
    particleFlowRate1 = ParticleFlowRate(
      dividerX: container.dividerX,
      particles: particles1,
    );
    particleFlowRate2 = ParticleFlowRate(
      dividerX: container.dividerX,
      particles: particles2,
    );
    _ticker = Ticker(_onTick);
    if (autoTick) {
      _ticker.start();
    }
  }

  final math.Random _random;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  final DiffusionContainer container = DiffusionContainer();
  final DiffusionSettings leftSettings = DiffusionSettings();
  final DiffusionSettings rightSettings = DiffusionSettings();

  final List<DiffusionParticle> particles1 = [];
  final List<DiffusionParticle> particles2 = [];

  final DiffusionData leftData = DiffusionData();
  final DiffusionData rightData = DiffusionData();

  late final DiffusionCollisionDetector _collisionDetector;
  late final ParticleFlowRate particleFlowRate1;
  late final ParticleFlowRate particleFlowRate2;

  bool isPlaying = true;
  DiffusionTimeSpeed timeSpeed = DiffusionTimeSpeed.normal;

  /// Canonical sim time (ps) — BaseModel.stopwatch @ 7a52c48.
  /// Display precision: 1 decimal place; units: ps; max 999.99.
  double stopwatchPs = 0;

  /// View toggles — DiffusionViewProperties
  bool centerOfMassVisible = false;
  bool particleFlowRateVisible = false;
  bool scaleVisible = false;

  /// Data accordion default collapsed — dataExpandedProperty: false
  bool dataExpanded = false;

  /// Stopwatch visibility — StopwatchCheckbox; default hidden
  bool stopwatchVisible = false;

  double? centerOfMass1;
  double? centerOfMass2;

  bool get slow => timeSpeed == DiffusionTimeSpeed.slow;

  int get numberOfParticles => particles1.length + particles2.length;

  /// Settings spinners enabled only while divider is in place
  /// (DiffusionSettingsNode enabledProperty = hasDividerProperty).
  bool get settingsEnabled => container.hasDivider;

  /// DividerToggleButton.enabled when N !== 0
  bool get dividerToggleEnabled => numberOfParticles != 0;

  /// Formatted stopwatch readout for view (does not compute time).
  String get stopwatchDisplay =>
      '${stopwatchPs.clamp(0, DiffusionConstants.maxTimePs).toStringAsFixed(1)} ps';

  void _onTick(Duration elapsed) {
    final dt = _lastElapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt <= 0 || dt > 0.25) return;
    step(dt);
  }

  /// Real-time step from Sim / Ticker.
  void step(double realDtSeconds) {
    if (!isPlaying) {
      notifyListeners();
      return;
    }
    stepRealTime(realDtSeconds);
  }

  void stepRealTime(double realDtSeconds) {
    final scale = DiffusionConstants.timeTransform(slow);
    stepModelTime(realDtSeconds * scale);
  }

  /// Manual Step button — fixed 0.2 ps model time.
  void stepForward() {
    stepModelTime(DiffusionConstants.modelTimeStepPs);
    notifyListeners();
  }

  void stepModelTime(double dtPs) {
    if (dtPs <= 0) return;
    stopwatchPs =
        (stopwatchPs + dtPs).clamp(0.0, DiffusionConstants.maxTimePs);
    // Order matches DiffusionModel.stepModelTime @ 7a52c48:
    // particles → flow rate (if no divider) → collision → COM/data
    for (final p in particles1) {
      p.step(dtPs);
    }
    for (final p in particles2) {
      p.step(dtPs);
    }
    if (!container.hasDivider) {
      particleFlowRate1.step(dtPs);
      particleFlowRate2.step(dtPs);
    }
    _collisionDetector.update();
    _updateCenterOfMass();
    _updateData();
    notifyListeners();
  }

  void play() {
    isPlaying = true;
    notifyListeners();
  }

  void pause() {
    isPlaying = false;
    notifyListeners();
  }

  void togglePlayPause() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void setTimeSpeed(DiffusionTimeSpeed speed) {
    timeSpeed = speed;
    notifyListeners();
  }

  void setLeftCount(int n) {
    if (!settingsEnabled && n != leftSettings.numberOfParticles) return;
    _setCount(
      DiffusionSettings.clampCount(n),
      leftSettings,
      particles1,
      ParticleSpecies.one,
      left: true,
    );
  }

  void setRightCount(int n) {
    if (!settingsEnabled && n != rightSettings.numberOfParticles) return;
    _setCount(
      DiffusionSettings.clampCount(n),
      rightSettings,
      particles2,
      ParticleSpecies.two,
      left: false,
    );
  }

  void setLeftMass(int m) {
    if (!settingsEnabled) return;
    leftSettings.mass = DiffusionSettings.clampMass(m);
    _updateMassTemp(particles1, leftSettings);
    notifyListeners();
  }

  void setRightMass(int m) {
    if (!settingsEnabled) return;
    rightSettings.mass = DiffusionSettings.clampMass(m);
    _updateMassTemp(particles2, rightSettings);
    notifyListeners();
  }

  void setLeftRadius(int r) {
    if (!settingsEnabled) return;
    leftSettings.radius = DiffusionSettings.clampRadius(r);
    _updateRadius(particles1, leftSettings.radius.toDouble(), left: true);
    notifyListeners();
  }

  void setRightRadius(int r) {
    if (!settingsEnabled) return;
    rightSettings.radius = DiffusionSettings.clampRadius(r);
    _updateRadius(particles2, rightSettings.radius.toDouble(), left: false);
    notifyListeners();
  }

  void setLeftTemperature(int t) {
    if (!settingsEnabled) return;
    leftSettings.initialTemperature = DiffusionSettings.clampTemperature(t);
    _updateMassTemp(particles1, leftSettings);
    if (!isPlaying) _updateData();
    notifyListeners();
  }

  void setRightTemperature(int t) {
    if (!settingsEnabled) return;
    rightSettings.initialTemperature = DiffusionSettings.clampTemperature(t);
    _updateMassTemp(particles2, rightSettings);
    if (!isPlaying) _updateData();
    notifyListeners();
  }

  void setHasDivider(bool value) {
    if (container.hasDivider == value) return;
    container.setHasDivider(value);
    if (value) {
      // Restore divider → restart experiment + reset flow rates
      leftSettings.restart((n) => setLeftCount(n));
      rightSettings.restart((n) => setRightCount(n));
      particleFlowRate1.reset();
      particleFlowRate2.reset();
    }
    notifyListeners();
  }

  void setParticleFlowRateVisible(bool v) {
    particleFlowRateVisible = v;
    notifyListeners();
  }

  void toggleDivider() => setHasDivider(!container.hasDivider);

  void setCenterOfMassVisible(bool v) {
    centerOfMassVisible = v;
    notifyListeners();
  }

  void setScaleVisible(bool v) {
    scaleVisible = v;
    notifyListeners();
  }

  void setDataExpanded(bool v) {
    dataExpanded = v;
    notifyListeners();
  }

  void setStopwatchVisible(bool v) {
    stopwatchVisible = v;
    notifyListeners();
  }

  void reset() {
    isPlaying = true;
    timeSpeed = DiffusionTimeSpeed.normal;
    stopwatchPs = 0;
    centerOfMassVisible = false;
    particleFlowRateVisible = false;
    scaleVisible = false;
    dataExpanded = false;
    stopwatchVisible = false;
    container.reset();
    leftSettings.reset();
    rightSettings.reset();
    particles1.clear();
    particles2.clear();
    centerOfMass1 = null;
    centerOfMass2 = null;
    particleFlowRate1.reset();
    particleFlowRate2.reset();
    _updateData();
    notifyListeners();
  }

  void _setCount(
    int n,
    DiffusionSettings settings,
    List<DiffusionParticle> particles,
    ParticleSpecies species, {
    required bool left,
  }) {
    settings.numberOfParticles = n;
    final delta = n - particles.length;
    if (delta > 0) {
      _addParticles(delta, settings, particles, species, left: left);
    } else if (delta < 0) {
      particles.removeRange(particles.length + delta, particles.length);
    }
    if (!isPlaying) {
      _updateCenterOfMass();
      _updateData();
    }
    notifyListeners();
  }

  void _addParticles(
    int n,
    DiffusionSettings settings,
    List<DiffusionParticle> particles,
    ParticleSpecies species, {
    required bool left,
  }) {
    final minX = left ? container.left : container.rightMinX;
    final maxX = left ? container.leftMaxX : container.right;
    final minY = container.bottom;
    final maxY = container.top;
    final r = settings.radius.toDouble();
    final mass = settings.mass.toDouble();
    final speed = DiffusionConstants.speedFromTemperature(
      temperatureK: settings.initialTemperature.toDouble(),
      massAmu: mass,
    );

    for (var i = 0; i < n; i++) {
      final x = _random.nextDouble() * ((maxX - r) - (minX + r)) + (minX + r);
      final y = _random.nextDouble() * ((maxY - r) - (minY + r)) + (minY + r);
      final angle = _random.nextDouble() * 2 * math.pi;
      final p = DiffusionParticle(
        species: species,
        mass: mass,
        radius: r,
        x: x,
        y: y,
        vx: 0,
        vy: 0,
      )..setVelocityPolar(speed, angle);
      particles.add(p);
    }
  }

  void _updateMassTemp(
    List<DiffusionParticle> particles,
    DiffusionSettings settings,
  ) {
    final mass = settings.mass.toDouble();
    final speed = DiffusionConstants.speedFromTemperature(
      temperatureK: settings.initialTemperature.toDouble(),
      massAmu: mass,
    );
    for (final p in particles) {
      p.mass = mass;
      p.setVelocityMagnitude(speed);
    }
  }

  void _updateRadius(
    List<DiffusionParticle> particles,
    double radius, {
    required bool left,
  }) {
    final minX = left ? container.left : container.rightMinX;
    final maxX = left ? container.leftMaxX : container.right;
    for (final p in particles) {
      p.radius = radius;
      if (!isPlaying) {
        if (p.left < minX) p.setPosition(minX + radius, p.y);
        if (p.right > maxX) p.setPosition(maxX - radius, p.y);
        if (p.bottom < container.bottom) {
          p.setPosition(p.x, container.bottom + radius);
        }
        if (p.top > container.top) {
          p.setPosition(p.x, container.top - radius);
        }
      }
    }
  }

  void _updateCenterOfMass() {
    centerOfMass1 = _comX(particles1);
    centerOfMass2 = _comX(particles2);
  }

  double? _comX(List<DiffusionParticle> particles) {
    if (particles.isEmpty) return null;
    var sum = 0.0;
    var m = 0.0;
    for (final p in particles) {
      sum += p.x * p.mass;
      m += p.mass;
    }
    return sum / m;
  }

  void _updateData() {
    leftData.update(
      container: container,
      leftSide: true,
      particles1: particles1,
      particles2: particles2,
    );
    rightData.update(
      container: container,
      leftSide: false,
      particles1: particles1,
      particles2: particles2,
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
