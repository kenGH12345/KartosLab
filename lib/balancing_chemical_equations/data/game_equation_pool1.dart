import '../model/bce_molecule.dart';
import '../model/equation.dart';
import '../model/equation_term.dart';

/// PhET `EquationPool1` — Game Level 1 challenge equations (21).
abstract final class GameEquationPool1 {
  static const range = BceCoefficientRanges.game;
  static const sourceCount = 21;
  static const firstBigMolecule = false;

  static List<Equation> createAll({int? initialCoefficient}) {
    var i = 0;
    Equation oneTwo(
      int r1,
      BceMolecule a,
      int p1,
      BceMolecule b,
      int p2,
      BceMolecule c,
    ) =>
        Equation.create1Reactant2Products(
          id: 'game.level1.equation${i++}',
          r1: r1,
          reactant1: a,
          p1: p1,
          product1: b,
          p2: p2,
          product2: c,
          coefficientsRange: range,
          initialCoefficient: initialCoefficient,
        );

    Equation twoOne(
      int r1,
      BceMolecule a,
      int r2,
      BceMolecule b,
      int p1,
      BceMolecule c,
    ) =>
        Equation.create2Reactants1Product(
          id: 'game.level1.equation${i++}',
          r1: r1,
          reactant1: a,
          r2: r2,
          reactant2: b,
          p1: p1,
          product1: c,
          coefficientsRange: range,
          initialCoefficient: initialCoefficient,
        );

    return [
      oneTwo(1, BceMolecule.pCl5, 1, BceMolecule.pCl3, 1, BceMolecule.cl2),
      oneTwo(1, BceMolecule.ch3Oh, 1, BceMolecule.co, 2, BceMolecule.h2),
      twoOne(2, BceMolecule.h2, 1, BceMolecule.o2, 2, BceMolecule.h2o),
      twoOne(1, BceMolecule.h2, 1, BceMolecule.f2, 2, BceMolecule.hf),
      oneTwo(2, BceMolecule.hCl, 1, BceMolecule.h2, 1, BceMolecule.cl2),
      twoOne(1, BceMolecule.ch2o, 1, BceMolecule.h2, 1, BceMolecule.ch3Oh),
      oneTwo(1, BceMolecule.c2h6, 1, BceMolecule.c2h4, 1, BceMolecule.h2),
      twoOne(1, BceMolecule.c2h2, 2, BceMolecule.h2, 1, BceMolecule.c2h6),
      twoOne(1, BceMolecule.c, 1, BceMolecule.o2, 1, BceMolecule.co2),
      twoOne(2, BceMolecule.c, 1, BceMolecule.o2, 2, BceMolecule.co),
      oneTwo(2, BceMolecule.co2, 2, BceMolecule.co, 1, BceMolecule.o2),
      oneTwo(2, BceMolecule.co, 1, BceMolecule.c, 1, BceMolecule.co2),
      twoOne(1, BceMolecule.c, 2, BceMolecule.s, 1, BceMolecule.cs2),
      oneTwo(2, BceMolecule.nh3, 1, BceMolecule.n2, 3, BceMolecule.h2),
      oneTwo(2, BceMolecule.no, 1, BceMolecule.n2, 1, BceMolecule.o2),
      oneTwo(2, BceMolecule.no2, 2, BceMolecule.no, 1, BceMolecule.o2),
      twoOne(2, BceMolecule.n2, 1, BceMolecule.o2, 2, BceMolecule.n2o),
      twoOne(1, BceMolecule.p4, 6, BceMolecule.h2, 4, BceMolecule.ph3),
      twoOne(1, BceMolecule.p4, 6, BceMolecule.f2, 4, BceMolecule.pf3),
      oneTwo(4, BceMolecule.pCl3, 1, BceMolecule.p4, 6, BceMolecule.cl2),
      oneTwo(2, BceMolecule.so3, 2, BceMolecule.so2, 1, BceMolecule.o2),
    ];
  }
}
