import '../plinko_constants.dart';
import 'ball.dart';

/// Lab ball — lands just below histogram top — `LabBall.js`.
class LabBall extends Ball {
  LabBall({
    required super.probability,
    required super.numberOfRows,
    required super.bins,
    required super.random,
  }) {
    finalBinVerticalOffset =
        PlinkoConstants.histogramMaxY - 6 * ballRadius;
  }
}
