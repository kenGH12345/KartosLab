import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';
import 'package:kratos/chemistry/build_an_atom/screens/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpGame(WidgetTester tester, GameModel g) async {
    await tester.pumpWidget(MaterialApp(home: BuildAnAtomGameScreen(model: g)));
    await tester.pump();
  }

  void answerCorrect(GameModel g) {
    final c = g.correctAnswer!;
    g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
  }

  testWidgets('normal path level 1 five challenges to complete', (tester) async {
    final g = GameModel(randomSeed: 21);
    await pumpGame(tester, g);
    await tester.tap(find.text('Periodic Table'));
    await tester.pump();

    for (var i = 0; i < BAAConstants.challengesPerLevel; i++) {
      expect(g.gameState, GameState.presentingChallenge);
      answerCorrect(g);
      await tester.pump();
      expect(g.gameState, GameState.solvedCorrectly);
      await tester.tap(find.text('Next'));
      await tester.pump();
    }
    expect(g.gameState, GameState.levelCompleted);
    expect(g.score, 10);
    expect(find.textContaining('Complete'), findsOneWidget);
  });

  testWidgets('all four levels playable one challenge each', (tester) async {
    for (var level = 1; level <= 4; level++) {
      final g = GameModel(randomSeed: 100 + level);
      await pumpGame(tester, g);
      g.startLevel(level);
      await tester.pump();
      expect(g.levelNumber, level);
      expect(g.challenge, isNotNull);
      answerCorrect(g);
      await tester.pump();
      expect(g.gameState, GameState.solvedCorrectly);
      g.startOver();
      await tester.pump();
    }
  });
}
