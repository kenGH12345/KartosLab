import 'box_type.dart';
import 'game_guess.dart';
import 'reaction.dart';

/// One game challenge — `Challenge.ts`.
class Challenge {
  Challenge({
    required this.reaction,
    required this.interactiveBox,
    this.moleculesVisible = true,
    this.numbersVisible = true,
  }) : guess = GameGuess(reaction, interactiveBox);

  final Reaction reaction;
  final BoxType interactiveBox;
  final bool moleculesVisible;
  final bool numbersVisible;
  final GameGuess guess;
  int points = 0;

  bool isCorrect() => guess.isCorrect(reaction);

  void showAnswer() {
    for (var i = 0; i < guess.reactants.length; i++) {
      guess.reactants[i].quantity = reaction.reactants[i].quantity;
    }
    for (var i = 0; i < guess.products.length; i++) {
      guess.products[i].quantity = reaction.products[i].quantity;
    }
    for (var i = 0; i < guess.leftovers.length; i++) {
      guess.leftovers[i].quantity = reaction.leftovers[i].quantity;
    }
  }

  void reset() {
    guess.reset();
    points = 0;
  }
}
