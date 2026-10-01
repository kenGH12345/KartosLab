import '../solver/inelastic_collision_engine.dart';
import 'ball_system.dart';
import 'collision_lab_model.dart';
import 'play_area.dart';

/// Inelastic screen model — `js/inelastic/model/InelasticModel.js`
class InelasticModel extends CollisionLabModel {
  @override
  PlayArea createPlayArea() => PlayArea.inelastic();

  @override
  BallSystem createBallSystem(PlayArea playArea) =>
      BallSystem.inelastic(playArea);

  @override
  InelasticCollisionEngine createCollisionEngine(
    PlayArea playArea,
    BallSystem ballSystem,
  ) {
    return InelasticCollisionEngine(playArea, ballSystem);
  }

  @override
  void reset() {
    super.reset();
    collisionEngine.reset();
  }

  @override
  void restart() {
    super.restart();
    collisionEngine.reset();
  }
}
