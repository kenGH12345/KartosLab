import 'substance.dart';

/// Chemical reaction model — `Reaction.ts`.
class Reaction {
  Reaction({
    required List<Substance> reactants,
    required List<Substance> products,
    this.name,
  })  : assert(reactants.length > 1, 'a reaction requires at least 2 reactants'),
        assert(products.isNotEmpty, 'a reaction requires at least 1 product'),
        reactants = List.unmodifiable(reactants),
        products = List.unmodifiable(products),
        leftovers = _createLeftovers(reactants) {
    for (final reactant in reactants) {
      reactant.onChanged = updateQuantities;
    }
    updateQuantities();
  }

  final String? name;
  final List<Substance> reactants;
  final List<Substance> products;
  final List<Substance> leftovers;

  static List<Substance> _createLeftovers(List<Substance> reactants) {
    return reactants
        .map(
          (reactant) => Substance(
            coefficient: 1,
            symbol: reactant.symbol,
            iconId: reactant.iconId,
            quantity: 0,
          ),
        )
        .toList(growable: false);
  }

  /// Formula is a reaction if more than one coefficient is non-zero,
  /// or if any coefficient is > 1.
  bool isReaction() {
    var greaterThanZero = 0;
    var greaterThanOne = 0;
    for (final reactant in reactants) {
      if (reactant.coefficient > 0) {
        greaterThanZero++;
      }
      if (reactant.coefficient > 1) {
        greaterThanOne++;
      }
    }
    return greaterThanZero > 1 || greaterThanOne > 0;
  }

  int get numberOfReactions => _getNumberOfReactions();

  int _getNumberOfReactions() {
    if (!isReaction()) {
      return 0;
    }

    final possibleValues = <int>[];
    for (final reactant in reactants) {
      if (reactant.coefficient != 0) {
        possibleValues.add(reactant.quantity ~/ reactant.coefficient);
      }
    }
    assert(possibleValues.isNotEmpty);
    possibleValues.sort();
    return possibleValues.first;
  }

  /// Indices of reactants that limit the number of complete reaction sets.
  List<int> get limitingReactantIndices {
    final count = numberOfReactions;
    if (count == 0) {
      return const [];
    }

    final indices = <int>[];
    for (var i = 0; i < reactants.length; i++) {
      final reactant = reactants[i];
      if (reactant.coefficient != 0 &&
          reactant.quantity ~/ reactant.coefficient == count) {
        indices.add(i);
      }
    }
    return indices;
  }

  void updateQuantities() {
    final count = _getNumberOfReactions();
    for (final product in products) {
      product.quantity = count * product.coefficient;
    }
    for (var i = 0; i < reactants.length; i++) {
      leftovers[i].quantity =
          reactants[i].quantity - (count * reactants[i].coefficient);
    }
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
    updateQuantities();
  }
}
