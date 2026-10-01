import '../model/bce_molecule.dart';
import '../model/equation.dart';
import '../model/equation_term.dart';
import '../model/view_mode.dart';

/// PhET `EquationsModel` — Synthesis / Decomposition / Combustion datasets.
abstract final class EquationsDatasets {
  static const range = BceCoefficientRanges.equations;

  // —— Synthesis (4) ——

  static List<Equation> createSynthesis({int? initialCoefficient}) {
    var i = 0;
    return [
      Equation.create2Reactants1Product(
        id: 'equations.synthesis.equation${i++}',
        r1: 2,
        reactant1: BceMolecule.c,
        r2: 1,
        reactant2: BceMolecule.o2,
        p1: 2,
        product1: BceMolecule.co,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      ),
      Equation.create2Reactants1Product(
        id: 'equations.synthesis.equation${i++}',
        r1: 2,
        reactant1: BceMolecule.n2,
        r2: 5,
        reactant2: BceMolecule.o2,
        p1: 2,
        product1: BceMolecule.n2o5,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      ),
      Equation.create2Reactants1Product(
        id: 'equations.synthesis.equation${i++}',
        r1: 4,
        reactant1: BceMolecule.p,
        r2: 5,
        reactant2: BceMolecule.o2,
        p1: 2,
        product1: BceMolecule.p2o5,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      ),
      Equation.create2Reactants1Product(
        id: 'equations.synthesis.equation${i++}',
        r1: 1,
        reactant1: BceMolecule.c2h2,
        r2: 2,
        reactant2: BceMolecule.h2,
        p1: 1,
        product1: BceMolecule.c2h6,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      ),
    ];
  }

  // —— Decomposition (4) ——

  static List<Equation> createDecomposition({int? initialCoefficient}) {
    var i = 0;
    return [
      Equation.create1Reactant2Products(
        id: 'equations.decomposition.equation${i++}',
        r1: 1,
        reactant1: BceMolecule.ch3Oh,
        p1: 1,
        product1: BceMolecule.co,
        p2: 2,
        product2: BceMolecule.h2,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      ),
      Equation.create1Reactant2Products(
        id: 'equations.decomposition.equation${i++}',
        r1: 2,
        reactant1: BceMolecule.no2,
        p1: 2,
        product1: BceMolecule.no,
        p2: 1,
        product2: BceMolecule.o2,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      ),
      Equation.create1Reactant2Products(
        id: 'equations.decomposition.equation${i++}',
        r1: 2,
        reactant1: BceMolecule.pCl3,
        p1: 2,
        product1: BceMolecule.p,
        p2: 3,
        product2: BceMolecule.cl2,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      ),
      Equation.create1Reactant2Products(
        id: 'equations.decomposition.equation${i++}',
        r1: 2,
        reactant1: BceMolecule.h2o2,
        p1: 2,
        product1: BceMolecule.h2o,
        p2: 1,
        product2: BceMolecule.o2,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      ),
    ];
  }

  // —— Combustion (4) ——

  static List<Equation> createCombustion({int? initialCoefficient}) {
    var i = 0;
    return [
      Equation.create2Reactants2Products(
        id: 'equations.combustion.equation${i++}',
        r1: 1,
        reactant1: BceMolecule.c2h4,
        r2: 3,
        reactant2: BceMolecule.o2,
        p1: 2,
        product1: BceMolecule.co2,
        p2: 2,
        product2: BceMolecule.h2o,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      ),
      Equation.create2Reactants2Products(
        id: 'equations.combustion.equation${i++}',
        r1: 1,
        reactant1: BceMolecule.c2h5Oh,
        r2: 3,
        reactant2: BceMolecule.o2,
        p1: 2,
        product1: BceMolecule.co2,
        p2: 3,
        product2: BceMolecule.h2o,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      ),
      Equation.create2Reactants2Products(
        id: 'equations.combustion.equation${i++}',
        r1: 2,
        reactant1: BceMolecule.ch3Oh,
        r2: 3,
        reactant2: BceMolecule.o2,
        p1: 2,
        product1: BceMolecule.co2,
        p2: 4,
        product2: BceMolecule.h2o,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      ),
      Equation.create2Reactants2Products(
        id: 'equations.combustion.equation${i++}',
        r1: 2,
        reactant1: BceMolecule.c2h2,
        r2: 5,
        reactant2: BceMolecule.o2,
        p1: 4,
        product1: BceMolecule.co2,
        p2: 2,
        product2: BceMolecule.h2o,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      ),
    ];
  }

  static List<Equation> createAll({int? initialCoefficient}) => [
        ...createSynthesis(initialCoefficient: initialCoefficient),
        ...createDecomposition(initialCoefficient: initialCoefficient),
        ...createCombustion(initialCoefficient: initialCoefficient),
      ];

  static List<Equation> forType(ReactionType type, {int? initialCoefficient}) {
    switch (type) {
      case ReactionType.synthesis:
        return createSynthesis(initialCoefficient: initialCoefficient);
      case ReactionType.decomposition:
        return createDecomposition(initialCoefficient: initialCoefficient);
      case ReactionType.combustion:
        return createCombustion(initialCoefficient: initialCoefficient);
    }
  }

  static const synthesisCount = 4;
  static const decompositionCount = 4;
  static const combustionCount = 4;
  static const sourceCount = synthesisCount + decompositionCount + combustionCount;
}
