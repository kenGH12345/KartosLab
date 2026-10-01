import 'dart:math' as math;

import '../plinko_constants.dart';
import 'ball.dart';
import 'ball_phase.dart';
import 'lab_ball.dart';
import 'plinko_common_model.dart';

/// Lab screen model — `LabModel.js`.
class LabModel extends PlinkoCommonModel {
  LabModel({super.random}) {
    // Lab default ballMode is oneBall; continuous uses isPlaying.
  }

  bool isPlaying = false;
  double ballCreationTimeInterval = PlinkoConstants.labIntervalBall;

  @override
  void setHopperMode(HopperMode mode) {
    if (hopperMode == mode) return;

    // When switching hopper mode, remove in-flight balls from binCount.
    for (final ball in balls) {
      if (ball.phase != BallPhase.exited &&
          ball.phase != BallPhase.collected) {
        histogram.bins[ball.binIndex].binCount--;
      }
    }
    balls.clear();
    hopperMode = mode;
    notifyChanged();
  }

  @override
  void reset() {
    isPlaying = false;
    super.reset();
  }

  void setPlaying(bool value) {
    if (isPlaying == value) return;
    isPlaying = value;
    notifyChanged();
  }

  /// Play button behavior for Lab.
  void playPressed() {
    switch (ballMode) {
      case BallMode.oneBall:
        addNewBall();
      case BallMode.continuous:
        setPlaying(true);
      case BallMode.tenBalls:
      case BallMode.maxBalls:
        break;
    }
  }

  void pausePressed() => setPlaying(false);

  @override
  void step(double dt) {
    ballCreationTimeElapsed += dt;

    if (isPlaying && ballCreationTimeElapsed > ballCreationTimeInterval) {
      addNewBall();
      ballCreationTimeElapsed = 0;
    }

    switch (hopperMode) {
      case HopperMode.ball:
        var ballsMoved = false;
        final dtCapped = dt * PlinkoConstants.labDtCapFactor;
        final capped = dtCapped > PlinkoConstants.labDtCap
            ? PlinkoConstants.labDtCap
            : dtCapped;
        for (final ball in List<Ball>.from(balls)) {
          final moved = ball.step(capped);
          ballsMoved = moved || ballsMoved;
        }
        if (ballsMoved) onBallsMoved?.call();
        ballCreationTimeInterval = PlinkoConstants.labIntervalBall;
      case HopperMode.path:
        for (final ball in List<Ball>.from(balls)) {
          ball.updateStatisticsAndLand();
        }
        ballCreationTimeInterval = PlinkoConstants.labIntervalPath;
      case HopperMode.none:
        for (final ball in List<Ball>.from(balls)) {
          ball.updateStatisticsAndLand();
        }
        ballCreationTimeInterval = PlinkoConstants.labIntervalNone;
    }
  }

  void addNewBall() {
    final added = LabBall(
      probability: probability,
      numberOfRows: numberOfRows,
      bins: histogram.bins,
      random: random,
    );
    histogram.bins[added.binIndex].binCount++;
    balls.add(added);

    if (histogram.getMaximumActualBinCount() >= PlinkoConstants.maxBallsLab) {
      isBallCapReached = true;
    }

    added.onHittingPeg = (direction) {
      onBallHittingPeg?.call(direction);
    };
    added.onOutOfPegs = () {
      histogram.addBallToHistogram(added);
    };

    added.onCollected = () {
      final previousIndex = balls.indexOf(added) - 1;
      if (previousIndex >= 0) {
        balls.removeAt(previousIndex);
      }
    };

    notifyChanged();
  }

  // —— Theoretical binomial (Lab only) ——

  double getTheoreticalAverage(int n, double p) => n * p;

  double getTheoreticalStandardDeviation(int n, double p) =>
      math.sqrt(n * p * (1 - p));

  double getBinomialCoefficient(int n, int k) {
    var coefficient = 1.0;
    for (var i = n - k + 1; i <= n; i++) {
      coefficient *= i;
    }
    for (var i = 1; i <= k; i++) {
      coefficient /= i;
    }
    return coefficient;
  }

  double getBinomialProbability(int n, int k, double p) {
    assert(k <= n);
    final coeff = getBinomialCoefficient(n, k);
    final weight = math.pow(p, k) * math.pow(1 - p, n - k);
    return coeff * weight;
  }

  List<double> getBinomialDistribution() {
    final n = numberOfRows;
    return [
      for (var k = 0; k < n + 1; k++)
        getBinomialProbability(n, k, probability),
    ];
  }

  List<double> getNormalizedBinomialDistribution() {
    final dist = getBinomialDistribution();
    final maxCoefficient = dist.reduce(math.max);
    if (maxCoefficient == 0) return dist;
    return [for (final num in dist) num / maxCoefficient];
  }

  double get theoreticalAverage =>
      getTheoreticalAverage(numberOfRows, probability);

  double get theoreticalStandardDeviation =>
      getTheoreticalStandardDeviation(numberOfRows, probability);
}
