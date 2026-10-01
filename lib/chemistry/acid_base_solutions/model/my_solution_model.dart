import 'abs_constants.dart';
import 'abs_model.dart';
import 'solutions/aqueous_solution.dart';
import 'solutions/strong_acid.dart';
import 'solutions/strong_base.dart';
import 'solutions/weak_acid.dart';
import 'solutions/weak_base.dart';

/// My Solution screen model — PhET `MySolutionModel.ts`.
///
/// No Water. Solution type is derived from [isAcid] × [isWeak].
/// [concentration] syncs to all solutions; [strength] syncs to weak only.
class MySolutionModel extends AbsModel {
  factory MySolutionModel() {
    final strongAcid = StrongAcid();
    final weakAcid = WeakAcid();
    final strongBase = StrongBase();
    final weakBase = WeakBase();
    return MySolutionModel._(
      strongAcid: strongAcid,
      weakAcid: weakAcid,
      strongBase: strongBase,
      weakBase: weakBase,
      solutions: [strongAcid, weakAcid, strongBase, weakBase],
    );
  }

  MySolutionModel._({
    required this.strongAcid,
    required this.weakAcid,
    required this.strongBase,
    required this.weakBase,
    required super.solutions,
  })  : _concentration = AbsConstants.concentrationRange.defaultValue,
        _strength = AbsConstants.weakStrengthRange.defaultValue,
        super(initialSolution: weakAcid) {
    _syncConcentration();
    _syncStrength();
  }

  final StrongAcid strongAcid;
  final WeakAcid weakAcid;
  final StrongBase strongBase;
  final WeakBase weakBase;

  bool _isAcid = true;
  bool _isWeak = true;

  /// Acid (true) vs Base (false). Default: Acid.
  bool get isAcid => _isAcid;

  set isAcid(bool value) {
    _isAcid = value;
    _applyTypeSwitches();
  }

  /// Weak (true) vs Strong (false). Default: weak.
  bool get isWeak => _isWeak;

  set isWeak(bool value) {
    _isWeak = value;
    _applyTypeSwitches();
  }

  double _concentration;
  double _strength;

  /// Solute concentration C (mol/L) — written to all solutions.
  double get concentration => _concentration;

  set concentration(double value) {
    _concentration = AbsConstants.concentrationRange.constrain(value);
    _syncConcentration();
    pHPaper.onSolutionOrPhChanged();
  }

  /// Ka/Kb ionization constant — written to weak solutions only.
  /// Source documentation: acid or base ionization constant.
  double get strength => _strength;

  set strength(double value) {
    _strength = AbsConstants.weakStrengthRange.constrain(value);
    _syncStrength();
    pHPaper.onSolutionOrPhChanged();
  }

  /// Derived selection matching source `DerivedProperty([isAcid, isWeak], ...)`.
  AqueousSolution get derivedSolution {
    if (_isWeak && _isAcid) return weakAcid;
    if (_isWeak && !_isAcid) return weakBase;
    if (!_isWeak && _isAcid) return strongAcid;
    return strongBase;
  }

  void _applyTypeSwitches() {
    final next = derivedSolution;
    if (!identical(solution, next)) {
      selectSolution(next);
    }
  }

  void _syncConcentration() {
    for (final s in solutions) {
      s.concentration = _concentration;
    }
  }

  void _syncStrength() {
    // Strong solutions have constant strength — do not synchronize.
    // See https://github.com/phetsims/acid-base-solutions/issues/94
    weakAcid.strength = _strength;
    weakBase.strength = _strength;
  }

  @override
  void reset() {
    // Source: reset isAcid, isWeak, concentration, strength Properties only,
    // then tools. Links rewrite solution concentration/strength.
    _isAcid = true;
    _isWeak = true;
    _concentration = AbsConstants.concentrationRange.defaultValue;
    _strength = AbsConstants.weakStrengthRange.defaultValue;
    for (final s in solutions) {
      s.reset();
    }
    _syncConcentration();
    _syncStrength();
    selectSolution(weakAcid);
    super.reset();
  }
}
