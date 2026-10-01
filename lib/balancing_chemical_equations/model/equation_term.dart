import 'package:flutter/foundation.dart';

import 'bce_molecule.dart';

/// Integer coefficient range for an [EquationTerm] (PhET `dot.Range`).
@immutable
class CoefficientRange {
  const CoefficientRange(this.min, this.max)
      : assert(min >= 0),
        assert(max >= min);

  final int min;
  final int max;

  bool contains(int value) => value >= min && value <= max;

  int clamp(int value) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}

/// Screen-specific coefficient ranges from PhET source.
abstract final class BceCoefficientRanges {
  static const intro = CoefficientRange(0, 3);
  static const equations = CoefficientRange(0, 6);
  static const game = CoefficientRange(0, 7);
}

/// PhET `EquationTerm` — one side term: balanced answer + user coefficient + molecule.
class EquationTerm extends ChangeNotifier {
  EquationTerm({
    required this.balancedCoefficient,
    required this.molecule,
    required this.coefficientRange,
    int? initialCoefficient,
  })  : assert(balancedCoefficient > 0),
        _initialCoefficient =
            initialCoefficient ?? BcePreferences.instance.initialCoefficient,
        _coefficient =
            initialCoefficient ?? BcePreferences.instance.initialCoefficient {
    assert(coefficientRange.contains(_coefficient));
  }

  /// Lowest positive integer coefficient that balances the equation (canonical).
  final int balancedCoefficient;

  final BceMolecule molecule;
  final CoefficientRange coefficientRange;

  int _initialCoefficient;
  int _coefficient;

  int get coefficient => _coefficient;

  /// User / display coefficient. Clamped to [coefficientRange]. Integer only.
  set coefficient(int value) {
    final next = coefficientRange.clamp(value);
    if (next == _coefficient) return;
    _coefficient = next;
    notifyListeners();
  }

  void increment() => coefficient = _coefficient + 1;
  void decrement() => coefficient = _coefficient - 1;

  /// Change the reset target and optionally reset (PhET `setInitialValue` + reset).
  void setInitialCoefficient(int value, {bool resetNow = true}) {
    final next = coefficientRange.clamp(value);
    _initialCoefficient = next;
    if (resetNow) {
      reset();
    }
  }

  void reset() {
    if (_coefficient == _initialCoefficient) return;
    _coefficient = _initialCoefficient;
    notifyListeners();
  }
}

/// PhET `BCEPreferences.initialCoefficientProperty` — global 0 or 1.
class BcePreferences {
  BcePreferences._();
  static final instance = BcePreferences._();

  static const validInitialCoefficients = [0, 1];

  int _initialCoefficient = 1;

  int get initialCoefficient => _initialCoefficient;

  set initialCoefficient(int value) {
    assert(validInitialCoefficients.contains(value));
    _initialCoefficient = value;
  }

  void reset() {
    _initialCoefficient = 1;
  }
}
