import 'dart:math' as math;

import '../gas_properties_constants.dart';
import '../solver/collision_solver.dart';
import 'particle.dart';
import 'particle_type.dart';
import 'random_source.dart';
import 'simulation_clock.dart';

/// Diffusion container — fixed 16000 pm width + removable divider.
class DiffusionContainer {
  DiffusionContainer() {
    _syncSideBounds();
  }

  final double width = GasPropertiesConstants.diffusionWidth;
  final double height = GasPropertiesConstants.height;
  final double dividerThickness = GasPropertiesConstants.dividerThickness;

  bool hasDivider = true;

  double get left => 0;
  double get right => width;
  double get bottom => 0;
  double get top => height;
  double get dividerX => width / 2;

  late double leftMaxX;
  late double rightMinX;

  void _syncSideBounds() {
    final half = hasDivider ? dividerThickness / 2 : 0.0;
    leftMaxX = dividerX - half;
    rightMinX = dividerX + half;
  }

  void setHasDivider(bool value) {
    hasDivider = value;
    _syncSideBounds();
  }

  void reset() {
    hasDivider = true;
    _syncSideBounds();
  }

  bool inLeft(double x) => x >= left && x <= leftMaxX;
  bool inRight(double x) => x >= rightMinX && x <= right;
}

/// One side's settings — DiffusionSettings.ts
class DiffusionSideSettings {
  int numberOfParticles = 0;
  int mass = GasPropertiesConstants.diffusionMassDefault;
  int radius = GasPropertiesConstants.diffusionRadiusDefault;
  int initialTemperature = GasPropertiesConstants.diffusionTempDefault;

  void reset() {
    numberOfParticles = 0;
    mass = GasPropertiesConstants.diffusionMassDefault;
    radius = GasPropertiesConstants.diffusionRadiusDefault;
    initialTemperature = GasPropertiesConstants.diffusionTempDefault;
  }

  static int clampCount(int v) {
    final c = v.clamp(0, GasPropertiesConstants.diffusionParticleMax);
    return (c / GasPropertiesConstants.diffusionParticleDelta).round() *
        GasPropertiesConstants.diffusionParticleDelta;
  }

  static int clampMass(int v) => v
      .clamp(
        GasPropertiesConstants.diffusionMassMin,
        GasPropertiesConstants.diffusionMassMax,
      )
      .toInt();

  static int clampRadius(int v) {
    final c = v.clamp(
      GasPropertiesConstants.diffusionRadiusMin,
      GasPropertiesConstants.diffusionRadiusMax,
    );
    return (c / GasPropertiesConstants.diffusionRadiusDelta).round() *
        GasPropertiesConstants.diffusionRadiusDelta;
  }

  static int clampTemperature(int v) {
    final c = v.clamp(
      GasPropertiesConstants.diffusionTempMin,
      GasPropertiesConstants.diffusionTempMax,
    );
    return (c / GasPropertiesConstants.diffusionTempDelta).round() *
        GasPropertiesConstants.diffusionTempDelta;
  }
}

/// Side data: N1, N2, T_avg
class DiffusionSideData {
  int numberOfParticles1 = 0;
  int numberOfParticles2 = 0;
  double? averageTemperatureK;

  void reset() {
    numberOfParticles1 = 0;
    numberOfParticles2 = 0;
    averageTemperatureK = null;
  }
}

/// Running-average flow rate — 300 samples.
class FlowRateSampler {
  FlowRateSampler({required this.dividerX, required this.particles});

  final double dividerX;
  final List<Particle> particles;

  double leftFlowRate = 0;
  double rightFlowRate = 0;

  final List<int> _leftCounts = [];
  final List<int> _rightCounts = [];
  final List<double> _dts = [];

  void reset() {
    leftFlowRate = 0;
    rightFlowRate = 0;
    _leftCounts.clear();
    _rightCounts.clear();
    _dts.clear();
  }

  void step(double dtPs) {
    assert(dtPs > 0);
    var leftCount = 0;
    var rightCount = 0;
    for (final p in particles) {
      if (p.prevX >= dividerX && p.x < dividerX) {
        leftCount++;
      } else if (p.prevX <= dividerX && p.x > dividerX) {
        rightCount++;
      }
    }
    _leftCounts.add(leftCount);
    _rightCounts.add(rightCount);
    _dts.add(dtPs);
    while (_leftCounts.length > GasPropertiesConstants.flowRateSampleCount) {
      _leftCounts.removeAt(0);
      _rightCounts.removeAt(0);
      _dts.removeAt(0);
    }
    final n = _leftCounts.length;
    final leftAvg = _leftCounts.fold<int>(0, (a, b) => a + b) / n;
    final rightAvg = _rightCounts.fold<int>(0, (a, b) => a + b) / n;
    final dtAvg = _dts.fold<double>(0, (a, b) => a + b) / n;
    leftFlowRate = leftAvg / dtAvg;
    rightFlowRate = rightAvg / dtAvg;
  }
}

