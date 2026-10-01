import '../solver/intro_collision_engine.dart';
import 'ball_system.dart';
import 'collision_lab_model.dart';
import 'play_area.dart';

/// Intro screen model — `js/intro/model/IntroModel.js`
class IntroModel extends CollisionLabModel {
  @override
  PlayArea createPlayArea() => PlayArea.intro();

  @override
  BallSystem createBallSystem(PlayArea playArea) => BallSystem.intro(playArea);

  @override
  IntroCollisionEngine createCollisionEngine(
    PlayArea playArea,
    BallSystem ballSystem,
  ) {
    return IntroCollisionEngine(playArea, ballSystem);
  }
}
