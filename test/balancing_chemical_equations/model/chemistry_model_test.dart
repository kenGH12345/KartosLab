import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_chemical_equations/balancing_chemical_equations.dart';

void main() {
  group('BceElement', () {
    test('symbols used by BCE molecules exist', () {
      const needed = ['H', 'C', 'N', 'O', 'P', 'S', 'F', 'Cl'];
      for (final s in needed) {
        expect(BceElement.getBySymbol(s).symbol, s);
      }
    });

    test('identity by symbol', () {
      expect(BceElement.h, BceElement.getBySymbol('H'));
      expect(BceElement.o.isOxygen, isTrue);
      expect(BceElement.c.isCarbon, isTrue);
    });
  });

  group('BceMolecule', () {
    test('H2O element counts', () {
      expect(BceMolecule.h2o.elementCounts[BceElement.h], 2);
      expect(BceMolecule.h2o.elementCounts[BceElement.o], 1);
      expect(BceMolecule.h2o.plainSymbol, 'H2O');
    });

    test('C2H5OH element counts (C2 H6 O1)', () {
      expect(BceMolecule.c2h5Oh.elementCounts[BceElement.c], 2);
      expect(BceMolecule.c2h5Oh.elementCounts[BceElement.h], 6);
      expect(BceMolecule.c2h5Oh.elementCounts[BceElement.o], 1);
    });

    test('catalogue size matches Molecule.ts statics', () {
      expect(BceMolecule.all.length, 38);
    });

    test('isBig when atoms > 5', () {
      expect(BceMolecule.h2.isBig, isFalse);
      expect(BceMolecule.n2o5.isBig, isTrue); // 7 atoms
      expect(BceMolecule.c2h5Oh.isBig, isTrue); // 9 atoms
    });
  });

  group('Coefficient', () {
    test('intro range 0..3', () {
      final term = EquationTerm(
        balancedCoefficient: 2,
        molecule: BceMolecule.h2o,
        coefficientRange: BceCoefficientRanges.intro,
        initialCoefficient: 1,
      );
      expect(term.coefficient, 1);
      term.coefficient = -1;
      expect(term.coefficient, 0);
      term.coefficient = 99;
      expect(term.coefficient, 3);
      term.coefficient = 0;
      expect(term.coefficient, 0);
      term.coefficient = 2;
      expect(term.coefficient, 2);
    });

    test('equations range 0..6 and game 0..7', () {
      expect(BceCoefficientRanges.equations.max, 6);
      expect(BceCoefficientRanges.game.max, 7);
    });

    test('reset restores initial', () {
      final term = EquationTerm(
        balancedCoefficient: 1,
        molecule: BceMolecule.c,
        coefficientRange: BceCoefficientRanges.intro,
        initialCoefficient: 1,
      );
      term.coefficient = 3;
      term.reset();
      expect(term.coefficient, 1);
    });
  });

  group('Equation balance semantics', () {
    late Equation water;

    setUp(() {
      water = Equation.create2Reactants1Product(
        id: 'test.water',
        r1: 2,
        reactant1: BceMolecule.h2,
        r2: 1,
        reactant2: BceMolecule.o2,
        p1: 2,
        product1: BceMolecule.h2o,
        coefficientsRange: BceCoefficientRanges.game,
        initialCoefficient: 0,
      );
    });

    tearDown(() => water.dispose());

    test('2 H2 + O2 → 2 H2O is balanced and simplified', () {
      water.reactants[0].coefficient = 2;
      water.reactants[1].coefficient = 1;
      water.products[0].coefficient = 2;
      expect(water.isBalanced, isTrue);
      expect(water.isSimplified, isTrue);
    });

    test('4 H2 + 2 O2 → 4 H2O is balanced but not simplified', () {
      water.reactants[0].coefficient = 4;
      water.reactants[1].coefficient = 2;
      water.products[0].coefficient = 4;
      expect(water.isBalanced, isTrue);
      expect(water.isSimplified, isFalse);
    });

    test('6 H2 + 3 O2 → 6 H2O is balanced not simplified', () {
      water.reactants[0].coefficient = 6;
      water.reactants[1].coefficient = 3;
      water.products[0].coefficient = 6;
      expect(water.isBalanced, isTrue);
      expect(water.isSimplified, isFalse);
    });

    test('unbalanced coeffs', () {
      water.reactants[0].coefficient = 1;
      water.reactants[1].coefficient = 1;
      water.products[0].coefficient = 1;
      expect(water.isBalanced, isFalse);
      expect(water.isSimplified, isFalse);
    });

    test('all zeros is not balanced', () {
      water.reactants[0].coefficient = 0;
      water.reactants[1].coefficient = 0;
      water.products[0].coefficient = 0;
      expect(water.isBalanced, isFalse);
    });

    test('atom counts for 2 H2 + O2 → 2 H2O', () {
      water.balance();
      final counts = water.getAtomCounts();
      final bySymbol = {for (final c in counts) c.element.symbol: c};
      expect(bySymbol['H']!.reactantsCount, 4);
      expect(bySymbol['H']!.productsCount, 4);
      expect(bySymbol['O']!.reactantsCount, 2);
      expect(bySymbol['O']!.productsCount, 2);
    });

    test('equation.balance() sets simplified', () {
      water.reactants[0].coefficient = 0;
      water.balance();
      expect(water.isBalanced, isTrue);
      expect(water.isSimplified, isTrue);
      expect(water.reactants[0].coefficient, 2);
      expect(water.reactants[1].coefficient, 1);
      expect(water.products[0].coefficient, 2);
    });
  });

  group('Ammonia', () {
    test('1 N2 + 3 H2 → 2 NH3 is balanced and simplified', () {
      final eq = IntroEquations.makeAmmonia(initialCoefficient: 0);
      addTearDown(eq.dispose);
      eq.reactants[0].coefficient = 1;
      eq.reactants[1].coefficient = 3;
      eq.products[0].coefficient = 2;
      expect(eq.isBalanced, isTrue);
      expect(eq.isSimplified, isTrue);
    });

    test('2 N2 + 6 H2 → 4 NH3 non-simplified (needs range ≥6)', () {
      // Source Make Ammonia balanced = 1:3:2. N=2 → 2:6:4.
      // Intro range is 0..3 so this case uses Equations/Game range.
      final eq = Equation.create2Reactants1Product(
        id: 'test.ammonia.wide',
        r1: 1,
        reactant1: BceMolecule.n2,
        r2: 3,
        reactant2: BceMolecule.h2,
        p1: 2,
        product1: BceMolecule.nh3,
        coefficientsRange: BceCoefficientRanges.equations,
        initialCoefficient: 0,
      );
      addTearDown(eq.dispose);
      eq.reactants[0].coefficient = 2;
      eq.reactants[1].coefficient = 6;
      eq.products[0].coefficient = 4;
      expect(eq.isBalanced, isTrue);
      expect(eq.isSimplified, isFalse);
    });

    test('source Intro ammonia simplified is 1 N2 + 3 H2 → 2 NH3 (not 2:3:2)', () {
      final eq = IntroEquations.makeAmmonia(initialCoefficient: 0);
      addTearDown(eq.dispose);
      eq.balance();
      expect(eq.reactants[0].coefficient, 1);
      expect(eq.reactants[1].coefficient, 3);
      expect(eq.products[0].coefficient, 2);
    });
  });

  group('Methane combustion (Intro)', () {
    test('balance() yields simplified', () {
      final eq = IntroEquations.combustMethane(initialCoefficient: 1);
      addTearDown(eq.dispose);
      eq.balance();
      expect(eq.isBalanced, isTrue);
      expect(eq.isSimplified, isTrue);
      expect(eq.reactants[0].coefficient, 1); // CH4
      expect(eq.reactants[1].coefficient, 2); // O2
      expect(eq.products[0].coefficient, 1); // CO2
      expect(eq.products[1].coefficient, 2); // H2O
    });
  });

  group('Dataset integrity', () {
    test('Intro count = 3', () {
      final all = IntroEquations.createAll();
      addTearDown(() {
        for (final e in all) {
          e.dispose();
        }
      });
      expect(all.length, IntroEquations.sourceCount);
      expect(all.map((e) => e.id).toSet().length, all.length);
    });

    test('Equations screen count = 12', () {
      final all = EquationsDatasets.createAll();
      addTearDown(() {
        for (final e in all) {
          e.dispose();
        }
      });
      expect(all.length, EquationsDatasets.sourceCount);
      expect(EquationsDatasets.createSynthesis().length, 4);
      expect(EquationsDatasets.createDecomposition().length, 4);
      expect(EquationsDatasets.createCombustion().length, 4);
    });

    test('Game pools 21 + 11 + 14', () {
      final l1 = GameEquationPool1.createAll();
      final l2 = GameEquationPool2.createAll();
      final l3 = GameEquationPool3.createAll();
      addTearDown(() {
        for (final e in [...l1, ...l2, ...l3]) {
          e.dispose();
        }
      });
      expect(l1.length, 21);
      expect(l2.length, 11);
      expect(l3.length, 14);
    });

    test('every dataset equation balance() → simplified', () {
      final all = [
        ...IntroEquations.createAll(initialCoefficient: 0),
        ...EquationsDatasets.createAll(initialCoefficient: 0),
        ...GameEquationPool1.createAll(initialCoefficient: 0),
        ...GameEquationPool2.createAll(initialCoefficient: 0),
        ...GameEquationPool3.createAll(initialCoefficient: 0),
      ];
      addTearDown(() {
        for (final e in all) {
          e.dispose();
        }
      });
      expect(all.length, BceDatasetCounts.total);
      for (final eq in all) {
        eq.balance();
        expect(eq.isBalanced, isTrue, reason: eq.id);
        expect(eq.isSimplified, isTrue, reason: eq.id);
        // Atom conservation must hold when simplified
        for (final c in eq.getAtomCounts()) {
          expect(c.reactantsCount, c.productsCount,
              reason: '${eq.id} ${c.element.symbol}');
        }
      }
    });

    test('stable unique ids across all equations', () {
      final all = [
        ...IntroEquations.createAll(),
        ...EquationsDatasets.createAll(),
        ...GameEquationPool1.createAll(),
        ...GameEquationPool2.createAll(),
        ...GameEquationPool3.createAll(),
      ];
      addTearDown(() {
        for (final e in all) {
          e.dispose();
        }
      });
      final ids = all.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  group('coefficient × composition foundation', () {
    test('2 × H2O contributes 4 H and 2 O on that side', () {
      final eq = IntroEquations.separateWater(initialCoefficient: 0);
      addTearDown(eq.dispose);
      eq.reactants[0].coefficient = 2; // 2 H2O
      final counts = eq.getAtomCounts();
      final h = counts.firstWhere((c) => c.element == BceElement.h);
      final o = counts.firstWhere((c) => c.element == BceElement.o);
      expect(h.reactantsCount, 4);
      expect(o.reactantsCount, 2);
    });
  });
}
