import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/model/reaction_factory.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_constants.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_strings.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_symbols.dart';
import 'package:kratos/reactants_products_and_leftovers/view/molecules_controller.dart';
import 'package:kratos/reactants_products_and_leftovers/view/molecules_screen.dart';
import 'package:kratos/reactants_products_and_leftovers/view/widgets/formula_text.dart';
import 'package:kratos/reactants_products_and_leftovers/view/widgets/molecule_icon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Molecules Final QA — reactions', () {
    test('source reactions Make Water / Ammonia / Combust Methane', () {
      final c = MoleculesController();
      expect(c.reactions.length, 3);
      expect(c.reactions.map((r) => r.name).toList(), [
        RpalStrings.makeWater,
        RpalStrings.makeAmmonia,
        RpalStrings.combustMethane,
      ]);
      expect(c.selected.name, RpalStrings.makeWater);
    });
  });

  group('Molecules Final QA — quantity boundary', () {
    for (final reactionIndex in [0, 1, 2]) {
      test('reaction[$reactionIndex] quantity 0/1/normal/8', () {
        final c = MoleculesController();
        c.selectReaction(c.reactions[reactionIndex]);
        for (final reactant in c.selected.reactants) {
          for (final q in [0, 1, 4, 8]) {
            c.setReactantQuantity(reactant, q);
            expect(reactant.quantity, q);
          }
          c.setReactantQuantity(reactant, -1);
          expect(reactant.quantity, RpalConstants.quantityMin);
          c.setReactantQuantity(reactant, 100);
          expect(reactant.quantity, RpalConstants.quantityMax);
        }
      });
    }
  });

  group('Molecules Final QA — reaction correctness from Model', () {
    test('Make Water stoichiometry', () {
      final c = MoleculesController();
      final r = c.selected;
      expect(r.reactants[0].symbol, RpalSymbols.h2);
      expect(r.reactants[1].symbol, RpalSymbols.o2);
      expect(r.products[0].symbol, RpalSymbols.h2o);

      c.setReactantQuantity(r.reactants[0], 6);
      c.setReactantQuantity(r.reactants[1], 4);
      expect(r.numberOfReactions, 3);
      expect(r.products[0].quantity, 6);
      expect(r.leftovers[0].quantity, 0);
      expect(r.leftovers[1].quantity, 1);
    });

    test('Make Ammonia stoichiometry', () {
      final c = MoleculesController();
      c.selectReaction(c.reactions[1]);
      final r = c.selected;
      c.setReactantQuantity(r.reactants[0], 2); // N2
      c.setReactantQuantity(r.reactants[1], 3); // H2
      expect(r.numberOfReactions, 1);
      expect(r.products[0].quantity, 2);
      expect(r.leftovers[0].quantity, 1);
      expect(r.leftovers[1].quantity, 0);
    });

    test('Combust Methane stoichiometry', () {
      final c = MoleculesController();
      c.selectReaction(c.reactions[2]);
      final r = c.selected;
      c.setReactantQuantity(r.reactants[0], 2); // CH4
      c.setReactantQuantity(r.reactants[1], 5); // O2
      expect(r.numberOfReactions, 2);
      expect(r.products[0].quantity, 2); // CO2
      expect(r.products[1].quantity, 4); // H2O
      expect(r.leftovers[0].quantity, 0);
      expect(r.leftovers[1].quantity, 1);
    });

    test('zero reactants → zero products, no ghost leftover math', () {
      final c = MoleculesController();
      final r = c.selected;
      c.setReactantQuantity(r.reactants[0], 0);
      c.setReactantQuantity(r.reactants[1], 0);
      expect(r.numberOfReactions, 0);
      expect(r.products.every((p) => p.quantity == 0), isTrue);
      expect(r.leftovers.every((l) => l.quantity == 0), isTrue);
    });
  });

  group('Molecules Final QA — formula / molecule visuals', () {
    testWidgets('FormulaText for H2O NH3 CH4', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FormulaText(symbolHtml: RpalSymbols.h2o, color: Colors.black),
                FormulaText(symbolHtml: RpalSymbols.nh3, color: Colors.black),
                FormulaText(symbolHtml: RpalSymbols.ch4, color: Colors.black),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(FormulaText), findsNWidgets(3));
      expect(find.text('2'), findsWidgets); // subscripts rendered
      expect(find.text('3'), findsWidgets);
      expect(find.text('4'), findsWidgets);
    });

    test('MoleculeIcon covers Molecules screen set', () {
      for (final id in RpalMoleculeId.values) {
        expect(MoleculeIcon.layoutSize(id).width, greaterThan(0));
        expect(MoleculeIcon.layoutSize(id).height, greaterThan(0));
      }
      expect(RpalMoleculeIdX.fromIconId('H2O'), RpalMoleculeId.h2o);
      expect(RpalMoleculeIdX.fromIconId('NH3'), RpalMoleculeId.nh3);
      expect(RpalMoleculeIdX.fromIconId('CH4'), RpalMoleculeId.ch4);
      expect(RpalMoleculeIdX.fromIconId('SO2'), RpalMoleculeId.so2);
      expect(RpalMoleculeIdX.fromIconId('S'), RpalMoleculeId.s);
      expect(RpalMoleculeIdX.fromIconId('C2H4'), RpalMoleculeId.c2h4);
    });

    test('every ReactionFactory iconId resolves to MoleculeIcon', () {
      for (final pool in ReactionFactory.pools) {
        for (final create in pool) {
          final reaction = create();
          for (final s in [
            ...reaction.reactants,
            ...reaction.products,
            ...reaction.leftovers,
          ]) {
            final id = RpalMoleculeIdX.fromIconId(s.iconId);
            expect(
              id,
              isNotNull,
              reason:
                  'missing geometry for iconId=${s.iconId} symbol=${s.symbol}',
            );
          }
        }
      }
    });

    testWidgets('MoleculesScreen shows water equation coefficients',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MoleculesScreen())),
      );
      await tester.pumpAndSettle();
      expect(find.text(RpalStrings.makeWater), findsOneWidget);
      expect(find.text('2'), findsWidgets); // H2 coeff
    });
  });

  group('Molecules Final QA — accordion / reset', () {
    test('accordion does not mutate reaction model', () {
      final c = MoleculesController();
      c.setReactantQuantity(c.selected.reactants[0], 5);
      c.toggleBeforeExpanded();
      c.toggleAfterExpanded();
      expect(c.selected.reactants[0].quantity, 5);
      expect(c.beforeExpanded, isFalse);
      expect(c.afterExpanded, isFalse);
    });

    test('reset restores reaction, quantities, accordion', () {
      final c = MoleculesController();
      c.selectReaction(c.reactions[2]);
      c.setReactantQuantity(c.selected.reactants[0], 7);
      c.setReactantQuantity(c.selected.reactants[1], 8);
      c.toggleBeforeExpanded();

      c.reset();

      expect(c.selected.name, RpalStrings.makeWater);
      expect(c.beforeExpanded, isTrue);
      expect(c.afterExpanded, isTrue);
      for (final reaction in c.reactions) {
        for (final reactant in reaction.reactants) {
          expect(reactant.quantity, 0);
        }
      }
    });
  });
}
