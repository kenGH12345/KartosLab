import 'ball_system.dart';
import 'collision_lab_model.dart';
import 'play_area.dart';

/// Explore 2D screen model — `js/explore2D/model/Explore2DModel.js`
/// Uses base [CollisionEngine].
class Explore2dModel extends CollisionLabModel {
  @override
  PlayArea createPlayArea() => PlayArea.explore2d();

  @override
  BallSystem createBallSystem(PlayArea playArea) =>
      BallSystem.explore2d(playArea);
}
