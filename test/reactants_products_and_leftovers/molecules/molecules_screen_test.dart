import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_constants.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_strings.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_symbols.dart';
import 'package:kratos/reactants_products_and_leftovers/view/molecules_controller.dart';
import 'package:kratos/reactants_products_and_leftovers/view/molecules_screen.dart';
import 'package:kratos/reactants_products_and_leftovers/view/widgets/formula_text.dart';
import 'package:kratos/reactants_products_and_leftovers/view/widgets/molecule_icon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MoleculesController', () {
    test('initial reaction is Make Water', () {
      final c = MoleculesController();
      expect(c.selected.name, RpalStrings.makeWater);
      expect(c.beforeExpanded, isTrue);
      expect(c.afterExpanded, isTrue);
    });

    test('Make Water H2=6 O2=4 products and leftovers', () {
      final c = MoleculesController();
      final r = c.selected;
      c.setReactantQuantity(r.reactants[0], 6);
      c.setReactantQuantity(r.reactants[1], 4);

      expect(r.numberOfReactions, 3);
      expect(r.products[0].quantity, 6);
      expect(r.leftovers[0].quantity, 0);
      expect(r.leftovers[1].quantity, 1);
      expect(r.limitingReactantIndices, [0]);
    });

    test('Make Water H2=4 O2=6 limiting H2', () {
      final c = MoleculesController();
      final r = c.selected;
      c.setReactantQuantity(r.reactants[0], 4);
      c.setReactantQuantity(r.reactants[1], 6);

      expect(r.numberOfReactions, 2);
      expect(r.products[0].quantity, 4);
      expect(r.leftovers[0].quantity, 0);
      expect(r.leftovers[1].quantity, 4);
    });

    test('Make Ammonia limiting and products', () {
      final c = MoleculesController();
      c.selectReaction(c.reactions[1]);
      expect(c.selected.name, RpalStrings.makeAmmonia);

      final r = c.selected;
      // N2 + 3 H2 → 2 NH3 ; N2=2 H2=3 → 1 reaction, leftover N2=1 H2=0, NH3=2
      c.setReactantQuantity(r.reactants[0], 2);
      c.setReactantQuantity(r.reactants[1], 3);

      expect(r.numberOfReactions, 1);
      expect(r.products[0].quantity, 2);
      expect(r.leftovers[0].quantity, 1);
      expect(r.leftovers[1].quantity, 0);
      expect(r.limitingReactantIndices, [1]);
    });

    test('Combust Methane products', () {
      final c = MoleculesController();
      c.selectReaction(c.reactions[2]);
      expect(c.selected.name, RpalStrings.combustMethane);

      final r = c.selected;
      c.setReactantQuantity(r.reactants[0], 1);
      c.setReactantQuantity(r.reactants[1], 3);

      expect(r.numberOfReactions, 1);
      expect(r.products[0].quantity, 1); // CO2
      expect(r.products[1].quantity, 2); // H2O
      expect(r.leftovers[0].quantity, 0);
      expect(r.leftovers[1].quantity, 1);
    });

    test('quantity clamped 0–8', () {
      final c = MoleculesController();
      c.setReactantQuantity(c.selected.reactants[0], -3);
      expect(c.selected.reactants[0].quantity, 0);
      c.setReactantQuantity(c.selected.reactants[0], 99);
      expect(c.selected.reactants[0].quantity, RpalConstants.quantityMax);
    });

    test('reaction switch isolates quantities', () {
      final c = MoleculesController();
      c.setReactantQuantity(c.selected.reactants[0], 5);
      c.selectReaction(c.reactions[1]);
      expect(c.selected.reactants[0].quantity, 0);
      expect(c.reactions[0].reactants[0].quantity, 5);
    });

    test('zero reaction', () {
      final c = MoleculesController();
      expect(c.selected.numberOfReactions, 0);
      expect(c.selected.products.every((p) => p.quantity == 0), isTrue);
    });

    test('reset restores Make Water and zero quantities', () {
      final c = MoleculesController();
      c.selectReaction(c.reactions[2]);
      c.setReactantQuantity(c.selected.reactants[0], 4);
      c.toggleBeforeExpanded();
      c.reset();

      expect(c.selected.name, RpalStrings.makeWater);
      expect(c.selected.reactants.every((s) => s.quantity == 0), isTrue);
      expect(c.beforeExpanded, isTrue);
    });
  });

  group('FormulaText', () {
    testWidgets('renders H2O with subscript digits', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormulaText(symbolHtml: RpalSymbols.h2o, color: Colors.black),
          ),
        ),
      );
      expect(find.textContaining('H'), findsWidgets);
      expect(find.text('2'), findsOneWidget);
      expect(find.textContaining('O'), findsWidgets);
    });
  });

  group('MoleculeIcon', () {
    test('all Molecules-screen ids have positive layout size', () {
      for (final id in RpalMoleculeId.values) {
        final size = MoleculeIcon.layoutSize(id);
        expect(size.width, greaterThan(0), reason: '$id');
        expect(size.height, greaterThan(0), reason: '$id');
      }
    });
  });

  group('MoleculesScreen widget', () {
    Future<void> pumpScreen(
      WidgetTester tester,
      MoleculesController controller,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 600,
              child: MoleculesScreen(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('launches Make Water', (tester) async {
      final c = MoleculesController();
      await pumpScreen(tester, c);

      expect(find.text(RpalStrings.makeWater), findsWidgets);
      expect(find.text(RpalStrings.beforeReaction), findsOneWidget);
      expect(find.text(RpalStrings.afterReaction), findsOneWidget);
      expect(find.text(RpalStrings.reactants), findsOneWidget);
      expect(find.text(RpalStrings.products), findsOneWidget);
      expect(find.text(RpalStrings.leftovers), findsOneWidget);
    });

    testWidgets('quantity change updates product count in model and UI',
        (tester) async {
      final c = MoleculesController();
      await pumpScreen(tester, c);

      c.setReactantQuantity(c.selected.reactants[0], 4);
      c.setReactantQuantity(c.selected.reactants[1], 2);
      await tester.pump();

      expect(c.selected.products[0].quantity, 4);
      expect(find.text('4'), findsWidgets);
    });

    testWidgets('switches to Make Ammonia and Combust Methane', (tester) async {
      final c = MoleculesController();
      await pumpScreen(tester, c);

      await tester.tap(find.text(RpalStrings.makeAmmonia));
      await tester.pumpAndSettle();
      expect(c.selected.name, RpalStrings.makeAmmonia);

      await tester.tap(find.text(RpalStrings.combustMethane));
      await tester.pumpAndSettle();
      expect(c.selected.name, RpalStrings.combustMethane);
    });

    testWidgets('reset restores defaults', (tester) async {
      final c = MoleculesController();
      await pumpScreen(tester, c);

      c.selectReaction(c.reactions[1]);
      c.setReactantQuantity(c.selected.reactants[0], 3);
      c.reset();
      await tester.pump();

      expect(c.selected.name, RpalStrings.makeWater);
      expect(c.selected.reactants[0].quantity, 0);
    });
  });
}
