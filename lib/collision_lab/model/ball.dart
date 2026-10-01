import '../collision_lab_constants.dart';
import '../solver/ball_utils.dart';
import 'ball_state.dart';
import 'cl_vec.dart';
import 'play_area.dart';

/// Trailing path point — `js/common/model/PathDataPoint.js`
class PathDataPoint {
  const PathDataPoint(this.time, this.position);
  final double time;
  final ClVec position;
}

/// Trailing path — `js/common/model/CollisionLabPath.js`
class CollisionLabPath {
  final List<PathDataPoint> dataPoints = [];

  void clear() => dataPoints.clear();

  /// No-op when [pathsVisible] is false (matches PhET).
  void updatePath(double elapsedTime, ClVec position, bool pathsVisible) {
    if (!pathsVisible) return;

    for (var i = 0; i < dataPoints.length; i++) {
      final p = dataPoints[i];
      if (p.time + CollisionLabConstants.pathPointLifetime <= elapsedTime ||
          p.time >= elapsedTime) {
        dataPoints.removeAt(i);
        i--;
      }
    }
    dataPoints.add(PathDataPoint(elapsedTime, position));
  }
}

/// Mutable Ball — `js/common/model/Ball.js`
class Ball {
  Ball({
    required BallState initialBallState,
    required this.playArea,
    required this.isConstantSize,
    required this.index,
  })  : _factoryState = initialBallState,
        position = initialBallState.position,
        velocity = initialBallState.velocity,
        mass = initialBallState.mass,
        restartState = initialBallState;

  final PlayArea playArea;

  /// 1-based index within the system.
  final int index;

  /// Reads BallSystem.ballsConstantSize.
  final bool Function() isConstantSize;

  /// Immutable factory defaults (reset-all).
  final BallState _factoryState;

  ClVec position;
  ClVec velocity;
  double mass;
  double rotation = 0;

  BallState restartState;

  final CollisionLabPath path = CollisionLabPath();

  bool massUserControlled = false;
  bool xPositionUserControlled = false;
  bool yPositionUserControlled = false;
  bool xVelocityUserControlled = false;
  bool yVelocityUserControlled = false;

  bool get userControlled =>
      massUserControlled ||
      xPositionUserControlled ||
      yPositionUserControlled ||
      xVelocityUserControlled ||
      yVelocityUserControlled;

  double get speed => velocity.magnitude;

  ClVec get momentum => velocity * mass;

  double get xMomentum => momentum.x;
  double get yMomentum => momentum.y;
  double get momentumMagnitude => momentum.magnitude;

  double get radius =>
      BallUtils.calculateBallRadius(mass, isConstantSize: isConstantSize());

  bool get insidePlayArea => playArea.containsAnyPartOf(this);

  double get left => position.x - radius;
  double get right => position.x + radius;
  double get top => position.y + radius;
  double get bottom => position.y - radius;

  void setXPosition(double x) => position = position.withX(x);
  void setYPosition(double y) => position = position.withY(y);

  void setXVelocity(double xVelocity) {
    velocity = velocity.withX(
      CollisionLabUtils.clampDown(xVelocity, CollisionLabConstants.minVelocity),
    );
  }

  void setYVelocity(double yVelocity) {
    velocity = velocity.withY(
      CollisionLabUtils.clampDown(yVelocity, CollisionLabConstants.minVelocity),
    );
  }

  void setState(BallState ballState) {
    position = ballState.position;
    velocity = ballState.velocity;
    mass = ballState.mass;
  }

  void saveState() {
    restartState = BallState(position: position, velocity: velocity, mass: mass);
  }

  void stepUniformMotion(double dt) {
    position = position + velocity * dt;
  }

  void dragToPosition(ClVec attempted) {
    ClVec corrected;
    if (!playArea.gridVisible) {
      corrected = playArea.bounds.eroded(radius).closestPointTo(attempted);
    } else {
      corrected = CollisionLabUtils.roundVectorToNearest(
        BallUtils.getBallGridSafeConstrainedBounds(playArea.bounds, radius)
            .closestPointTo(attempted),
        CollisionLabConstants.minorGridlineSpacing,
      );
    }
    if (playArea.dimension == PlayAreaDimension.one) {
      corrected = corrected.withY(0);
    }
    position = corrected;
  }

  void restart() {
    setState(restartState);
    path.clear();
    rotation = 0;
  }

  void reset() {
    setState(_factoryState);
    rotation = 0;
    path.clear();
    massUserControlled = false;
    xPositionUserControlled = false;
    yPositionUserControlled = false;
    xVelocityUserControlled = false;
    yVelocityUserControlled = false;
    saveState();
  }
}
