import 'package:flutter/foundation.dart';

import '../model/sandwich_recipe.dart';
import '../model/sandwiches_model.dart';
import '../model/substance.dart';
import '../rpal_constants.dart';

/// View controller for Sandwiches screen — binds Model + accordion UI state.
class SandwichesController extends ChangeNotifier {
  SandwichesController({SandwichesModel? model})
      : model = model ?? SandwichesModel() {
    _wireModelNotifications();
  }

  final SandwichesModel model;

  bool beforeExpanded = true;
  bool afterExpanded = true;

  SandwichRecipe get selected => model.selectedReaction;

  List<SandwichRecipe> get recipes => model.reactions;

  void _wireModelNotifications() {
    final seen = <Substance>{};
    for (final recipe in model.reactions) {
      for (final substance in [
        ...recipe.reactants,
        ...recipe.products,
        ...recipe.leftovers,
        recipe.bread,
        recipe.meat,
        recipe.cheese,
        recipe.sandwich,
      ]) {
        if (seen.add(substance)) {
          _chainNotify(substance);
        }
      }
    }
  }

  void _chainNotify(Substance substance) {
    final previous = substance.onChanged;
    substance.onChanged = () {
      previous?.call();
      notifyListeners();
    };
  }

  void selectRecipe(SandwichRecipe recipe) {
    if (identical(model.selectedReaction, recipe)) {
      return;
    }
    model.selectReaction(recipe);
    notifyListeners();
  }

  void setReactantQuantity(Substance reactant, int quantity) {
    final clamped = quantity.clamp(
      RpalConstants.quantityMin,
      RpalConstants.quantityMax,
    );
    if (reactant.quantity == clamped) {
      return;
    }
    reactant.quantity = clamped;
    // onChanged → updateQuantities → notifyListeners
  }

  void setCoefficient(Substance ingredient, int coefficient) {
    assert(selected.coefficientsMutable);
    final clamped = coefficient.clamp(
      RpalConstants.sandwichCoefficientMin,
      RpalConstants.sandwichCoefficientMax,
    );
    if (ingredient.coefficient == clamped) {
      return;
    }
    ingredient.coefficient = clamped;
  }

  void toggleBeforeExpanded() {
    beforeExpanded = !beforeExpanded;
    notifyListeners();
  }

  void toggleAfterExpanded() {
    afterExpanded = !afterExpanded;
    notifyListeners();
  }

  void reset() {
    model.reset();
    beforeExpanded = true;
    afterExpanded = true;
    notifyListeners();
  }
}
