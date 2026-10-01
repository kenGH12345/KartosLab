import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'ph_chemistry.dart';
import 'ph_scale_constants.dart';
import 'solution_derived_properties.dart';
import 'water.dart';

/// My Solution screen solution — PhET `MySolution.ts`.
///
/// Intrinsic: writable [pH] + [totalVolume]. Color fixed to water.
class MySolution extends ChangeNotifier {
  MySolution({
    double pH = 7,
    double volume = 0.5,
    this.maxVolume = 1.2,
  })  : _pH = pH,
        _totalVolume = volume {
    derived = SolutionDerivedProperties(pH: _pH, totalVolume: _totalVolume);
  }

  final double maxVolume;
  double _pH;
  double _totalVolume;
  late final SolutionDerivedProperties derived;

  double get pH => _pH;
  double get totalVolume => _totalVolume;
  Color get color => Water.color;

  set pH(double v) {
    final clamped = v.clamp(PhScaleConstants.phMin, PhScaleConstants.phMax);
    if (_pH == clamped) return;
    _pH = clamped;
    derived.update(pH: _pH, totalVolume: _totalVolume);
    notifyListeners();
  }

  set totalVolume(double v) {
    final clamped = v.clamp(0.01, maxVolume);
    if (_totalVolume == clamped) return;
    _totalVolume = clamped;
    derived.update(pH: _pH, totalVolume: _totalVolume);
    notifyListeners();
  }

  /// Graph indicator / spinner drive pH from concentration or moles.
  void setPHFromConcentrationH3O(ConcentrationValue c) {
    final next = PhChemistry.concentrationH3OToPH(c);
    if (next != null) pH = next;
  }

  void setPHFromConcentrationOH(ConcentrationValue c) {
    final next = PhChemistry.concentrationOHToPH(c);
    if (next != null) pH = next;
  }

  void reset() {
    _pH = 7;
    _totalVolume = 0.5;
    derived.update(pH: _pH, totalVolume: _totalVolume);
    notifyListeners();
  }
}

/// My Solution screen model — PhET `MySolutionModel.ts`.
class MySolutionModel extends ChangeNotifier {
  MySolutionModel() {
    solution = MySolution();
    solution.addListener(notifyListeners);
  }

  late final MySolution solution;

  void reset() {
    solution.reset();
  }

  @override
  void dispose() {
    solution.removeListener(notifyListeners);
    solution.dispose();
    super.dispose();
  }
}