/// Independent Diffusion model — no Ideal Gas Law.
class DiffusionModel {
  DiffusionModel({RandomSource? random}) : random = random ?? RandomSource() {
    flowRate1 = FlowRateSampler(dividerX: container.dividerX, particles: particles1);
    flowRate2 = FlowRateSampler(dividerX: container.dividerX, particles: particles2);
    clock = SimulationClock();
  }

  final RandomSource random;
  final DiffusionContainer container = DiffusionContainer();
  final DiffusionSideSettings leftSettings = DiffusionSideSettings();
  final DiffusionSideSettings rightSettings = DiffusionSideSettings();
  final List<Particle> particles1 = [];
  final List<Particle> particles2 = [];
  final DiffusionSideData leftData = DiffusionSideData();
  final DiffusionSideData rightData = DiffusionSideData();

  late final FlowRateSampler flowRate1;
  late final FlowRateSampler flowRate2;
  late final SimulationClock clock;

  double? centerOfMass1;
  double? centerOfMass2;
  int _nextId = 1;

  bool get settingsEnabled => container.hasDivider;
  int get numberOfParticles => particles1.length + particles2.length;

  void setSlow(bool slow) => clock.setSlow(slow);

  void stepRealTime(double realSeconds) {
    final dt = clock.stepRealTime(realSeconds);
    if (dt > 0) stepModelTime(dt);
  }

  void stepOnce() {
    final dt = clock.stepOnce();
    stepModelTime(dt);
  }

  void stepModelTime(double dtPs) {
    assert(dtPs > 0);
    for (final p in particles1) {
      p.step(dtPs);
    }
    for (final p in particles2) {
      p.step(dtPs);
    }
    if (!container.hasDivider) {
      flowRate1.step(dtPs);
      flowRate2.step(dtPs);
    }
    _collide();
    _updateCenterOfMass();
    _updateData();
  }

  void _collide() {
    // Particle-particle within species; cross when open.
    CollisionSolver.doParticleParticleCollisions(particles1);
    CollisionSolver.doParticleParticleCollisions(particles2);
    if (!container.hasDivider) {
      _crossCollisions();
    }
    if (container.hasDivider) {
      CollisionSolver.doParticleContainerCollisions(
        particles1,
        left: container.left,
        right: container.leftMaxX,
        bottom: container.bottom,
        top: container.top,
      );
      CollisionSolver.doParticleContainerCollisions(
        particles2,
        left: container.rightMinX,
        right: container.right,
        bottom: container.bottom,
        top: container.top,
      );
    } else {
      CollisionSolver.doParticleContainerCollisions(
        particles1,
        left: container.left,
        right: container.right,
        bottom: container.bottom,
        top: container.top,
      );
      CollisionSolver.doParticleContainerCollisions(
        particles2,
        left: container.left,
        right: container.right,
        bottom: container.bottom,
        top: container.top,
      );
    }
  }

  void _crossCollisions() {
    for (final p1 in particles1) {
      for (final p2 in particles2) {
        if (!p1.contactedParticle(p2) && p1.contactsParticle(p2)) {
          CollisionSolver.doParticleParticleCollisions([p1, p2]);
        }
      }
    }
  }

  void setLeftCount(int n) {
    if (!settingsEnabled && n != leftSettings.numberOfParticles) return;
    _setCount(DiffusionSideSettings.clampCount(n), leftSettings, particles1, left: true);
  }

  void setRightCount(int n) {
    if (!settingsEnabled && n != rightSettings.numberOfParticles) return;
    _setCount(DiffusionSideSettings.clampCount(n), rightSettings, particles2, left: false);
  }

  void _setCount(
    int n,
    DiffusionSideSettings settings,
    List<Particle> particles, {
    required bool left,
  }) {
    settings.numberOfParticles = n;
    particles.clear();
    for (var i = 0; i < n; i++) {
      particles.add(_createParticle(settings, left: left));
    }
    _updateCenterOfMass();
    _updateData();
  }

