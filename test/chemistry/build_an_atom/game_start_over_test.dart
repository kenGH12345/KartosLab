import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';

void main() {
  test('startOver keeps best, bumps seed', () {
    final g = GameModel(randomSeed: 70);
    g.startLevel(1);
    for (var i = 0; i < BAAConstants.challengesPerLevel; i++) {
      final c = g.correctAnswer!;
      g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
      g.next();
    }
    final best = g.levels[0].bestScore;
    final seed = g.randomSeed;
    expect(best, 10);

    g.startOver();
    expect(g.gameState, GameState.levelSelection);
    expect(g.levels[0].bestScore, best);
    expect(g.randomSeed, seed + 1);
    expect(g.score, 0);
  });
}
