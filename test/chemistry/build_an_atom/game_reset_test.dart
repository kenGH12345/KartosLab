import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';

void main() {
  test('reset during game clears best and timer preference', () {
    final g = GameModel(randomSeed: 60);
    g.setTimerEnabled(true);
    g.startLevel(1);
    final c = g.correctAnswer!;
    g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
    // finish level to set best
    while (g.gameState != GameState.levelCompleted) {
      if (g.gameState == GameState.solvedCorrectly ||
          g.gameState == GameState.showingAnswer) {
        g.next();
      } else if (g.gameState == GameState.presentingChallenge) {
        final a = g.correctAnswer!;
        g.check(AnswerAtom(a.protons, a.neutrons, a.electrons));
      } else if (g.gameState == GameState.tryAgain) {
        g.tryAgain();
      } else if (g.gameState == GameState.attemptsExhausted) {
        g.displayCorrectAnswer();
      }
    }
    expect(g.levels[0].bestScore, greaterThan(0));

    g.startLevel(1); // mid-game
    g.reset();
    expect(g.gameState, GameState.levelSelection);
    expect(g.levels[0].bestScore, 0);
    expect(g.timerEnabled, isFalse);
    expect(g.score, 0);
  });
}