  Particle _createParticle(DiffusionSideSettings s, {required bool left}) {
    final r = s.radius.toDouble();
    final minX = left ? container.left + r : container.rightMinX + r;
    final maxX = left ? container.leftMaxX - r : container.right - r;
    final minY = container.bottom + r;
    final maxY = container.top - r;
    final x = minX + random.nextDouble() * (maxX - minX);
    final y = minY + random.nextDouble() * (maxY - minY);
    final speed = math.sqrt(
      3 * GasPropertiesConstants.boltzmann * s.initialTemperature / s.mass,
    );
    final angle = random.nextDouble() * 2 * math.pi;
    final p = Particle(
      id: _nextId++,
      type: ParticleType.heavy, // type unused; mass/radius overridden
      mass: s.mass.toDouble(),
      radius: r,
      x: x,
      y: y,
    );
    p.prevX = x;
    p.prevY = y;
    p.setVelocityPolar(speed, angle);
    return p;
  }

  void setLeftMass(int m) {
    if (!settingsEnabled) return;
    leftSettings.mass = DiffusionSideSettings.clampMass(m);
    for (final p in particles1) {
      p.mass = leftSettings.mass.toDouble();
      p.setSpeed(math.sqrt(
        3 *
            GasPropertiesConstants.boltzmann *
            leftSettings.initialTemperature /
            p.mass,
      ));
    }
    _updateData();
  }

  void setRightMass(int m) {
    if (!settingsEnabled) return;
    rightSettings.mass = DiffusionSideSettings.clampMass(m);
    for (final p in particles2) {
      p.mass = rightSettings.mass.toDouble();
      p.setSpeed(math.sqrt(
        3 *
            GasPropertiesConstants.boltzmann *
            rightSettings.initialTemperature /
            p.mass,
      ));
    }
    _updateData();
  }

  void setLeftRadius(int r) {
    if (!settingsEnabled) return;
    leftSettings.radius = DiffusionSideSettings.clampRadius(r);
    for (final p in particles1) {
      p.radius = leftSettings.radius.toDouble();
    }
  }

  void setRightRadius(int r) {
    if (!settingsEnabled) return;
    rightSettings.radius = DiffusionSideSettings.clampRadius(r);
    for (final p in particles2) {
      p.radius = rightSettings.radius.toDouble();
    }
  }

  void setLeftTemperature(int t) {
    if (!settingsEnabled) return;
    leftSettings.initialTemperature = DiffusionSideSettings.clampTemperature(t);
    for (final p in particles1) {
      p.setSpeed(math.sqrt(
        3 *
            GasPropertiesConstants.boltzmann *
            leftSettings.initialTemperature /
            p.mass,
      ));
    }
    _updateData();
  }

  void setRightTemperature(int t) {
    if (!settingsEnabled) return;
    rightSettings.initialTemperature =
        DiffusionSideSettings.clampTemperature(t);
    for (final p in particles2) {
      p.setSpeed(math.sqrt(
        3 *
            GasPropertiesConstants.boltzmann *
            rightSettings.initialTemperature /
            p.mass,
      ));
    }
    _updateData();
  }

  void setHasDivider(bool value) {
    if (container.hasDivider == value) return;
    container.setHasDivider(value);
    if (value) {
      leftSettings.numberOfParticles = particles1.length;
      rightSettings.numberOfParticles = particles2.length;
      setLeftCount(leftSettings.numberOfParticles);
      setRightCount(rightSettings.numberOfParticles);
      flowRate1.reset();
      flowRate2.reset();
    }
  }

  void _updateCenterOfMass() {
    centerOfMass1 = _comX(particles1);
    centerOfMass2 = _comX(particles2);
  }

  double? _comX(List<Particle> particles) {
    if (particles.isEmpty) return null;
    var num = 0.0;
    var den = 0.0;
    for (final p in particles) {
      num += p.mass * p.x;
      den += p.mass;
    }
    return num / den;
  }

  void _updateData() {
    _fillSide(leftData, (x) => container.inLeft(x));
    _fillSide(rightData, (x) => container.inRight(x));
  }

  void _fillSide(DiffusionSideData data, bool Function(double x) inSide) {
    var n1 = 0;
    var n2 = 0;
    var totalKe = 0.0;
    for (final p in particles1) {
      if (inSide(p.x)) {
        n1++;
        totalKe += p.kineticEnergy;
      }
    }
    for (final p in particles2) {
      if (inSide(p.x)) {
        n2++;
        totalKe += p.kineticEnergy;
      }
    }
    data.numberOfParticles1 = n1;
    data.numberOfParticles2 = n2;
    final total = n1 + n2;
    if (total == 0) {
      data.averageTemperatureK = null;
    } else {
      data.averageTemperatureK =
          (2 / 3) * (totalKe / total) / GasPropertiesConstants.boltzmann;
    }
  }

  void reset() {
    clock.reset();
    container.reset();
    leftSettings.reset();
    rightSettings.reset();
    particles1.clear();
    particles2.clear();
    leftData.reset();
    rightData.reset();
    flowRate1.reset();
    flowRate2.reset();
    centerOfMass1 = null;
    centerOfMass2 = null;
  }
}
