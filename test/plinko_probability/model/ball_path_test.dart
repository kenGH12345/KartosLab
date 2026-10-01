import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/plinko_probability/model/ball.dart';
import 'package:kratos/plinko_probability/model/ball_phase.dart';
import 'package:kratos/plinko_probability/model/histogram.dart';
import 'package:kratos/plinko_probability/model/peg.dart';
import 'package:kratos/plinko_probability/model/plinko_random.dart';

void main() {
  List<BinInfo> emptyBins([int n = 27]) =>
      List.generate(n, (_) => BinInfo());

  group('Ball path precompute', () {
    test('p=1 always goes right -> binIndex = numberOfRows', () {
      final ball = Ball(
        probability: 1,
        numberOfRows: 12,
        bins: emptyBins(),
        random: PlinkoRandom(1),
      );
      expect(ball.binIndex, 12);
      expect(
        ball.pegHistory.every((h) => h.direction == PegDirection.right),
        isTrue,
      );
    });

    test('p=0 always goes left -> binIndex = 0', () {
      final ball = Ball(
        probability: 0,
        numberOfRows: 12,
        bins: emptyBins(),
        random: PlinkoRandom(1),
      );
      expect(ball.binIndex, 0);
      expect(
        ball.pegHistory.every((h) => h.direction == PegDirection.left),
        isTrue,
      );
    });

    test('pegHistory length = numberOfRows + 1', () {
      final ball = Ball(
        probability: 0.5,
        numberOfRows: 8,
        bins: emptyBins(),
        random: PlinkoRandom(42),
      );
      expect(ball.pegHistory.length, 9);
    });

    test('seeded p=0.5 mean binIndex ~ n*p', () {
      final rng = PlinkoRandom(12345);
      var rightTotal = 0;
      const balls = 2000;
      const rows = 12;
      for (var i = 0; i < balls; i++) {
        final ball = Ball(
          probability: 0.5,
          numberOfRows: rows,
          bins: emptyBins(),
          random: rng,
        );
        rightTotal += ball.binIndex;
      }
      final meanRightsPerBall = rightTotal / balls;
      expect(meanRightsPerBall, closeTo(6.0, 0.25));
    });
  });

  group('Ball motion', () {
    test('phases progress to COLLECTED', () {
      final ball = Ball(
        probability: 1,
        numberOfRows: 3,
        bins: emptyBins(),
        random: PlinkoRandom(0),
      );
      ball.finalBinVerticalOffset = -2;

      expect(ball.phase, BallPhase.initial);
      var guard = 0;
      while (ball.phase != BallPhase.collected && guard < 5000) {
        ball.step(0.05);
        guard++;
      }
      expect(ball.phase, BallPhase.collected);
      expect(guard, lessThan(5000));
    });

    test('updateStatisticsAndLand skips animation from INITIAL', () {
      var out = 0;
      var collected = 0;
      final ball = Ball(
        probability: 0.5,
        numberOfRows: 5,
        bins: emptyBins(),
        random: PlinkoRandom(7),
      );
      ball.onOutOfPegs = () => out++;
      ball.onCollected = () => collected++;
      ball.updateStatisticsAndLand();
      expect(ball.phase, BallPhase.collected);
      expect(out, 1);
      expect(collected, 1);
    });
  });
}
