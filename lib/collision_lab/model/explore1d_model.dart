import '../solver/explore1d_collision_engine.dart';
import 'ball_system.dart';
import 'collision_lab_model.dart';
import 'play_area.dart';

/// Explore 1D screen model — `js/explore1D/model/Explore1DModel.js`
class Explore1dModel extends CollisionLabModel {
  @override
  PlayArea createPlayArea() => PlayArea.explore1d();

  @override
  BallSystem createBallSystem(PlayArea playArea) =>
      BallSystem.explore1d(playArea);

  @override
  Explore1dCollisionEngine createCollisionEngine(
    PlayArea playArea,
    BallSystem ballSystem,
  ) {
    return Explore1dCollisionEngine(playArea, ballSystem);
  }
}
