import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_constants.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_strings.dart';
import 'package:kratos/reactants_products_and_leftovers/view/sandwiches_controller.dart';

void main() {
  group('Sandwiches Final QA — recipes', () {
    test('source recipes Cheese → Meat and Cheese → Custom', () {
      final c = SandwichesController();
      expect(c.recipes.map((r) => r.name).toList(), [
        RpalStrings.cheese,
        RpalStrings.meatAndCheese,
        RpalStrings.custom,
      ]);
      expect(c.selected.name, RpalStrings.cheese);
      expect(c.recipes[0].coefficientsMutable, isFalse);
      expect(c.recipes[1].coefficientsMutable, isFalse);
      expect(c.recipes[2].coefficientsMutable, isTrue);
    });

    test('recipe selection cycles without mutating quantities of others', () {
      final c = SandwichesController();
      final cheese = c.recipes[0];
      cheese.bread.quantity = 5;
      c.selectRecipe(c.recipes[1]);
      expect(c.selected.name, RpalStrings.meatAndCheese);
      expect(cheese.bread.quantity, 5); // other recipe state retained until reset
      c.selectRecipe(c.recipes[2]);
      expect(c.selected.coefficientsMutable, isTrue);
    });
  });

  group('Sandwiches Final QA — quantity boundary', () {
    test('Cheese reactants accept 0,1,normal,8; clamp out of range', () {
      final c = SandwichesController();
      final bread = c.selected.bread;
      final cheese = c.selected.cheese;

      for (final q in [0, 1, 4, 8]) {
        c.setReactantQuantity(bread, q);
        expect(bread.quantity, q);
        c.setReactantQuantity(cheese, q);
        expect(cheese.quantity, q);
      }

      c.setReactantQuantity(bread, -3);
      expect(bread.quantity, RpalConstants.quantityMin);
      c.setReactantQuantity(bread, 99);
      expect(bread.quantity, RpalConstants.quantityMax);
    });

    test('Meat and Cheese all three ingredients boundary', () {
      final c = SandwichesController();
      c.selectRecipe(c.recipes[1]);
      for (final s in c.selected.reactants) {
        c.setReactantQuantity(s, 0);
        expect(s.quantity, 0);
        c.setReactantQuantity(s, 8);
        expect(s.quantity, 8);
      }
    });
  });

  group('Sandwiches Final QA — limiting reactant', () {
    test('Cheese: bread limiting vs cheese limiting', () {
      final c = SandwichesController();
      final r = c.selected;
      // 2 bread + 1 cheese → sandwich
      c.setReactantQuantity(r.bread, 4);
      c.setReactantQuantity(r.cheese, 5);
      expect(r.numberOfReactions, 2);
      expect(r.sandwich.quantity, 2);
      expect(r.leftovers[0].quantity, 0); // bread exhausted
      expect(r.leftovers[1].quantity, 3);
      expect(r.limitingReactantIndices, [0]);

      c.setReactantQuantity(r.bread, 6);
      c.setReactantQuantity(r.cheese, 1);
      expect(r.numberOfReactions, 1);
      expect(r.sandwich.quantity, 1);
      expect(r.leftovers[0].quantity, 4);
      expect(r.leftovers[1].quantity, 0);
      expect(r.limitingReactantIndices, [1]);
    });

    test('both exhausted and one reactant zero', () {
      final c = SandwichesController();
      final r = c.selected;
      c.setReactantQuantity(r.bread, 4);
      c.setReactantQuantity(r.cheese, 2);
      expect(r.numberOfReactions, 2);
      expect(r.leftovers.every((l) => l.quantity == 0), isTrue);

      c.setReactantQuantity(r.bread, 0);
      c.setReactantQuantity(r.cheese, 8);
      expect(r.numberOfReactions, 0);
      expect(r.sandwich.quantity, 0);
      expect(r.leftovers[0].quantity, 0);
      expect(r.leftovers[1].quantity, 8);
    });
  });

  group('Sandwiches Final QA — Custom coefficients', () {
    test('coefficient 0–3 and invalid Custom isReaction false', () {
      final c = SandwichesController();
      c.selectRecipe(c.recipes[2]);
      final custom = c.selected;
      expect(custom.isReaction(), isFalse);
      expect(custom.numberOfReactions, 0);

      for (final coef in [0, 1, 2, 3]) {
        c.setCoefficient(custom.bread, coef);
        expect(custom.bread.coefficient, coef);
      }
      c.setCoefficient(custom.bread, 9);
      expect(custom.bread.coefficient, RpalConstants.sandwichCoefficientMax);

      // still invalid: only bread=3, meat=0, cheese=0 → greaterThanZero=1, greaterThanOne=1 → isReaction true!
      // Source: isReaction if greaterThanZero > 1 OR greaterThanOne > 0
      expect(custom.isReaction(), isTrue);

      // all zero → invalid
      c.setCoefficient(custom.bread, 0);
      c.setCoefficient(custom.meat, 0);
      c.setCoefficient(custom.cheese, 0);
      expect(custom.isReaction(), isFalse);
      expect(custom.numberOfReactions, 0);
      expect(custom.hasValidSandwich, isFalse);

      // single ingredient coef=1 → greaterThanZero=1, greaterThanOne=0 → NOT a reaction
      c.setCoefficient(custom.bread, 1);
      expect(custom.isReaction(), isFalse);
      expect(custom.numberOfReactions, 0);

      // bread=2 meat=1 → valid
      c.setCoefficient(custom.bread, 2);
      c.setCoefficient(custom.meat, 1);
      expect(custom.isReaction(), isTrue);
      c.setReactantQuantity(custom.bread, 4);
      c.setReactantQuantity(custom.meat, 2);
      expect(custom.numberOfReactions, 2);
      expect(custom.sandwich.quantity, 2);
    });
  });

  group('Sandwiches Final QA — accordion / reset', () {
    test('accordion toggles do not change model quantities', () {
      final c = SandwichesController();
      c.setReactantQuantity(c.selected.bread, 7);
      final q = c.selected.bread.quantity;
      c.toggleBeforeExpanded();
      c.toggleAfterExpanded();
      expect(c.beforeExpanded, isFalse);
      expect(c.afterExpanded, isFalse);
      expect(c.selected.bread.quantity, q);
      expect(c.selected.name, RpalStrings.cheese);
    });

    test('reset restores recipe, quantities, accordion', () {
      final c = SandwichesController();
      c.selectRecipe(c.recipes[2]);
      c.setCoefficient(c.selected.bread, 2);
      c.setReactantQuantity(c.selected.bread, 5);
      c.toggleBeforeExpanded();
      c.toggleAfterExpanded();

      c.reset();

      expect(c.selected.name, RpalStrings.cheese);
      expect(c.beforeExpanded, isTrue);
      expect(c.afterExpanded, isTrue);
      expect(c.recipes[0].bread.quantity, 0);
      expect(c.recipes[0].cheese.quantity, 0);
      expect(c.recipes[2].bread.coefficient, 0);
      expect(c.recipes[2].meat.coefficient, 0);
      expect(c.recipes[2].cheese.coefficient, 0);
    });
  });
}
