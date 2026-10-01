import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';

void main() {
  test('show answer displays after two failures', () {
    final g = GameModel(randomSeed: 1);
    g.startLevel(1);
    g.check(const AnswerAtom(0, 0, 0));
    expect(g.gameState, GameState.tryAgain);
    g.tryAgain();
    g.check(const AnswerAtom(0, 0, 0));
    expect(g.gameState, GameState.attemptsExhausted);
    g.displayCorrectAnswer();
    expect(g.gameState, GameState.showingAnswer);
    expect(g.correctAnswer, isNotNull);
  });
}
