import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';

void main() {
  test('timer off does not run', () {
    final g = GameModel(randomSeed: 1);
    expect(g.timerEnabled, isFalse);
    g.startLevel(1);
    g.step(1.0);
    expect(g.timer.isRunning, isFalse);
    expect(g.timer.elapsedSeconds, 0);
  });

  test('timer on runs and stops at end', () {
    final g = GameModel(randomSeed: 2);
    g.setTimerEnabled(true);
    g.startLevel(1);
    expect(g.timer.isRunning, isTrue);
    g.step(2.5);
    expect(g.timer.elapsedSeconds, 2);

    for (var i = 0; i < BAAConstants.challengesPerLevel; i++) {
      final c = g.correctAnswer!;
      g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
      g.next();
    }
    expect(g.gameState, GameState.levelCompleted);
    expect(g.timer.isRunning, isFalse);
  });

  test('startOver resets timer elapsed', () {
    final g = GameModel(randomSeed: 3);
    g.setTimerEnabled(true);
    g.startLevel(1);
    g.step(5);
    g.startOver();
    expect(g.timer.elapsedSeconds, 0);
    expect(g.timer.isRunning, isFalse);
  });
}
