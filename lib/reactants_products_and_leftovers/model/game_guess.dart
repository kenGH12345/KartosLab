import 'box_type.dart';
import 'reaction.dart';
import 'substance.dart';

/// User answer to a game challenge — `GameGuess.ts`.
class GameGuess {
  GameGuess(Reaction reaction, BoxType interactiveBox)
      : reactants = _cloneReactants(reaction, interactiveBox),
        products = _cloneProducts(reaction, interactiveBox),
        leftovers = _cloneLeftovers(reaction, interactiveBox);

  final List<Substance> reactants;
  final List<Substance> products;
  final List<Substance> leftovers;

  static List<Substance> _cloneReactants(
    Reaction reaction,
    BoxType interactiveBox,
  ) {
    return reaction.reactants
        .map(
          (reactant) => reactant.clone(
            quantity: interactiveBox == BoxType.before ? 0 : null,
          ),
        )
        .toList(growable: false);
  }

  static List<Substance> _cloneProducts(
    Reaction reaction,
    BoxType interactiveBox,
  ) {
    return reaction.products
        .map(
          (product) => product.clone(
            quantity: interactiveBox == BoxType.after ? 0 : null,
          ),
        )
        .toList(growable: false);
  }

  static List<Substance> _cloneLeftovers(
    Reaction reaction,
    BoxType interactiveBox,
  ) {
    return reaction.leftovers
        .map(
          (leftover) => leftover.clone(
            quantity: interactiveBox == BoxType.after ? 0 : null,
          ),
        )
        .toList(growable: false);
  }

  bool isCorrect(Reaction answer) {
    for (var i = 0; i < reactants.length; i++) {
      if (!reactants[i].equalsSubstance(answer.reactants[i])) {
        return false;
      }
    }
    for (var i = 0; i < products.length; i++) {
      if (!products[i].equalsSubstance(answer.products[i])) {
        return false;
      }
    }
    for (var i = 0; i < leftovers.length; i++) {
      if (!leftovers[i].equalsSubstance(answer.leftovers[i])) {
        return false;
      }
    }
    return true;
  }

  void reset() {
    for (final reactant in reactants) {
      reactant.reset();
    }
    for (final product in products) {
      product.reset();
    }
    for (final leftover in leftovers) {
      leftover.reset();
    }
  }
}
