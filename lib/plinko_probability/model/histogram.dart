import 'dart:math' as math;

import '../plinko_constants.dart';
import 'ball.dart';

/// Per-bin counters — `Histogram.js` binInfo.
class BinInfo {
  int binCount = 0;
  int visibleBinCount = 0;

  /// 0 center, 1 right, -1 left.
  int orientation = 0;
}

/// Experimental histogram + sample statistics — `Histogram.js`.
class Histogram {
  Histogram(this.numberOfRows) {
    setBinsToZero();
  }

  int numberOfRows;
  final List<BinInfo> bins = [];

  double average = 0;
  double standardDeviation = 0;
  double standardDeviationOfMean = 0;
  int landedBallsNumber = 0;

  double sumOfSquares = 0;
  double variance = 0;

  void Function()? onUpdated;

  int get binCount => numberOfRows + 1;

  void reset() {
    setBinsToZero();
    resetStatistics();
    onUpdated?.call();
  }

  void setBinsToZero() {
    bins
      ..clear()
      ..addAll(
        List.generate(
          PlinkoConstants.rowsMax + 1,
          (_) => BinInfo(),
        ),
      );
  }

  void updateBinCountAndOrientation(Ball ball) {
    bins[ball.binIndex].binCount++;
    bins[ball.binIndex].orientation = ball.binOrientation;
  }

  void updateStatistics(int binIndex) {
    landedBallsNumber++;
    final n = landedBallsNumber;

    average = ((n - 1) * average + binIndex) / n;
    sumOfSquares += binIndex * binIndex;

    if (n > 1) {
      variance = (sumOfSquares - n * average * average) / (n - 1);
      standardDeviation = math.sqrt(variance);
      standardDeviationOfMean = standardDeviation / math.sqrt(n);
    } else {
      variance = 0;
      standardDeviation = 0;
      standardDeviationOfMean = 0;
    }
  }

  void addBallToHistogram(Ball ball) {
    bins[ball.binIndex].visibleBinCount++;
    updateStatistics(ball.binIndex);
    onUpdated?.call();
  }

  int getBinCount(int binIndex) => bins[binIndex].visibleBinCount;

  double getFractionalBinCount(int binIndex) {
    if (landedBallsNumber > 0) {
      return bins[binIndex].visibleBinCount / landedBallsNumber;
    }
    return 0;
  }

  List<double> getNormalizedSampleDistribution() {
    final maxCount = getMaximumBinCount();
    final divisionFactor = math.max(maxCount, 1).toDouble();
    return [
      for (final bin in bins.take(binCount))
        bin.visibleBinCount / divisionFactor,
    ];
  }

  int getMaximumActualBinCount() {
    var maxCount = 0;
    for (final bin in bins) {
      maxCount = math.max(maxCount, bin.binCount);
    }
    return maxCount;
  }

  int getMaximumBinCount() {
    var maxCount = 0;
    for (final bin in bins.take(binCount)) {
      maxCount = math.max(maxCount, bin.visibleBinCount);
    }
    return maxCount;
  }

  double getBinCenterX(int binIndex, int numberOfBins) {
    assert(binIndex < numberOfBins);
    const boundsWidth =
        PlinkoConstants.histogramMaxX - PlinkoConstants.histogramMinX;
    return ((binIndex + 0.5) / numberOfBins) * boundsWidth +
        PlinkoConstants.histogramMinX;
  }

  double getBinLeft(int binIndex, int numberOfBins) {
    assert(binIndex < numberOfBins);
    const boundsWidth =
        PlinkoConstants.histogramMaxX - PlinkoConstants.histogramMinX;
    return (binIndex / numberOfBins) * boundsWidth +
        PlinkoConstants.histogramMinX;
  }

  void resetStatistics() {
    landedBallsNumber = 0;
    average = 0;
    sumOfSquares = 0;
    variance = 0;
    standardDeviation = 0;
    standardDeviationOfMean = 0;
  }

  void onNumberOfRowsChanged(int rows) {
    numberOfRows = rows;
    reset();
  }
}
