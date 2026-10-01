import 'ball.dart';
import 'ball_state.dart';
import 'cl_vec.dart';

/// Presets for Inelastic screen — `js/inelastic/model/InelasticPreset.js`
enum InelasticPreset {
  custom,
  crissCross,
  headOn,
  glancing;

  List<BallState>? get ballStates {
    switch (this) {
      case InelasticPreset.custom:
        return null;
      case InelasticPreset.crissCross:
        return const [
          BallState(
            position: ClVec(-0.5, 0.00),
            velocity: ClVec(1.00, 0.5),
            mass: 0.50,
          ),
          BallState(
            position: ClVec(0.50, 0.00),
            velocity: ClVec(-1.0, 0.5),
            mass: 0.50,
          ),
        ];
      case InelasticPreset.headOn:
        return const [
          BallState(
            position: ClVec(-0.5, 0.00),
            velocity: ClVec(0.50, 0),
            mass: 0.5,
          ),
          BallState(
            position: ClVec(0.50, 0.00),
            velocity: ClVec(-0.5, 0),
            mass: 0.5,
          ),
        ];
      case InelasticPreset.glancing:
        return const [
          BallState(
            position: ClVec(-0.65, 0.00),
            velocity: ClVec(0, 0),
            mass: 1.8,
          ),
          BallState(
            position: ClVec(0.6, 0.12),
            velocity: ClVec(-1, 0),
            mass: 0.3,
          ),
        ];
    }
  }

  /// Apply preset states to [balls] (no-op for [custom]).
  void applyToBalls(List<Ball> balls) {
    final states = ballStates;
    if (states == null) return;
    assert(states.length == balls.length);
    for (var i = 0; i < balls.length; i++) {
      final ball = balls[i];
      ball.setState(states[i]);
      ball.path.clear();
      ball.rotation = 0;
      ball.saveState();
    }
  }
}
