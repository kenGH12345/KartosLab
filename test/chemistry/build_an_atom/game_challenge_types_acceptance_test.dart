import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/challenge_descriptor_set_factory.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/challenge_type.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';
import 'package:kratos/chemistry/build_an_atom/screens/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('15 ChallengeType: create → validate via GameModel.check', () {
    final seen = <ChallengeType>{};

    for (var seed = 1; seed <= 120 && seen.length < ChallengeType.count; seed++) {
      final g = GameModel(randomSeed: seed);
      for (var level = 1; level <= 4; level++) {
        g.startLevel(level);
        for (var i = 0; i < BAAConstants.challengesPerLevel; i++) {
          final type = g.challenge!.type;
          final c = g.correctAnswer!;
          g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
          expect(
            g.gameState,
            anyOf(GameState.solvedCorrectly, GameState.levelCompleted),
            reason: 'type $type failed',
          );
          seen.add(type);
          if (g.gameState == GameState.solvedCorrectly ||
              g.gameState == GameState.showingAnswer) {
            g.next();
          }
          if (g.gameState == GameState.levelCompleted) break;
        }
        g.startOver();
      }
    }

    expect(
      seen.length,
      ChallengeType.count,
      reason: 'missing ${ChallengeType.values.toSet().difference(seen)}',
    );
  });

  testWidgets('each ChallengeType can render on Game Screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    final seen = <ChallengeType>{};

    for (var seed = 1; seed <= 80 && seen.length < ChallengeType.count; seed++) {
      final g = GameModel(randomSeed: seed);
      for (var level = 1; level <= 4 && seen.length < ChallengeType.count; level++) {
        g.startLevel(level);
        for (var i = 0; i < 5 && seen.length < ChallengeType.count; i++) {
          final type = g.challenge!.type;
          if (!seen.contains(type)) {
            await tester.pumpWidget(
              MaterialApp(home: BuildAnAtomGameScreen(model: g)),
            );
            await tester.pump();
            expect(tester.takeException(), isNull, reason: 'render $type');
            seen.add(type);
          }
          final c = g.correctAnswer!;
          g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
          if (g.gameState == GameState.solvedCorrectly) g.next();
          if (g.gameState == GameState.levelCompleted) break;
        }
        g.startOver();
      }
    }
    expect(seen.length, ChallengeType.count);
  });

  test('pool sizes intact', () {
    expect(kLevelChallengeTypes.length, 4);
    expect(ChallengeType.count, 15);
  });
}
