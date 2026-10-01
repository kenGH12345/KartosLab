import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/projectile_motion/model/projectile_motion_model.dart';
import 'package:kratos/projectile_motion/pm_constants.dart';

/// VectorsDisplayEnumeration.ts
enum PmVectorsDisplay { total, components }

/// ProjectileMotionViewProperties + 各屏子类的 Flutter 等价。
///
/// 各屏可用性（见 PHASE_1 §3）：
/// - Intro：独立 4 个 checkbox（V total/components，A total/components），无力
/// - Vectors：display 单选 + V/A/F 三开关
/// - Drag：display 单选 + V/F 两开关（无 A）
/// - Lab：无向量 UI
class PmViewProperties extends ChangeNotifier {
  PmViewProperties({
    required this.hasForceVectors,
    required this.hasAccelerationVectors,
    required this.usesDisplayEnumeration,
  });

  final bool hasForceVectors;
  final bool hasAccelerationVectors;
  final bool usesDisplayEnumeration;

  // Intro 独立开关
  bool _totalVelocityVectorOn = false;
  bool _componentsVelocityVectorsOn = false;
  bool _totalAccelerationVectorOn = false;
  bool _componentsAccelerationVectorsOn = false;

  // Vectors / Drag
  PmVectorsDisplay _vectorsDisplay = PmVectorsDisplay.total;
  bool _velocityVectorsOn = false;
  bool _accelerationVectorsOn = false;
  bool _forceVectorsOn = false;

  bool get totalVelocityVectorOn => _totalVelocityVectorOn;
  bool get componentsVelocityVectorsOn => _componentsVelocityVectorsOn;
  bool get totalAccelerationVectorOn => _totalAccelerationVectorOn;
  bool get componentsAccelerationVectorsOn => _componentsAccelerationVectorsOn;
  PmVectorsDisplay get vectorsDisplay => _vectorsDisplay;
  bool get velocityVectorsOn => _velocityVectorsOn;
  bool get accelerationVectorsOn => _accelerationVectorsOn;
  bool get forceVectorsOn => _forceVectorsOn;

  // ── 有效可见性（VectorsViewProperties.ts:81-98 等价）───────────────────

  bool get showTotalVelocityVector => usesDisplayEnumeration
      ? _velocityVectorsOn && _vectorsDisplay == PmVectorsDisplay.total
      : _totalVelocityVectorOn;

  bool get showVelocityComponentVectors => usesDisplayEnumeration
      ? _velocityVectorsOn && _vectorsDisplay == PmVectorsDisplay.components
      : _componentsVelocityVectorsOn;

  bool get showTotalAccelerationVector =>
      hasAccelerationVectors &&
      (usesDisplayEnumeration
          ? _accelerationVectorsOn && _vectorsDisplay == PmVectorsDisplay.total
          : _totalAccelerationVectorOn);

  bool get showAccelerationComponentVectors =>
      hasAccelerationVectors &&
      (usesDisplayEnumeration
          ? _accelerationVectorsOn &&
              _vectorsDisplay == PmVectorsDisplay.components
          : _componentsAccelerationVectorsOn);

  bool get showTotalForceVector =>
      hasForceVectors &&
      _forceVectorsOn && _vectorsDisplay == PmVectorsDisplay.total;

  bool get showForceComponentVectors =>
      hasForceVectors &&
      _forceVectorsOn && _vectorsDisplay == PmVectorsDisplay.components;

  // ── Setters ────────────────────────────────────────────────────────────

  void setTotalVelocityVectorOn(bool v) {
    _totalVelocityVectorOn = v;
    notifyListeners();
  }

  void setComponentsVelocityVectorsOn(bool v) {
    _componentsVelocityVectorsOn = v;
    notifyListeners();
  }

  void setTotalAccelerationVectorOn(bool v) {
    _totalAccelerationVectorOn = v;
    notifyListeners();
  }

  void setComponentsAccelerationVectorsOn(bool v) {
    _componentsAccelerationVectorsOn = v;
    notifyListeners();
  }

  void setVectorsDisplay(PmVectorsDisplay v) {
    _vectorsDisplay = v;
    notifyListeners();
  }

  void setVelocityVectorsOn(bool v) {
    _velocityVectorsOn = v;
    notifyListeners();
  }

  void setAccelerationVectorsOn(bool v) {
    _accelerationVectorsOn = v;
    notifyListeners();
  }

  void setForceVectorsOn(bool v) {
    _forceVectorsOn = v;
    notifyListeners();
  }

  void reset() {
    _totalVelocityVectorOn = false;
    _componentsVelocityVectorsOn = false;
    _totalAccelerationVectorOn = false;
    _componentsAccelerationVectorsOn = false;
    _vectorsDisplay = PmVectorsDisplay.total;
    _velocityVectorsOn = false;
    _accelerationVectorsOn = false;
    _forceVectorsOn = false;
    notifyListeners();
  }
}

/// Clock + model 桥接（仿 PendulumLabController）。
class ProjectileMotionController extends ChangeNotifier {
  ProjectileMotionController(this.model, this.viewProperties)
      : clock = SimulationClock(fps: 60) {
    model.addListener(_onChanged);
    viewProperties.addListener(_onChanged);
  }

  final ProjectileMotionModel model;
  final PmViewProperties viewProperties;
  final SimulationClock clock;

  void _onChanged() => notifyListeners();

  void attach(TickerProvider vsync) {
    clock.attach(vsync);
    clock.onTick = (dt, _) => model.step(dt);
    if (model.isPlaying) {
      clock.play();
    }
  }

  void setPlaying(bool playing) {
    model.setPlaying(playing);
    if (playing) {
      clock.play();
    } else {
      clock.pause();
    }
  }

  /// Step 按钮：恒定 0.012s 单步（ScreenView:382-384）
  void stepManual() {
    if (clock.isRunning) return;
    model.stepModelElements(PmConstants.timePerDataPoint);
    model.setPlaying(false);
    notifyListeners();
  }

  void fire() => model.fire();

  void reset() {
    model.reset();
    viewProperties.reset();
    clock.reset();
    if (model.isPlaying) {
      clock.play();
    } else {
      clock.pause();
    }
  }

  @override
  void dispose() {
    model.removeListener(_onChanged);
    viewProperties.removeListener(_onChanged);
    clock.dispose();
    model.dispose();
    viewProperties.dispose();
    super.dispose();
  }
}
