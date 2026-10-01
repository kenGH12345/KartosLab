import 'dart:math';

import '../rpal_constants.dart';
import 'box_type.dart';
import 'challenge.dart';
import 'reaction.dart';
import 'reaction_factory.dart';

/// Challenge generation — `ChallengeFactory.ts`.
class ChallengeFactory {
  ChallengeFactory._();

  static const challengesPerLevel = RpalConstants.challengesPerLevel;

  static const interactiveBoxes = [
    BoxType.before,
    BoxType.after,
    BoxType.after,
  ];

  static int getNumberOfChallenges(int level) {
    assert(level >= 0 && level < ReactionFactory.pools.length);
    return challengesPerLevel;
  }

  static List<Challenge> createChallenges(
    int level,
    int maxQuantity, {
    bool moleculesVisible = true,
    bool numbersVisible = true,
    Random? random,
  }) {
    assert(level >= 0 && level < ReactionFactory.pools.length);
    assert(maxQuantity > 0);
    final rng = random ?? Random();

    final factoryFunctions =
        List<Reaction Function()>.from(ReactionFactory.pools[level]);
    final zeroProductsIndex = rng.nextInt(challengesPerLevel);
    final challenges = <Challenge>[];

    for (var i = 0; i < challengesPerLevel; i++) {
      final Reaction reaction;
      if (i == zeroProductsIndex) {
        reaction = _createWithoutProducts(factoryFunctions, rng);
      } else {
        reaction = _createWithProducts(factoryFunctions, maxQuantity, rng);
      }
      _fixQuantityRangeViolation(reaction, maxQuantity);
      challenges.add(
        Challenge(
          reaction: reaction,
          interactiveBox: interactiveBoxes[level],
          moleculesVisible: moleculesVisible,
          numbersVisible: numbersVisible,
        ),
      );
    }
    assert(challenges.length == challengesPerLevel);
    return challenges;
  }

  static Reaction _createWithProducts(
    List<Reaction Function()> factoryFunctions,
    int maxQuantity,
    Random rng,
  ) {
    assert(factoryFunctions.isNotEmpty);
    final index = rng.nextInt(factoryFunctions.length);
    final factory = factoryFunctions.removeAt(index);
    final reaction = factory();
    for (final reactant in reaction.reactants) {
      final minQ = reactant.coefficient;
      reactant.quantity = minQ + rng.nextInt(maxQuantity - minQ + 1);
    }
    return reaction;
  }

  static Reaction _createWithoutProducts(
    List<Reaction Function()> factoryFunctions,
    Random rng,
  ) {
    assert(factoryFunctions.isNotEmpty);
    final disqualified = <Reaction Function()>[];
    Reaction? reaction;
    var retry = true;
    while (retry) {
      assert(factoryFunctions.isNotEmpty);
      final index = rng.nextInt(factoryFunctions.length);
      final factory = factoryFunctions.removeAt(index);
      reaction = factory();
      retry = _hasReactantCoefficientsAllOne(reaction);
      if (retry) {
        disqualified.add(factory);
      }
    }
    factoryFunctions.addAll(disqualified);
    final generated = reaction!;
    for (final reactant in generated.reactants) {
      final maxExclusive = max(1, reactant.coefficient - 1);
      reactant.quantity = 1 + rng.nextInt(maxExclusive);
    }
    return generated;
  }

  static bool _hasReactantCoefficientsAllOne(Reaction reaction) {
    return reaction.reactants.every((r) => r.coefficient == 1);
  }

  static bool _hasQuantityRangeViolation(Reaction reaction, int maxQuantity) {
    for (final s in [
      ...reaction.reactants,
      ...reaction.products,
      ...reaction.leftovers,
    ]) {
      if (s.quantity > maxQuantity) {
        return true;
      }
    }
    return false;
  }

  static void _fixQuantityRangeViolation(Reaction reaction, int maxQuantity) {
    if (!_hasQuantityRangeViolation(reaction, maxQuantity)) {
      return;
    }
    for (final reactant in reaction.reactants) {
      if (reactant.quantity > maxQuantity) {
        reactant.quantity = maxQuantity;
      }
    }
    var reactantIndex = 0;
    var changed = false;
    while (_hasQuantityRangeViolation(reaction, maxQuantity)) {
      final reactant = reaction.reactants[reactantIndex];
      if (reactant.quantity > 1) {
        reactant.quantity = reactant.quantity - 1;
        changed = true;
      }
      reactantIndex++;
      if (reactantIndex > reaction.reactants.length - 1) {
        reactantIndex = 0;
        if (!changed) {
          break;
        }
        changed = false;
      }
    }
    if (_hasQuantityRangeViolation(reaction, maxQuantity)) {
      throw StateError('quantity-range violation cannot be fixed');
    }
  }
}
