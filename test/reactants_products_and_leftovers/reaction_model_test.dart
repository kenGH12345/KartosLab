import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/model/box_type.dart';
import 'package:kratos/reactants_products_and_leftovers/model/game_guess.dart';
import 'package:kratos/reactants_products_and_leftovers/model/molecules_model.dart';
import 'package:kratos/reactants_products_and_leftovers/model/reaction_factory.dart';
import 'package:kratos/reactants_products_and_leftovers/model/sandwich_recipe.dart';
import 'package:kratos/reactants_products_and_leftovers/model/sandwiches_model.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_symbols.dart';

void main() {
  group('Reaction definition', () {
    test('makeWater has source coefficients', () {
      final reaction = ReactionFactory.makeWater();
      expect(reaction.reactants[0].coefficient, 2);
      expect(reaction.reactants[0].symbol, RpalSymbols.h2);
      expect(reaction.reactants[1].coefficient, 1);
      expect(reaction.products[0].coefficient, 2);
      expect(reaction.leftovers.length, reaction.reactants.length);
    });

    test('cheese sandwich recipe', () {
      final recipe = SandwichRecipe(
        breadCount: 2,
        meatCount: 0,
        cheeseCount: 1,
      );
      expect(recipe.reactants.length, 2);
      expect(recipe.reactants[0].symbol, RpalSymbols.bread);
      expect(recipe.reactants[1].symbol, RpalSymbols.cheese);
      expect(recipe.products.single.symbol, RpalSymbols.sandwich);
    });
  });

  group('Product and leftover calculation', () {
    test('make water H2=6 O2=4', () {
      final reaction = ReactionFactory.makeWater();
      reaction.reactants[0].quantity = 6;
      reaction.reactants[1].quantity = 4;

      expect(reaction.numberOfReactions, 3);
      expect(reaction.products[0].quantity, 6);
      expect(reaction.leftovers[0].quantity, 0);
      expect(reaction.leftovers[1].quantity, 1);
    });

    test('make water H2=4 O2=6', () {
      final reaction = ReactionFactory.makeWater();
      reaction.reactants[0].quantity = 4;
      reaction.reactants[1].quantity = 6;

      expect(reaction.numberOfReactions, 2);
      expect(reaction.products[0].quantity, 4);
      expect(reaction.leftovers[0].quantity, 0);
      expect(reaction.leftovers[1].quantity, 4);
    });

    test('cheese sandwich bread=6 cheese=4', () {
      final recipe = SandwichRecipe(breadCount: 2, meatCount: 0, cheeseCount: 1);
      recipe.bread.quantity = 6;
      recipe.cheese.quantity = 4;

      expect(recipe.numberOfReactions, 3);
      expect(recipe.sandwich.quantity, 3);
      expect(recipe.leftovers[0].quantity, 0);
      expect(recipe.leftovers[1].quantity, 1);
    });

    test('combust methane CH4=1 O2=3', () {
      final reaction = ReactionFactory.combustMethane();
      reaction.reactants[0].quantity = 1;
      reaction.reactants[1].quantity = 3;

      expect(reaction.numberOfReactions, 1);
      expect(reaction.products[0].quantity, 1);
      expect(reaction.products[1].quantity, 2);
      expect(reaction.leftovers[0].quantity, 0);
      expect(reaction.leftovers[1].quantity, 1);
    });
  });

  group('Limiting reactant', () {
    test('H2 limits when H2=6 O2=4 (min floor = 3)', () {
      final reaction = ReactionFactory.makeWater();
      reaction.reactants[0].quantity = 6;
      reaction.reactants[1].quantity = 4;

      expect(reaction.numberOfReactions, 3);
      expect(reaction.limitingReactantIndices, [0]);
    });

    test('H2 limits when H2=4 O2=6', () {
      final reaction = ReactionFactory.makeWater();
      reaction.reactants[0].quantity = 4;
      reaction.reactants[1].quantity = 6;

      expect(reaction.limitingReactantIndices, [0]);
    });

    test('O2 limits when H2=6 O2=2', () {
      final reaction = ReactionFactory.makeWater();
      reaction.reactants[0].quantity = 6;
      reaction.reactants[1].quantity = 2;

      expect(reaction.numberOfReactions, 2);
      expect(reaction.limitingReactantIndices, [1]);
    });
  });

  group('Zero reaction', () {
    test('all reactant quantities zero', () {
      final reaction = ReactionFactory.makeWater();
      expect(reaction.numberOfReactions, 0);
      expect(reaction.products[0].quantity, 0);
      expect(reaction.leftovers[0].quantity, 0);
      expect(reaction.leftovers[1].quantity, 0);
    });

    test('custom invalid coefficients are not a reaction', () {
      final custom = SandwichRecipe(
        breadCount: 0,
        meatCount: 0,
        cheeseCount: 0,
        coefficientsMutable: true,
      );
      expect(custom.isReaction(), isFalse);
      expect(custom.numberOfReactions, 0);
      expect(custom.sandwich.quantity, 0);
      expect(custom.sandwich.iconId, 'sandwich:none');
    });

    test('custom becomes valid when coefficients change', () {
      final custom = SandwichRecipe(
        breadCount: 0,
        meatCount: 0,
        cheeseCount: 0,
        coefficientsMutable: true,
      );
      custom.bread.coefficient = 2;
      custom.cheese.coefficient = 1;
      custom.bread.quantity = 4;
      custom.cheese.quantity = 2;

      expect(custom.isReaction(), isTrue);
      expect(custom.numberOfReactions, 2);
      expect(custom.sandwich.quantity, 2);
    });
  });

  group('Reset', () {
    test('sandwiches model reset', () {
      final model = SandwichesModel();
      model.selectedReaction.bread.quantity = 5;
      model.selectReaction(model.reactions[1]);
      model.reset();

      expect(model.selectedReaction.name, 'Cheese');
      expect(model.reactions.every((r) => r.reactants.every((s) => s.quantity == 0)), isTrue);
    });

    test('molecules model reset', () {
      final model = MoleculesModel();
      model.selectedReaction.reactants[0].quantity = 7;
      model.selectReaction(model.reactions.last);
      model.reset();

      expect(model.selectedReaction.name, 'Make Water');
      expect(model.reactions.every((r) => r.products.every((p) => p.quantity == 0)), isTrue);
    });
  });

  group('Game guess', () {
    test('before challenge initializes guess reactants to zero', () {
      final reaction = ReactionFactory.makeWater();
      reaction.reactants[0].quantity = 4;
      reaction.reactants[1].quantity = 2;

      final guess = GameGuess(reaction, BoxType.before);
      expect(guess.reactants[0].quantity, 0);
      expect(guess.reactants[1].quantity, 0);
      expect(guess.products[0].quantity, reaction.products[0].quantity);
    });

    test('after challenge guess matches answer when filled', () {
      final reaction = ReactionFactory.makeWater();
      reaction.reactants[0].quantity = 4;
      reaction.reactants[1].quantity = 2;

      final guess = GameGuess(reaction, BoxType.after);
      guess.products[0].quantity = reaction.products[0].quantity;
      guess.leftovers[0].quantity = reaction.leftovers[0].quantity;
      guess.leftovers[1].quantity = reaction.leftovers[1].quantity;

      expect(guess.isCorrect(reaction), isTrue);
    });
  });
}
