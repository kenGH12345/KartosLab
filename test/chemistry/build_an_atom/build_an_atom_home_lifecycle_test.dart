import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';
import 'package:kratos/chemistry/build_an_atom/screens/atom_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/build_an_atom_home.dart';
import 'package:kratos/chemistry/build_an_atom/screens/game_screen.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> openBaa(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(BuildAnAtomHome.title));
    await tester.tap(find.text(BuildAnAtomHome.title));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('rapid Home entry/exit ×10', (tester) async {
    await setDesktop(tester);
    for (var i = 0; i < 10; i++) {
      await openBaa(tester);
      expect(find.byType(BuildAnAtomHome), findsOneWidget);
      await tester.pageBack();
      for (var j = 0; j < 15; j++) {
        await tester.pump(const Duration(milliseconds: 40));
      }
      expect(find.byType(HomeScreen), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Game timer stops when leaving Home route', (tester) async {
    await setDesktop(tester);
    final g = GameModel(randomSeed: 801)..setTimerEnabled(true);
    g.startLevel(1);
    await tester.pumpWidget(
      MaterialApp(
        home: BuildAnAtomGameScreen(model: g, embedded: true),
      ),
    );
    await tester.pump();
    g.step(1.0);
    expect(g.timer.isRunning, isTrue);
    final frozen = g.timer.elapsedSecondsExact;

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();
    expect(g.timer.isRunning, isFalse);
    await tester.pump(const Duration(seconds: 1));
    expect(g.timer.elapsedSecondsExact, frozen);
  });

  testWidgets('reward leave from Game tab has no exception', (tester) async {
    await setDesktop(tester);
    final g = GameModel(randomSeed: 1)..startLevel(1);
    for (var i = 0; i < 5; i++) {
      final c = g.correctAnswer!;
      g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
      g.next();
    }
    expect(g.gameState, GameState.levelCompleted);
    await tester.pumpWidget(
      MaterialApp(home: BuildAnAtomGameScreen(model: g, embedded: true)),
    );
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Atom↔Symbol↔Game via Home tabs then back', (tester) async {
    await setDesktop(tester);
    await openBaa(tester);
    expect(find.byType(BuildAnAtomAtomScreen), findsOneWidget);

    await tester.tap(find.text(BuildAnAtomHome.symbolTabLabel));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(BuildAnAtomHome.gameTabLabel));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(BuildAnAtomHome.atomTabLabel));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pageBack();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
