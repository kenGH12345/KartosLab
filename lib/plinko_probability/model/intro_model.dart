import '../plinko_constants.dart';
import 'ball.dart';
import 'intro_ball.dart';
import 'plinko_common_model.dart';

/// Intro screen model — `IntroModel.js`.
class IntroModel extends PlinkoCommonModel {
  IntroModel({super.random}) {
    cylinderInfo = CylinderInfo.forRows(numberOfRows);
    hopperMode = HopperMode.ball; // Intro always ball
  }

  late CylinderInfo cylinderInfo;

  int launchedBallsNumber = 0;
  int ballsToCreateNumber = 0;

  @override
  void setNumberOfRows(int rows) {
    super.setNumberOfRows(rows);
    cylinderInfo = CylinderInfo.forRows(numberOfRows);
  }

  @override
  void setBallMode(BallMode mode) {
    if (ballMode == mode) return;
    super.setBallMode(mode);
    if (ballsToCreateNumber > 0) {
      ballsToCreateNumber = 0;
      isBallCapReached = launchedBallsNumber >= PlinkoConstants.maxBallsIntro;
      notifyChanged();
    }
  }

  /// Play button: enqueue balls based on ballMode.
  void play() {
    switch (ballMode) {
      case BallMode.oneBall:
        ballsToCreateNumber++;
      case BallMode.tenBalls:
        ballsToCreateNumber += 10;
      case BallMode.maxBalls:
        ballsToCreateNumber += PlinkoConstants.maxBallsIntro;
      case BallMode.continuous:
        break;
    }
    notifyChanged();
  }

  @override
  void erase() {
    super.erase();
    ballsToCreateNumber = 0;
    launchedBallsNumber = 0;
  }

  @override
  void step(double dt) {
    ballCreationTimeElapsed += dt;

    if (ballsToCreateNumber > 0 &&
        ballCreationTimeElapsed > PlinkoConstants.introBallCreationInterval &&
        launchedBallsNumber < PlinkoConstants.maxBallsIntro) {
      addNewBall();
    }

    var ballsMoved = false;
    final dtCapped = dt * PlinkoConstants.introDtCapFactor;
    final capped = dtCapped > PlinkoConstants.introDtCap
        ? PlinkoConstants.introDtCap
        : dtCapped;

    for (final ball in List<Ball>.from(balls)) {
      final moved = ball.step(capped);
      ballsMoved = moved || ballsMoved;
    }

    if (ballsMoved) {
      onBallsMoved?.call();
    }
  }

  void addNewBall() {
    final added = IntroBall(
      probability: probability,
      numberOfRows: numberOfRows,
      bins: histogram.bins,
      random: random,
      cylinderInfo: cylinderInfo,
    );

    launchedBallsNumber++;
    ballsToCreateNumber--;
    ballCreationTimeElapsed = 0;

    if (launchedBallsNumber + ballsToCreateNumber >=
        PlinkoConstants.maxBallsIntro) {
      isBallCapReached = true;
    }

    histogram.updateBinCountAndOrientation(added);
    balls.add(added);

    added.onHittingPeg = (direction) {
      onBallHittingPeg?.call(direction);
    };
    added.onOutOfPegs = () {
      histogram.addBallToHistogram(added);
    };

    notifyChanged();
  }
}
