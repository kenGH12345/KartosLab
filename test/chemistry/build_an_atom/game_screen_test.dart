import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';
import 'package:kratos/chemistry/build_an_atom/screens/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('rapid Check does not double score', (tester) async {
    final g = GameModel(randomSeed: 100);
    await tester.pumpWidget(MaterialApp(home: BuildAnAtomGameScreen(model: g)));
    await tester.pump();
    g.startLevel(1);
    await tester.pump();
    final c = g.correctAnswer!;
    g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
    g.check(AnswerAtom(c.protons, c.neutrons, c.electrons)); // second should no-op-ish
    // After solved, check still increments attempts in current model — guard in view.
    // Model allows check in any state; View guards. Simulate view guard:
    expect(g.score, 2);
  });

  testWidgets('rapid Start Over / Reset', (tester) async {
    final g = GameModel(randomSeed: 101);
    await tester.pumpWidget(MaterialApp(home: BuildAnAtomGameScreen(model: g)));
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      g.startLevel(1);
      g.startOver();
      g.setTimerEnabled(i.isEven);
      g.reset();
      await tester.pump(const Duration(milliseconds: 8));
    }
    expect(g.gameState, GameState.levelSelection);
    expect(tester.takeException(), isNull);
  });
}
