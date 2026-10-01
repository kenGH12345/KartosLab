import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_constants.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_strings.dart';
import 'package:kratos/reactants_products_and_leftovers/view/sandwiches_controller.dart';
import 'package:kratos/reactants_products_and_leftovers/view/sandwiches_screen.dart';
import 'package:kratos/reactants_products_and_leftovers/view/widgets/quantities_node.dart';
import 'package:kratos/reactants_products_and_leftovers/view/widgets/sandwich_icon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SandwichesController', () {
    test('initial recipe is Cheese', () {
      final c = SandwichesController();
      expect(c.selected.name, RpalStrings.cheese);
      expect(c.beforeExpanded, isTrue);
      expect(c.afterExpanded, isTrue);
    });

    test('quantity increment updates products and leftovers', () {
      final c = SandwichesController();
      final recipe = c.selected;
      c.setReactantQuantity(recipe.bread, 6);
      c.setReactantQuantity(recipe.cheese, 4);

      expect(recipe.numberOfReactions, 3);
      expect(recipe.sandwich.quantity, 3);
      expect(recipe.leftovers[0].quantity, 0);
      expect(recipe.leftovers[1].quantity, 1);
    });

    test('quantity clamped to 0–8', () {
      final c = SandwichesController();
      c.setReactantQuantity(c.selected.bread, -1);
      expect(c.selected.bread.quantity, 0);
      c.setReactantQuantity(c.selected.bread, 99);
      expect(c.selected.bread.quantity, RpalConstants.quantityMax);
    });

    test('Meat and Cheese selection switches recipe', () {
      final c = SandwichesController();
      c.selectRecipe(c.recipes[1]);
      expect(c.selected.name, RpalStrings.meatAndCheese);
      expect(c.selected.reactants.length, 3);
    });

    test('Custom coefficient 0–3 and No Reaction', () {
      final c = SandwichesController();
      c.selectRecipe(c.recipes[2]);
      expect(c.selected.isReaction(), isFalse);
      expect(c.selected.numberOfReactions, 0);

      c.setCoefficient(c.selected.bread, 2);
      c.setCoefficient(c.selected.cheese, 1);
      expect(c.selected.isReaction(), isTrue);

      c.setCoefficient(c.selected.bread, 99);
      expect(c.selected.bread.coefficient, RpalConstants.sandwichCoefficientMax);
    });

    test('reset restores defaults', () {
      final c = SandwichesController();
      c.selectRecipe(c.recipes[1]);
      c.setReactantQuantity(c.selected.bread, 5);
      c.toggleBeforeExpanded();
      c.reset();

      expect(c.selected.name, RpalStrings.cheese);
      expect(c.selected.bread.quantity, 0);
      expect(c.beforeExpanded, isTrue);
      expect(c.afterExpanded, isTrue);
    });

    test('createXOffsets for 2 and 3 substances', () {
      final two = QuantitiesNode.createXOffsets(2, 310);
      expect(two.length, 2);
      expect(two[0], closeTo(0.15 * 310 + (310 - 2 * 0.15 * 310) / 4, 0.01));

      final three = QuantitiesNode.createXOffsets(3, 310);
      expect(three.length, 3);
      expect(three[0], closeTo(310 / 6, 0.01));
    });
  });

  group('SandwichIcon stacking', () {
    test('cheese sandwich layers start with bread', () {
      const icon = SandwichIcon(breadCount: 2, meatCount: 0, cheeseCount: 1);
      final layers = icon.buildLayerAssets();
      expect(layers.first, contains('bread'));
      expect(layers.length, 3); // bread, cheese, bread
    });
  });

  group('SandwichesScreen widget', () {
    testWidgets('launches and shows Cheese', (tester) async {
      final controller = SandwichesController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 600,
              child: SandwichesScreen(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(RpalStrings.cheese), findsWidgets);
      expect(find.text(RpalStrings.beforeSandwich), findsOneWidget);
      expect(find.text(RpalStrings.afterSandwich), findsOneWidget);
      expect(find.text(RpalStrings.reactants), findsOneWidget);
      expect(find.text(RpalStrings.products), findsOneWidget);
      expect(find.text(RpalStrings.leftovers), findsOneWidget);
    });

    testWidgets('quantity change updates product display', (tester) async {
      final controller = SandwichesController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 600,
              child: SandwichesScreen(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.setReactantQuantity(controller.selected.bread, 4);
      controller.setReactantQuantity(controller.selected.cheese, 2);
      await tester.pump();

      expect(controller.selected.sandwich.quantity, 2);
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('recipe selector switches to Custom and shows No Reaction',
        (tester) async {
      final controller = SandwichesController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 600,
              child: SandwichesScreen(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(RpalStrings.custom));
      await tester.pumpAndSettle();

      expect(controller.selected.name, RpalStrings.custom);
      expect(find.textContaining('Reaction'), findsWidgets);
      expect(controller.selected.isReaction(), isFalse);
    });

    testWidgets('accordion collapse hides stack content', (tester) async {
      final controller = SandwichesController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 600,
              child: SandwichesScreen(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.beforeExpanded, isTrue);
      controller.toggleBeforeExpanded();
      await tester.pumpAndSettle();
      expect(controller.beforeExpanded, isFalse);

      controller.toggleBeforeExpanded();
      await tester.pumpAndSettle();
      expect(controller.beforeExpanded, isTrue);
    });

    testWidgets('reset restores recipe and quantities', (tester) async {
      final controller = SandwichesController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 600,
              child: SandwichesScreen(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.selectRecipe(controller.recipes[1]);
      controller.setReactantQuantity(controller.selected.bread, 7);
      controller.reset();
      await tester.pump();

      expect(controller.selected.name, RpalStrings.cheese);
      expect(controller.selected.bread.quantity, 0);
    });
  });
}
