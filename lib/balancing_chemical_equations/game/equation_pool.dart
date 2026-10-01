import 'dart:math';

import '../model/equation.dart';

/// PhET `EquationPool` — random challenge selection with exclusions + firstBigMolecule.
class EquationPool {
  EquationPool({
    required List<Equation> pool,
    this.firstBigMolecule = true,
    Map<Equation, List<Equation>>? exclusionsMap,
    Random? random,
  })  : _pool = List.unmodifiable(pool),
        _exclusionsMap = exclusionsMap,
        _random = random ?? Random();

  final List<Equation> _pool;
  final bool firstBigMolecule;
  final Map<Equation, List<Equation>>? _exclusionsMap;
  final Random _random;

  int get poolSize => _pool.length;

  Equation getEquation(int index) => _pool[index];

  void reset() {
    for (final e in _pool) {
      e.reset();
    }
  }

  /// Randomly select [numberOfEquations] without duplicates.
  List<Equation> getEquations(int numberOfEquations) {
    final poolCopy = List<Equation>.from(_pool);
    final equations = <Equation>[];

    for (var i = 0; i < numberOfEquations; i++) {
      assert(poolCopy.isNotEmpty);
      var equation = poolCopy[_random.nextInt(poolCopy.length)];

      if (i == 0 && !firstBigMolecule && equation.hasBigMolecule) {
        final startIndex = _random.nextInt(poolCopy.length);
        var index = startIndex;
        var done = false;
        while (!done) {
          equation = poolCopy[index];
          if (!equation.hasBigMolecule) {
            done = true;
          } else {
            index++;
            if (index > poolCopy.length - 1) index = 0;
            if (index == startIndex) done = true;
          }
        }
      }

      equation.reset();
      equations.add(equation);
      poolCopy.remove(equation);

      final exclusions = _exclusionsMap?[equation];
      if (exclusions != null) {
        for (final exclusion in exclusions) {
          poolCopy.remove(exclusion);
        }
      }
    }

    assert(equations.length == numberOfEquations);
    if (!firstBigMolecule) {
      assert(!equations.first.hasBigMolecule);
    }
    return equations;
  }
}
