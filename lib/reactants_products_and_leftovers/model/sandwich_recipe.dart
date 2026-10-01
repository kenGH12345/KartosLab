import '../rpal_symbols.dart';
import 'reaction.dart';
import 'substance.dart';

/// Sandwich recipe — `SandwichRecipe.ts`.
class SandwichRecipe extends Reaction {
  factory SandwichRecipe({
    required int breadCount,
    required int meatCount,
    required int cheeseCount,
    bool coefficientsMutable = false,
    String? name,
  }) {
    final bread = Substance(
      coefficient: breadCount,
      symbol: RpalSymbols.bread,
      iconId: 'bread',
    );
    final meat = Substance(
      coefficient: meatCount,
      symbol: RpalSymbols.meat,
      iconId: 'meat',
    );
    final cheese = Substance(
      coefficient: cheeseCount,
      symbol: RpalSymbols.cheese,
      iconId: 'cheese',
    );

    final ingredients = <Substance>[];
    if (breadCount > 0 || coefficientsMutable) {
      ingredients.add(bread);
    }
    if (meatCount > 0 || coefficientsMutable) {
      ingredients.add(meat);
    }
    if (cheeseCount > 0 || coefficientsMutable) {
      ingredients.add(cheese);
    }

    final sandwich = Substance(
      coefficient: 1,
      symbol: RpalSymbols.sandwich,
      iconId: coefficientsMutable ? 'sandwich_dynamic' : 'sandwich_static',
    );

    final recipe = SandwichRecipe._(
      reactants: ingredients,
      sandwich: sandwich,
      coefficientsMutable: coefficientsMutable,
      name: name,
      bread: bread,
      meat: meat,
      cheese: cheese,
    );

    assert(
      coefficientsMutable || recipe.isReaction(),
      'a static recipe must be a valid reaction',
    );

    if (coefficientsMutable) {
      for (final ingredient in ingredients) {
        final previous = ingredient.onChanged;
        ingredient.onChanged = () {
          previous?.call();
          recipe._updateSandwichIcon();
          recipe.updateQuantities();
        };
      }
      recipe._updateSandwichIcon();
    }

    return recipe;
  }

  SandwichRecipe._({
    required super.reactants,
    required this.sandwich,
    required this.coefficientsMutable,
    super.name,
    required this.bread,
    required this.meat,
    required this.cheese,
  }) : super(products: [sandwich]);

  final Substance sandwich;
  final bool coefficientsMutable;
  final Substance bread;
  final Substance meat;
  final Substance cheese;

  bool get hasValidSandwich => isReaction();

  void _updateSandwichIcon() {
    if (!coefficientsMutable) {
      return;
    }
    sandwich.iconId = isReaction()
        ? 'sandwich:${bread.coefficient},${meat.coefficient},${cheese.coefficient}'
        : 'sandwich:none';
  }
}
