import '../collision_lab_constants.dart';
import '../solver/collision_engine.dart';
import 'ball_system.dart';
import 'momenta_diagram.dart';
import 'play_area.dart';

enum TimeSpeed { normal, slow }

/// Abstract screen model — `js/common/model/CollisionLabModel.js`
abstract class CollisionLabModel {
  CollisionLabModel() {
    playArea = createPlayArea();
    ballSystem = createBallSystem(playArea);
    collisionEngine = createCollisionEngine(playArea, ballSystem);
    momentaDiagram = MomentaDiagram(
      prepopulatedBalls: ballSystem.prepopulatedBalls,
      balls: ballSystem.balls,
      dimension: playArea.dimension,
    );
  }

  bool isPlaying = false;
  double elapsedTime = 0;
  TimeSpeed timeSpeed = TimeSpeed.normal;

  late final PlayArea playArea;
  late final BallSystem ballSystem;
  late final CollisionEngine collisionEngine;
  late final MomentaDiagram momentaDiagram;

  PlayArea createPlayArea();
  BallSystem createBallSystem(PlayArea playArea);

  CollisionEngine createCollisionEngine(PlayArea playArea, BallSystem ballSystem) {
    return CollisionEngine(playArea, ballSystem);
  }

  void reset() {
    isPlaying = false;
    elapsedTime = 0;
    timeSpeed = TimeSpeed.normal;
    playArea.reset();
    ballSystem.reset();
    collisionEngine.reset();
    momentaDiagram.reset();
  }

  void restart() {
    isPlaying = false;
    elapsedTime = 0;
    ballSystem.restart();
    collisionEngine.reset();
  }

  void returnBalls() => restart();

  void step(double dt) {
    final factor = timeSpeed == TimeSpeed.normal
        ? CollisionLabConstants.normalSpeedFactor
        : CollisionLabConstants.slowSpeedFactor;
    if (isPlaying) {
      stepManual(dt * factor);
    }
  }

  void stepManual(double dt) {
    final previousElapsedTime = elapsedTime;
    elapsedTime += dt;
    if (elapsedTime < 0) elapsedTime = 0;
    collisionEngine.step(dt, previousElapsedTime);
    if (ballSystem.supportsChangeInMomentum) {
      ballSystem.updateChangeInMomentumOpacity(elapsedTime);
    }
    if (momentaDiagram.expanded) {
      momentaDiagram.updateVectors();
    }
  }

  void stepBackwards() {
    stepManual(
      -1 *
          (CollisionLabConstants.timeStepDuration < elapsedTime
              ? CollisionLabConstants.timeStepDuration
              : elapsedTime),
    );
  }

  void stepForwards() {
    stepManual(CollisionLabConstants.timeStepDuration);
  }
}
