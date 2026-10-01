import 'sandwich_recipe.dart';
import 'rpal_base_model.dart';

/// Model for the Sandwiches screen — `SandwichesModel.ts`.
class SandwichesModel extends RpalBaseModel<SandwichRecipe> {
  SandwichesModel()
      : super([
          SandwichRecipe(
            breadCount: 2,
            meatCount: 0,
            cheeseCount: 1,
            name: 'Cheese',
          ),
          SandwichRecipe(
            breadCount: 2,
            meatCount: 1,
            cheeseCount: 1,
            name: 'Meat and Cheese',
          ),
          SandwichRecipe(
            breadCount: 0,
            meatCount: 0,
            cheeseCount: 0,
            coefficientsMutable: true,
            name: 'Custom',
          ),
        ]);
}
