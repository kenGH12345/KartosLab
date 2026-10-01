import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';

void main() {
  test('perfect path score 10 reward', () {
    final g = GameModel(randomSeed: 41);
    g.startLevel(1);
    for (var i = 0; i < BAAConstants.challengesPerLevel; i++) {
      final c = g.correctAnswer!;
      g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
      g.next();
    }
    expect(g.gameState, GameState.levelCompleted);
    expect(g.score, 10);
    expect(g.shouldShowReward, isTrue);
    expect(g.starProgress.filledStars, 5);
  });

  test('second-attempt path score 9', () {
    final g = GameModel(randomSeed: 42);
    g.startLevel(1);
    // first challenge: retry then correct (+1)
    g.check(const AnswerAtom(0, 0, 0));
    g.tryAgain();
    var c = g.correctAnswer!;
    g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
    g.next();
    // remaining 4 first-try correct (+8)
    for (var i = 0; i < 4; i++) {
      c = g.correctAnswer!;
      g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
      g.next();
    }
    expect(g.score, 9);
    expect(g.shouldShowReward, isFalse);
  });

  test('low score path still completes', () {
    final g = GameModel(randomSeed: 43);
    g.startLevel(1);
    for (var i = 0; i < BAAConstants.challengesPerLevel; i++) {
      g.check(const AnswerAtom(0, 0, 0));
      if (g.gameState == GameState.tryAgain) {
        g.tryAgain();
        g.check(const AnswerAtom(0, 0, 0));
      }
      if (g.gameState == GameState.attemptsExhausted) {
        g.displayCorrectAnswer();
      }
      g.next();
    }
    expect(g.gameState, GameState.levelCompleted);
    expect(g.score, 0);
    g.startOver();
    expect(g.gameState, GameState.levelSelection);
  });
}
