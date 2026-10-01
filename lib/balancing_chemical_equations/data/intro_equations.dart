import '../model/bce_molecule.dart';
import '../model/equation.dart';
import '../model/equation_term.dart';

/// PhET `IntroModel.choices` — three fixed equations.
abstract final class IntroEquations {
  static const range = BceCoefficientRanges.intro;

  /// Make Ammonia: N2 + 3 H2 → 2 NH3
  static Equation makeAmmonia({int? initialCoefficient}) =>
      Equation.create2Reactants1Product(
        id: 'intro.makeAmmonia',
        r1: 1,
        reactant1: BceMolecule.n2,
        r2: 3,
        reactant2: BceMolecule.h2,
        p1: 2,
        product1: BceMolecule.nh3,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      );

  /// Separate Water: 2 H2O → 2 H2 + O2
  static Equation separateWater({int? initialCoefficient}) =>
      Equation.create1Reactant2Products(
        id: 'intro.separateWater',
        r1: 2,
        reactant1: BceMolecule.h2o,
        p1: 2,
        product1: BceMolecule.h2,
        p2: 1,
        product2: BceMolecule.o2,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      );

  /// Combust Methane: CH4 + 2 O2 → CO2 + 2 H2O
  static Equation combustMethane({int? initialCoefficient}) =>
      Equation.create2Reactants2Products(
        id: 'intro.combustMethane',
        r1: 1,
        reactant1: BceMolecule.ch4,
        r2: 2,
        reactant2: BceMolecule.o2,
        p1: 1,
        product1: BceMolecule.co2,
        p2: 2,
        product2: BceMolecule.h2o,
        coefficientsRange: range,
        initialCoefficient: initialCoefficient,
      );

  static List<Equation> createAll({int? initialCoefficient}) => [
        makeAmmonia(initialCoefficient: initialCoefficient),
        separateWater(initialCoefficient: initialCoefficient),
        combustMethane(initialCoefficient: initialCoefficient),
      ];

  static const sourceCount = 3;
}
