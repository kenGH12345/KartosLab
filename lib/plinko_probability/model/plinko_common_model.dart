import '../plinko_constants.dart';
import 'ball.dart';
import 'galton_board.dart';
import 'histogram.dart';
import 'peg.dart';
import 'plinko_random.dart';

/// Ball dispense modes — `PlinkoProbabilityCommonModel` BALL_MODE_VALUES.
enum BallMode { oneBall, tenBalls, maxBalls, continuous }

/// What comes out of the hopper — HOPPER_MODE_VALUES.
enum HopperMode { ball, path, none }

/// Shared model — `PlinkoProbabilityCommonModel.js`.
abstract class PlinkoCommonModel {
  PlinkoCommonModel({PlinkoRandom? random})
      : random = random ?? PlinkoRandom() {
    galtonBoard = GaltonBoard(numberOfRows);
    histogram = Histogram(numberOfRows);
  }

  final PlinkoRandom random;

  double probability = PlinkoConstants.binaryProbabilityDefault;
  BallMode ballMode = BallMode.oneBall;
  HopperMode hopperMode = HopperMode.ball;
  bool isBallCapReached = false;
  int numberOfRows = PlinkoConstants.rowsDefault;

  double ballCreationTimeElapsed = 0;
  final List<Ball> balls = [];

  late GaltonBoard galtonBoard;
  late Histogram histogram;

  void Function()? onBallsMoved;
  void Function()? onChanged;
  void Function(PegDirection direction)? onBallHittingPeg;

  void notifyChanged() => onChanged?.call();

  void setProbability(double value) {
    final clamped = value.clamp(
      PlinkoConstants.binaryProbabilityMin,
      PlinkoConstants.binaryProbabilityMax,
    );
    if (probability == clamped) return;
    probability = clamped;
    erase();
    notifyChanged();
  }

  void setNumberOfRows(int rows) {
    final clamped = rows.clamp(PlinkoConstants.rowsMin, PlinkoConstants.rowsMax);
    if (numberOfRows == clamped) return;
    numberOfRows = clamped;
    galtonBoard.updateForRows(numberOfRows);
    histogram.numberOfRows = numberOfRows;
    erase();
    notifyChanged();
  }

  void setBallMode(BallMode mode) {
    if (ballMode == mode) return;
    ballMode = mode;
    notifyChanged();
  }

  void setHopperMode(HopperMode mode) {
    if (hopperMode == mode) return;
    hopperMode = mode;
    notifyChanged();
  }

  void reset() {
    probability = PlinkoConstants.binaryProbabilityDefault;
    ballMode = BallMode.oneBall;
    hopperMode = HopperMode.ball;
    isBallCapReached = false;
    numberOfRows = PlinkoConstants.rowsDefault;
    galtonBoard.updateForRows(numberOfRows);
    histogram.numberOfRows = numberOfRows;
    erase();
    notifyChanged();
  }

  void erase() {
    balls.clear();
    histogram.reset();
    isBallCapReached = false;
    onBallsMoved?.call();
    notifyChanged();
  }

  void step(double dt);
}
