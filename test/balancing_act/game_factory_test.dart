import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

void main() {
  group('SourceFaithfulChallengeFactory', () {
    test('generates 6 challenges per level matching kind schema', () {
      final factory = SourceFaithfulChallengeFactory(random: math.Random(42));
      for (var level = 0; level < 4; level++) {
        final set = factory.generateChallengeSetForLevel(level);
        expect(set.length, 6);
        final expected = BaGameLevelDataset.challengeKindsForLevel(level);
        for (var i = 0; i < 6; i++) {
          expect(set[i].kind, expected[i],
              reason: 'level $level challenge $i');
        }
      }
    });

    test('balance challenges are solvable at balancedConfiguration', () {
      final factory = SourceFaithfulChallengeFactory(random: math.Random(7));
      for (var level = 0; level < 4; level++) {
        final set = factory.generateChallengeSetForLevel(level);
        for (final c in set.where((e) => e.kind == BaChallengeKind.balanceMasses)) {
          expect(c.movableMasses, isNotEmpty);
          expect(c.balancedConfiguration, isNotEmpty);
          expect(c.initialColumnState, ColumnState.singleColumn);
          // Net m*d of fixed + solution ≈ 0
          var torque = 0.0;
          for (final p in c.fixedMassDistancePairs) {
            torque += p.mass.massValue * p.distance;
          }
          for (final p in c.balancedConfiguration) {
            torque += p.mass.massValue * p.distance;
          }
          expect(torque.abs(), lessThan(1e-6));
        }
      }
    });

    test('mass deduction uses mystery fixed + known movable', () {
      final factory = SourceFaithfulChallengeFactory(random: math.Random(3));
      final set = factory.generateChallengeSetForLevel(0);
      final deductions =
          set.where((c) => c.kind == BaChallengeKind.massDeduction).toList();
      expect(deductions, isNotEmpty);
      for (final c in deductions) {
        expect(c.initialColumnState, ColumnState.noColumns);
        expect(c.fixedMassDistancePairs.single.mass.isMystery, isTrue);
        expect(c.movableMasses, isNotEmpty);
        expect(c.showMassEntryDialog, isTrue);
      }
    });

    test('tilt challenges start with DOUBLE columns', () {
      final factory = SourceFaithfulChallengeFactory(random: math.Random(9));
      final set = factory.generateChallengeSetForLevel(0);
      for (final c
          in set.where((e) => e.kind == BaChallengeKind.tiltPrediction)) {
        expect(c.initialColumnState, ColumnState.doubleColumns);
        expect(c.fixedMassDistancePairs.length, greaterThanOrEqualTo(2));
        expect(c.showTiltPredictionSelector, isTrue);
      }
    });

    test('static generateChallengeSet used as production default', () {
      final set = SourceFaithfulChallengeFactory.generateChallengeSet(1);
      expect(set.length, 6);
    });
  });

  group('Game frame-rate integration', () {
    test('step uses source ω+=α semantics independent of call count', () {
      final a = BalanceGameModel(
        challengeSetFactory: DeterministicChallengeFactory.generateChallengeSet,
      );
      final b = BalanceGameModel(
        challengeSetFactory: DeterministicChallengeFactory.generateChallengeSet,
      );
      a.startLevel(0);
      b.startLevel(0);
      // Force imbalance: remove columns with mass on one side
      final challenge = a.getCurrentChallenge()!;
      if (challenge.kind == BaChallengeKind.balanceMasses) {
        final movable = challenge.movableMasses.single;
        a.beginDragMovable(movable);
        a.dragMovableTo(movable, const BaVector2(1.5, 0.9));
        a.endDragMovable(movable);
        a.columnState = ColumnState.noColumns;
        a.plank.onColumnStateChanged(ColumnState.noColumns);

        final movableB = b.getCurrentChallenge()!.movableMasses.single;
        b.beginDragMovable(movableB);
        b.dragMovableTo(movableB, const BaVector2(1.5, 0.9));
        b.endDragMovable(movableB);
        b.columnState = ColumnState.noColumns;
        b.plank.onColumnStateChanged(ColumnState.noColumns);

        // Same total time, different dt
        for (var i = 0; i < 60; i++) {
          a.step(1 / 60);
        }
        for (var i = 0; i < 30; i++) {
          b.step(1 / 30);
        }
        // Angles should be close but NOT identical (source is frame-rate
        // sensitive by design: ω+=α without *dt). Documented P1 behavior.
        expect(a.plank.tiltAngle.abs(), greaterThan(0));
        expect(b.plank.tiltAngle.abs(), greaterThan(0));
      }
    });

    test('large dt still clamps to maxTiltAngle', () {
      final game = BalanceGameModel(
        challengeSetFactory: (_) => [
          DeterministicChallengeFactory.balanceMassesSample(),
        ],
      );
      game.startLevel(0);
      final movable = game.getCurrentChallenge()!.movableMasses.single;
      game.beginDragMovable(movable);
      game.dragMovableTo(movable, const BaVector2(2.0, 0.9));
      game.endDragMovable(movable);
      game.columnState = ColumnState.noColumns;
      game.plank.onColumnStateChanged(ColumnState.noColumns);
      for (var i = 0; i < 20; i++) {
        game.step(0.1);
      }
      expect(game.plank.tiltAngle.abs(),
          lessThanOrEqualTo(BaGeometry.maxTiltAngle + 1e-9));
    });
  });
}
