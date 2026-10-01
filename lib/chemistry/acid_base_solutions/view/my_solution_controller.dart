import 'dart:math';

import 'package:flutter/foundation.dart';

import '../model/abs_constants.dart';
import '../model/abs_math.dart';
import '../model/abs_particle_field.dart';
import '../model/abs_preferences.dart';
import '../model/abs_view_properties.dart';
import '../model/my_solution_model.dart';

/// Owns [MySolutionModel] + view properties + particle cache.
///
/// Particles regenerate when solution type, concentration, or strength
/// fingerprint changes (source links strength/concentration to particle
/// canvas update). Unrelated rebuilds keep positions.
class MySolutionController extends ChangeNotifier {
  MySolutionController({
    MySolutionModel? model,
    AbsViewProperties? viewProperties,
    AbsPreferences? preferences,
    Random? random,
  })  : model = model ?? MySolutionModel(),
        viewProperties = viewProperties ?? AbsViewProperties(),
        preferences = preferences ?? AbsPreferences(),
        _ownsModel = model == null,
        particleField = AbsParticleField(random: random ?? Random()) {
    _regenerateParticles(force: true);
  }

  final MySolutionModel model;
  final AbsViewProperties viewProperties;
  final AbsPreferences preferences;
  final AbsParticleField particleField;
  final bool _ownsModel;

  List<AbsParticleInstance> _particles = const [];
  Object? _fingerprint;

  List<AbsParticleInstance> get particles => _particles;

  bool paperPressed = false;
  bool meterPressed = false;
  bool positiveProbePressed = false;
  bool negativeProbePressed = false;

  Object _computeFingerprint() => (
        model.solution,
        model.concentration,
        model.strength,
        model.isAcid,
        model.isWeak,
      );

  void setIsAcid(bool value) {
    if (model.isAcid == value) return;
    model.isAcid = value;
    _afterChemistryChange();
  }

  void setIsWeak(bool value) {
    if (model.isWeak == value) return;
    model.isWeak = value;
    _afterChemistryChange();
  }

  void setConcentration(double value) {
    final next = AbsConstants.concentrationRange.constrain(value);
    if (model.concentration == next) return;
    model.concentration = next;
    _afterChemistryChange();
  }

  /// Spinner ±0.001 with 3-decimal fixed rounding — `InitialConcentrationControl`.
  void nudgeConcentration(int direction) {
    final delta = AbsConstants.deltaConcentration * direction;
    final next = AbsMath.toFixedNumber(
      model.concentration + delta,
      AbsConstants.concentrationDecimals,
    );
    setConcentration(next);
  }

  void setStrength(double value) {
    final next = AbsConstants.weakStrengthRange.constrain(value);
    if (model.strength == next) return;
    model.strength = next;
    _afterChemistryChange();
  }

  void setViewMode(AbsViewMode mode) {
    if (viewProperties.viewMode == mode) return;
    viewProperties.viewMode = mode;
    notifyListeners();
  }

  void setToolMode(AbsToolMode mode) {
    if (viewProperties.toolMode == mode) return;
    viewProperties.toolMode = mode;
    paperPressed = false;
    meterPressed = false;
    positiveProbePressed = false;
    negativeProbePressed = false;
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
    _regenerateParticles(force: true);
    notifyListeners();
  }

  void step(double dt) {
    final before = model.pHPaper.position;
    final wasAnimating = model.pHPaper.animating;
    model.pHPaper.step(dt, isPressed: paperPressed);
    if (model.pHPaper.position != before ||
        model.pHPaper.animating != wasAnimating) {
      notifyListeners();
    }
  }

  void _afterChemistryChange() {
    _regenerateParticles(force: false);
    notifyListeners();
  }

  void _regenerateParticles({required bool force}) {
    final fp = _computeFingerprint();
    if (!force && fp == _fingerprint && _particles.isNotEmpty) return;
    _fingerprint = fp;
    final lensRadius =
        AbsParticleField.lensRadiusForBeakerHeight(model.beaker.size.height);
    _particles = particleField.buildLayout(
      solution: model.solution,
      lensRadius: lensRadius,
    );
  }

  @override
  void dispose() {
    if (_ownsModel) {
      // no-op
    }
    super.dispose();
  }
}
