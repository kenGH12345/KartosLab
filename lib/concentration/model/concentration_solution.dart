import 'dart:math' as math;
import 'dart:ui';

import 'solute.dart';
import 'solvent.dart';
import 'concentration_constants.dart';

/// Solution in the beaker — beers-law-lab `ConcentrationSolution.ts`.
///
/// Intrinsic: [soluteMoles], [volume].
/// Derived: concentration, precipitateMoles, percentConcentration, color.
/// [isSaturated] is updated explicitly (source: end of `step`), not as a pure getter.
class ConcentrationSolution {
  ConcentrationSolution({
    required Solute solute,
    double soluteMoles = 0,
    double volume = 0.5,
  })  : _solute = solute,
        _soluteMoles = soluteMoles,
        _volume = volume;

  final Solvent solvent = Solvent.water;

  Solute _solute;
  double _soluteMoles;
  double _volume;

  /// When false, [precipitateMoles] returns the last cached value
  /// (dropper atomic volume+solute update — concentration#1).
  bool updatePrecipitateAmount = true;
  double _cachedPrecipitateMoles = 0;

  bool _isSaturated = false;

  Solute get solute => _solute;

  /// Total solute (dissolved + precipitate), mol.
  double get soluteMoles => _soluteMoles;

  /// Solution volume, L (solvent; solute displacement ignored).
  double get volume => _volume;

  bool get isSaturated => _isSaturated;

  double get saturatedConcentration => _solute.saturatedConcentration;

  double get precipitateMoles {
    if (!updatePrecipitateAmount) {
      return _cachedPrecipitateMoles;
    }
    final p = math.max(0.0, _soluteMoles - (_volume * saturatedConcentration));
    _cachedPrecipitateMoles = p;
    return p;
  }

  /// Dissolved solute moles.
  double get dissolvedMoles => math.max(0.0, _soluteMoles - precipitateMoles);

  /// M = min(saturated, moles/L); 0 when empty.
  double get concentration {
    if (_volume <= 0) return 0;
    return math.min(saturatedConcentration, _soluteMoles / _volume);
  }

  /// Grams of dissolved solute.
  double get soluteGrams => _solute.molarMass * dissolvedMoles;

  /// Mass percent concentration [0, 100].
  double get percentConcentration {
    if (_volume <= 0) return 0;
    final solventGrams = _volume * solvent.density;
    final grams = soluteGrams;
    return 100 * (grams / (grams + solventGrams));
  }

  Color get color {
    if (concentration <= 0) return solvent.color;
    return _solute.colorScheme.concentrationToColor(concentration);
  }

  /// Source `getNumberOfPrecipitateParticles`.
  int get numberOfPrecipitateParticles {
    var n = (_solute.particlesPerMole * precipitateMoles).round();
    if (n == 0 && precipitateMoles > 0) {
      n = 1;
    }
    return n;
  }

  void setSolute(Solute value) {
    _solute = value;
  }

  void setSoluteMoles(double value) {
    _soluteMoles = value.clamp(
      ConcentrationConstants.soluteAmountMin,
      ConcentrationConstants.soluteAmountMax,
    );
  }

  void setVolume(double value) {
    _volume = value.clamp(
      ConcentrationConstants.solutionVolumeMin,
      ConcentrationConstants.solutionVolumeMax,
    );
  }

  /// Source `updateIsSaturatedProperty` — call at end of `step`.
  void updateIsSaturated() {
    _isSaturated = (_volume > 0) &&
        (_soluteMoles / _volume) > saturatedConcentration;
  }

  void reset({
    required Solute solute,
    double soluteMoles = 0,
    double volume = 0.5,
  }) {
    _solute = solute;
    _soluteMoles = soluteMoles;
    _volume = volume;
    updatePrecipitateAmount = true;
    _cachedPrecipitateMoles = 0;
    _isSaturated = false;
  }
}
