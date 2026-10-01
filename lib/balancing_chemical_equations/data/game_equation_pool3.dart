import '../model/bce_molecule.dart';
import '../model/equation.dart';
import '../model/equation_term.dart';

/// PhET `EquationPool3` — Game Level 3 (14 equations + exclusion map foundations).
///
/// Exclusion map (which equations cannot co-appear) is recorded for Phase 4 Game;
/// Phase 1 only guarantees the equation catalogue + balance semantics.
abstract final class GameEquationPool3 {
  static const range = BceCoefficientRanges.game;
  static const sourceCount = 14;

  static List<Equation> createAll({int? initialCoefficient}) {
    var i = 0;
    Equation twoTwo(
      int r1,
      BceMolecule a,
      int r2,
      BceMolecule b,
      int p1,
      BceMolecule c,
      int p2,
      BceMolecule d,
    ) =>
        Equation.create2Reactants2Products(
          id: 'game.level3.equation${i++}',
          r1: r1,
          reactant1: a,
          r2: r2,
          reactant2: b,
          p1: p1,
          product1: c,
          p2: p2,
          product2: d,
          coefficientsRange: range,
          initialCoefficient: initialCoefficient,
        );

    return [
      // C2H5OH + 3 O2 → 2 CO2 + 3 H2O
      twoTwo(1, BceMolecule.c2h5Oh, 3, BceMolecule.o2, 2, BceMolecule.co2, 3, BceMolecule.h2o),
      // reverse
      twoTwo(2, BceMolecule.co2, 3, BceMolecule.h2o, 1, BceMolecule.c2h5Oh, 3, BceMolecule.o2),
      // 2 C2H6 + 7 O2 → 4 CO2 + 6 H2O
      twoTwo(2, BceMolecule.c2h6, 7, BceMolecule.o2, 4, BceMolecule.co2, 6, BceMolecule.h2o),
      twoTwo(4, BceMolecule.co2, 6, BceMolecule.h2o, 2, BceMolecule.c2h6, 7, BceMolecule.o2),
      // 2 C2H2 + 5 O2 → 4 CO2 + 2 H2O
      twoTwo(2, BceMolecule.c2h2, 5, BceMolecule.o2, 4, BceMolecule.co2, 2, BceMolecule.h2o),
      twoTwo(4, BceMolecule.co2, 2, BceMolecule.h2o, 2, BceMolecule.c2h2, 5, BceMolecule.o2),
      // 4 NH3 + 3 O2 → 2 N2 + 6 H2O
      twoTwo(4, BceMolecule.nh3, 3, BceMolecule.o2, 2, BceMolecule.n2, 6, BceMolecule.h2o),
      twoTwo(2, BceMolecule.n2, 6, BceMolecule.h2o, 4, BceMolecule.nh3, 3, BceMolecule.o2),
      // 4 NH3 + 5 O2 → 4 NO + 6 H2O
      twoTwo(4, BceMolecule.nh3, 5, BceMolecule.o2, 4, BceMolecule.no, 6, BceMolecule.h2o),
      twoTwo(4, BceMolecule.no, 6, BceMolecule.h2o, 4, BceMolecule.nh3, 5, BceMolecule.o2),
      // 4 NH3 + 7 O2 → 4 NO2 + 6 H2O
      twoTwo(4, BceMolecule.nh3, 7, BceMolecule.o2, 4, BceMolecule.no2, 6, BceMolecule.h2o),
      twoTwo(4, BceMolecule.no2, 6, BceMolecule.h2o, 4, BceMolecule.nh3, 7, BceMolecule.o2),
      // 4 NH3 + 6 NO → 5 N2 + 6 H2O
      twoTwo(4, BceMolecule.nh3, 6, BceMolecule.no, 5, BceMolecule.n2, 6, BceMolecule.h2o),
      twoTwo(5, BceMolecule.n2, 6, BceMolecule.h2o, 4, BceMolecule.nh3, 6, BceMolecule.no),
    ];
  }

  /// Exclusion pairs by equation index (Phase 4 will wire into pool selection).
  /// Mirrors EquationPool3 exclusionsMap structure as index sets.
  static const Map<int, List<int>> exclusionIndices = {
    2: [3, 4],
    3: [2, 5],
    4: [5, 2],
    5: [4, 3],
    0: [1],
    1: [0],
    6: [7, 8, 10, 12],
    8: [9, 6, 10, 12],
    10: [11, 6, 8, 12],
    12: [13, 6, 8, 10],
    7: [6, 9, 11, 13],
    9: [8, 7, 11, 13],
    11: [10, 7, 9, 13],
    13: [12, 7, 9, 11],
  };
}
