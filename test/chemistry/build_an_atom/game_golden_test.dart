import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';
import 'package:kratos/chemistry/build_an_atom/screens/game_screen.dart';
import 'package:kratos/chemistry/build_an_atom/view/game/game_audio_adapter.dart';

/// Phase 4 Game goldens — fixed seed for determinism.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpGame(
    WidgetTester tester,
    GameModel model, {
    GameAudioAdapter? audio,
  }) async {
    await tester.binding.setSurfaceSize(
      const Size(BAAConstants.designWidth, BAAConstants.designHeight + 56),
    );
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(BAAConstants.designWidth, BAAConstants.designHeight + 56),
            devicePixelRatio: 1,
            textScaler: TextScaler.linear(1),
          ),
          child: BuildAnAtomGameScreen(model: model, audio: audio),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
  }

  group('Game goldens', () {
    testWidgets('game_level_selection', (tester) async {
      final g = GameModel(randomSeed: 1);
      await pumpGame(tester, g);
      await expectLater(
        find.byType(BuildAnAtomGameScreen),
        matchesGoldenFile('golden/game/game_level_selection.png'),
      );
    });

    testWidgets('game_timer_off', (tester) async {
      final g = GameModel(randomSeed: 1);
      expect(g.timerEnabled, isFalse);
      await pumpGame(tester, g);
      await expectLater(
        find.byType(BuildAnAtomGameScreen),
        matchesGoldenFile('golden/game/game_timer_off.png'),
      );
    });

    testWidgets('game_timer_on', (tester) async {
      final g = GameModel(randomSeed: 1)..setTimerEnabled(true);
      await pumpGame(tester, g);
      await expectLater(
        find.byType(BuildAnAtomGameScreen),
        matchesGoldenFile('golden/game/game_timer_on.png'),
      );
    });

    testWidgets('game_level1', (tester) async {
      final g = GameModel(randomSeed: 1)..startLevel(1);
      await pumpGame(tester, g);
      await expectLater(
        find.byType(BuildAnAtomGameScreen),
        matchesGoldenFile('golden/game/game_level1.png'),
      );
    });

    testWidgets('game_level2', (tester) async {
      final g = GameModel(randomSeed: 2)..startLevel(2);
      await pumpGame(tester, g);
      await expectLater(
        find.byType(BuildAnAtomGameScreen),
        matchesGoldenFile('golden/game/game_level2.png'),
      );
    });

    testWidgets('game_level3', (tester) async {
      final g = GameModel(randomSeed: 3)..startLevel(3);
      await pumpGame(tester, g);
      await expectLater(
        find.byType(BuildAnAtomGameScreen),
        matchesGoldenFile('golden/game/game_level3.png'),
      );
    });

    testWidgets('game_level4', (tester) async {
      final g = GameModel(randomSeed: 4)..startLevel(4);
      await pumpGame(tester, g);
      await expectLater(
        find.byType(BuildAnAtomGameScreen),
        matchesGoldenFile('golden/game/game_level4.png'),
      );
    });

    testWidgets('game_try_again', (tester) async {
      final g = GameModel(randomSeed: 1)..startLevel(1);
      g.check(const AnswerAtom(0, 0, 0));
      await pumpGame(tester, g);
      expect(g.gameState, GameState.tryAgain);
      await expectLater(
        find.byType(BuildAnAtomGameScreen),
        matchesGoldenFile('golden/game/game_try_again.png'),
      );
    });

    testWidgets('game_show_answer', (tester) async {
      final g = GameModel(randomSeed: 1)..startLevel(1);
      g.check(const AnswerAtom(0, 0, 0));
      g.tryAgain();
      g.check(const AnswerAtom(0, 0, 0));
      g.displayCorrectAnswer();
      await pumpGame(tester, g);
      expect(g.gameState, GameState.showingAnswer);
      await expectLater(
        find.byType(BuildAnAtomGameScreen),
        matchesGoldenFile('golden/game/game_show_answer.png'),
      );
    });

    testWidgets('game_correct', (tester) async {
      final g = GameModel(randomSeed: 1)..startLevel(1);
      final c = g.correctAnswer!;
      g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
      await pumpGame(tester, g);
      expect(g.gameState, GameState.solvedCorrectly);
      await expectLater(
        find.byType(BuildAnAtomGameScreen),
        matchesGoldenFile('golden/game/game_correct.png'),
      );
    });

    testWidgets('game_level_complete', (tester) async {
      final g = GameModel(randomSeed: 1)..startLevel(1);
      for (var i = 0; i < 5; i++) {
        final c = g.correctAnswer!;
        g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
        g.next();
      }
      await pumpGame(tester, g);
      expect(g.gameState, GameState.levelCompleted);
      await expectLater(
        find.byType(BuildAnAtomGameScreen),
        matchesGoldenFile('golden/game/game_level_complete.png'),
      );
    });

    testWidgets('game_reward', (tester) async {
      final audio = GameAudioAdapter();
      final g = GameModel(randomSeed: 1)..startLevel(1);
      for (var i = 0; i < 5; i++) {
        final c = g.correctAnswer!;
        g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
        g.next();
      }
      expect(g.shouldShowReward, isTrue);
      await pumpGame(tester, g, audio: audio);
      await tester.pump(const Duration(milliseconds: 100));
      await expectLater(
        find.byType(BuildAnAtomGameScreen),
        matchesGoldenFile('golden/game/game_reward.png'),
      );
    });
  });
}
