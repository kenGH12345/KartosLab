import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';
import 'package:kratos/chemistry/build_an_atom/screens/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpGame(WidgetTester tester, {GameModel? model}) async {
    await tester.pumpWidget(
      MaterialApp(home: BuildAnAtomGameScreen(model: model)),
    );
    await tester.pump();
  }

  testWidgets('enters level selection', (tester) async {
    await pumpGame(tester);
    expect(find.text('Choose Your Game!'), findsOneWidget);
    expect(find.text('Timer: OFF'), findsOneWidget);
    expect(find.text('Periodic Table'), findsOneWidget);
    expect(find.text('Mass and Charge'), findsOneWidget);
    expect(find.text('Symbols'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);
  });

  testWidgets('select level 1 enters presentingChallenge', (tester) async {
    final g = GameModel(randomSeed: 11);
    await pumpGame(tester, model: g);
    await tester.tap(find.text('Periodic Table'));
    await tester.pump();
    expect(g.gameState, GameState.presentingChallenge);
    expect(g.levelNumber, 1);
    expect(g.challengeNumber, 1);
    expect(find.text('Check'), findsOneWidget);
    expect(find.textContaining('Challenge 1 of 5'), findsOneWidget);
  });

  testWidgets('select level 2 not level 1', (tester) async {
    final g = GameModel(randomSeed: 12);
    await pumpGame(tester, model: g);
    await tester.tap(find.text('Mass and Charge'));
    await tester.pump();
    expect(g.levelNumber, 2);
  });
}
