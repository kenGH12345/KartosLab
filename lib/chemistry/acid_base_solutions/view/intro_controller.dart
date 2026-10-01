import 'dart:math';

import 'package:flutter/foundation.dart';

import '../model/abs_particle_field.dart';
import '../model/abs_preferences.dart';
import '../model/abs_view_properties.dart';
import '../model/intro_model.dart';
import '../model/solutions/aqueous_solution.dart';

/// Owns Intro model + view properties + cached particle layout.
///
/// Particles regenerate only when the selected [AqueousSolution] instance
/// changes (or on reset) — never on unrelated rebuilds.
class IntroController extends ChangeNotifier {
  IntroController({
    IntroModel? model,
    AbsViewProperties? viewProperties,
    AbsPreferences? preferences,
    Random? random,
  })  : model = model ?? IntroModel(),
        viewProperties = viewProperties ?? AbsViewProperties(),
        preferences = preferences ?? AbsPreferences(),
        _ownsModel = model == null,
        particleField = AbsParticleField(random: random ?? Random()) {
    _regenerateParticles();
  }

  final IntroModel model;
  final AbsViewProperties viewProperties;
  final AbsPreferences preferences;
  final AbsParticleField particleField;
  final bool _ownsModel;

  List<AbsParticleInstance> _particles = const [];
  AqueousSolution? _layoutSolution;

  /// Magnifying-glass particle instances (excluding H2O).
  List<AbsParticleInstance> get particles => _particles;

  bool paperPressed = false;
  bool meterPressed = false;
  bool positiveProbePressed = false;
  bool negativeProbePressed = false;

  void selectSolution(AqueousSolution solution) {
    model.selectedSolution = solution;
    _regenerateParticles();
    notifyListeners();
  }

  void setViewMode(AbsViewMode mode) {
    if (viewProperties.viewMode == mode) return;
    viewProperties.viewMode = mode;
    notifyListeners();
  }

  void setToolMode(AbsToolMode mode) {
    if (viewProperties.toolMode == mode) return;
    viewProperties.toolMode = mode;
    // Interrupt tool interaction (source: interruptSubtreeInput).
    paperPressed = false;
    meterPressed = false;
    positiveProbePressed = false;
    negativeProbePressed = false;
    notifyListeners();
  }

  void setShowSolvent(bool value) {
    if (preferences.showSolvent == value) return;
    preferences.showSolvent = value;
    notifyListeners();
  }

  void notifyModelChanged() => notifyListeners();

  void resetAll() {
    model.reset();
    viewProperties.reset();
    paperPressed = false;
    meterPressed = false;
    positiveProbePressed = false;
    negativeProbePressed = false;
    _layoutSolution = null;
    _regenerateParticles();
    notifyListeners();
  }

  /// Simulation clock tick — drives pH paper float (250 px/s).
  void step(double dt) {
    final before = model.pHPaper.position;
    final wasAnimating = model.pHPaper.animating;
    model.pHPaper.step(dt, isPressed: paperPressed);
    if (model.pHPaper.position != before ||
        model.pHPaper.animating != wasAnimating) {
      notifyListeners();
    }
  }

  void _regenerateParticles() {
    final solution = model.solution;
    if (identical(_layoutSolution, solution) && _particles.isNotEmpty) {
      return;
    }
    _layoutSolution = solution;
    final lensRadius =
        AbsParticleField.lensRadiusForBeakerHeight(model.beaker.size.height);
    _particles = particleField.buildLayout(
      solution: solution,
      lensRadius: lensRadius,
    );
  }

  /// Force regenerate (e.g. after concentration change via test harness).
  void regenerateParticles() {
    _layoutSolution = null;
    _regenerateParticles();
    notifyListeners();
  }

  @override
  void dispose() {
    // IntroModel has no dispose; keep hook for symmetry.
    if (_ownsModel) {
      // no-op
    }
    super.dispose();
  }
}
