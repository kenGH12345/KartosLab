import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'molarity_constants.dart';
import 'molarity_math.dart';
import 'solute.dart';
import 'solvent.dart';

/// Solution model — source: `js/molarity/model/Solution.js`.
///
/// Intrinsic: [solute] / [soluteAmount] / [volume]
/// Derived (getters only — reactive, no `step(dt)`):
/// - [concentration] = toFixedNumber(min(C_sat, n/V), 3)  (0 if V≤0)
/// - [precipitateAmount] = max(0, n − V·C_sat) when V>0; else n
/// - [isSaturated] ⇔ precipitateAmount ≠ 0
/// - [numberOfParticles] from global PARTICLES_PER_MOLE=200
///
/// Cross-sim isolation: do **not** import Beer's Law Lab / Concentration physics.
class Solution extends ChangeNotifier {
  Solution({
    required this.solvent,
    required this.solute,
    double soluteAmount = MolarityConstants.soluteAmountDefault,
    double volume = MolarityConstants.volumeDefault,
  })  : _soluteAmount = MolarityConstants.constrainSoluteAmount(soluteAmount),
        _volume = _constrainVolumeAllowZero(volume);

  final Solvent solvent;

  /// Current solute (intrinsic).
  Solute solute;

  double _soluteAmount;
  double _volume;

  /// Solute amount (mol), range 0…1, 3 decimal places.
  double get soluteAmount => _soluteAmount;

  /// Solution volume (L). UI range 0.2…1; Model allows 0 for defensive tests.
  double get volume => _volume;

  /// Molarity (mol/L) — Derived with source precision.
  ///
  /// ```
  /// volume > 0
  ///   ? toFixedNumber(min(C_sat, n/V), 3)
  ///   : 0
  /// ```
  double get concentration {
    if (_volume <= 0) return 0;
    final raw = math.min(
      solute.saturatedConcentration,
      _soluteAmount / _volume,
    );
    return MolarityMath.toFixedNumber(
      raw,
      MolarityConstants.concentrationDecimalPlaces,
    );
  }

  /// Precipitate (mol) — CODE wins over doc/model.md.
  ///
  /// ```
  /// volume > 0 ? max(0, n - V*C_sat) : n
  /// ```
  double get precipitateAmount {
    if (_volume <= 0) return _soluteAmount;
    return math.max(
      0.0,
      _volume *
          ((_soluteAmount / _volume) - solute.saturatedConcentration),
    );
  }

  /// Source: `precipitateAmountProperty.value !== 0`.
  bool get isSaturated => precipitateAmount != 0;

  /// Source: `atMaxConcentration()`.
  bool get atMaxConcentration =>
      solute.saturatedConcentration == concentration;

  /// Source: `hasSolute()` — concentration > 0.
  bool get hasSolute => concentration > 0;

  /// View-facing particle count — source `PrecipitateNode.getNumberOfParticles`.
  int get numberOfParticles {
    final amount = precipitateAmount;
    var n = (MolarityConstants.particlesPerMole * amount).floor();
    if (n == 0 && amount > 0) n = 1;
    return n;
  }

  /// Solution color — source `getColor()`.
  /// C=0 → Water; else interpolate(minColor, maxColor, C/C_sat).
  Color get solutionColor {
    if (concentration <= 0) return solvent.color;
    final sat = solute.saturatedConcentration;
    if (sat <= 0) return solute.solutionColor.maxColor;
    final t = MolarityMath.linear(0, sat, 0, 1, concentration);
    return solute.solutionColor.interpolate(t);
  }

  /// Beaker label formula — source `BeakerLabelNode`.
  /// volume==0 → ''; concentration==0 → H₂O; else solute.formula.
  String get beakerLabel {
    if (_volume == 0) return '';
    if (concentration == 0) return solvent.formula;
    return solute.formula;
  }

  void setSolute(Solute v) {
    solute = v;
    notifyListeners();
  }

  /// Constrains to 0…1 with 3 decimal places (slider contract).
  void setSoluteAmount(double v) {
    _soluteAmount = MolarityConstants.constrainSoluteAmount(v);
    notifyListeners();
  }

  /// Constrains to UI range 0.2…1 with 3 dp, **except** volume==0 for tests.
  void setVolume(double v) {
    _volume = _constrainVolumeAllowZero(v);
    notifyListeners();
  }

  void reset({
    required Solute solute,
    double soluteAmount = MolarityConstants.soluteAmountDefault,
    double volume = MolarityConstants.volumeDefault,
  }) {
    this.solute = solute;
    _soluteAmount = MolarityConstants.constrainSoluteAmount(soluteAmount);
    _volume = MolarityConstants.constrainVolume(volume);
    notifyListeners();
  }

  /// Static helper — source `Solution.computePrecipitateAmount`.
  static double computePrecipitateAmount(
    double volume,
    double soluteAmount,
    double saturatedConcentration,
  ) {
    if (volume <= 0) return soluteAmount;
    return math.max(
      0.0,
      volume * ((soluteAmount / volume) - saturatedConcentration),
    );
  }

  /// Allow exactly 0 for defensive Model tests; otherwise UI clamp.
  static double _constrainVolumeAllowZero(double value) {
    if (value == 0) return 0;
    return MolarityConstants.constrainVolume(value);
  }
}
