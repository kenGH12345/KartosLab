import '../model/bce_molecule.dart';
import '../model/equation.dart';
import '../model/equation_term.dart';

/// PhET `EquationPool2` — Game Level 2 (11 equations).
abstract final class GameEquationPool2 {
  static const range = BceCoefficientRanges.game;
  static const sourceCount = 11;

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
          id: 'game.level2.equation${i++}',
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
      twoTwo(2, BceMolecule.c, 2, BceMolecule.h2o, 1, BceMolecule.ch4, 1, BceMolecule.co2),
      twoTwo(1, BceMolecule.ch4, 1, BceMolecule.h2o, 3, BceMolecule.h2, 1, BceMolecule.co),
      twoTwo(1, BceMolecule.ch4, 2, BceMolecule.o2, 1, BceMolecule.co2, 2, BceMolecule.h2o),
      twoTwo(1, BceMolecule.c2h4, 3, BceMolecule.o2, 2, BceMolecule.co2, 2, BceMolecule.h2o),
      twoTwo(1, BceMolecule.c2h6, 1, BceMolecule.cl2, 1, BceMolecule.c2h5Cl, 1, BceMolecule.hCl),
      twoTwo(1, BceMolecule.ch4, 4, BceMolecule.s, 1, BceMolecule.cs2, 2, BceMolecule.h2s),
      twoTwo(1, BceMolecule.cs2, 3, BceMolecule.o2, 1, BceMolecule.co2, 2, BceMolecule.so2),
      twoTwo(1, BceMolecule.so2, 2, BceMolecule.h2, 1, BceMolecule.s, 2, BceMolecule.h2o),
      twoTwo(1, BceMolecule.so2, 3, BceMolecule.h2, 1, BceMolecule.h2s, 2, BceMolecule.h2o),
      twoTwo(2, BceMolecule.f2, 1, BceMolecule.h2o, 1, BceMolecule.of2, 2, BceMolecule.hf),
      twoTwo(1, BceMolecule.of2, 1, BceMolecule.h2o, 1, BceMolecule.o2, 2, BceMolecule.hf),
    ];
  }
}
