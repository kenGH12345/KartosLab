import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('retry path: wrong then correct → +1', (tester) async {
    final g = GameModel(randomSeed: 31);
    await pumpGame(tester, g);
    g.startLevel(1);
    await tester.pump();

    g.check(const AnswerAtom(0, 0, 0));
    await tester.pump();
    expect(g.gameState, GameState.tryAgain);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pump();
    expect(g.gameState, GameState.presentingChallenge);

    final c = g.correctAnswer!;
    g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
    await tester.pump();
    expect(g.score, 1);
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('exhausted → Show Answer → Next', (tester) async {
    final g = GameModel(randomSeed: 32);
    await pumpGame(tester, g);
    g.startLevel(1);
    await tester.pump();

    g.check(const AnswerAtom(0, 0, 0));
    await tester.pump();
    await tester.tap(find.text('Try Again'));
    await tester.pump();
    g.check(const AnswerAtom(0, 0, 0));
    await tester.pump();
    expect(g.gameState, GameState.attemptsExhausted);
    expect(find.text('Show Answer'), findsOneWidget);

    await tester.tap(find.text('Show Answer'));
    await tester.pump();
    expect(g.gameState, GameState.showingAnswer);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(g.challengeNumber, 2);
  });
}
