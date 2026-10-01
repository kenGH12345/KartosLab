import 'dart:math' as math;

import '../collision_lab_constants.dart';
import '../solver/ball_utils.dart';
import 'ball.dart';
import 'ball_state.dart';
import 'center_of_mass.dart';
import 'cl_vec.dart';
import 'inelastic_preset.dart';
import 'play_area.dart';

/// Isolated system of Balls — `js/common/model/BallSystem.js` + screen subtypes.
class BallSystem {
  BallSystem({
    required List<BallState> initialBallStates,
    required this.playArea,
    this.minBalls = 1,
    this.maxBalls = 4,
    int defaultNumberOfBalls = 2,
    this.pathsVisibleInitially = false,
    this.supportsChangeInMomentum = false,
    this.supportsInelasticPreset = false,
  }) {
    assert(initialBallStates.length == maxBalls);
    assert(defaultNumberOfBalls >= minBalls && defaultNumberOfBalls <= maxBalls);

    prepopulatedBalls = [
      for (var i = 0; i < initialBallStates.length; i++)
        Ball(
          initialBallState: initialBallStates[i],
          playArea: playArea,
          isConstantSize: () => ballsConstantSize,
          index: i + 1,
        ),
    ];

    numberOfBalls = defaultNumberOfBalls;
    _defaultNumberOfBalls = defaultNumberOfBalls;
    pathsVisible = pathsVisibleInitially;
    _syncBallsToNumber();

    centerOfMass = CenterOfMass(balls: balls);

    if (supportsChangeInMomentum) {
      for (final ball in balls) {
        changeInMomentum[ball] = ClVec.zero;
      }
    }
  }

  factory BallSystem.intro(PlayArea playArea) => BallSystem(
        initialBallStates: introInitialBallStates,
        playArea: playArea,
        minBalls: 2,
        maxBalls: 2,
        defaultNumberOfBalls: 2,
        pathsVisibleInitially: false,
        supportsChangeInMomentum: true,
      );

  factory BallSystem.explore1d(PlayArea playArea) => BallSystem(
        initialBallStates: explore1dInitialBallStates,
        playArea: playArea,
        minBalls: 1,
        maxBalls: 5,
        defaultNumberOfBalls: 2,
        pathsVisibleInitially: false,
      );

  factory BallSystem.explore2d(PlayArea playArea) => BallSystem(
        initialBallStates: explore2dInitialBallStates,
        playArea: playArea,
        minBalls: 1,
        maxBalls: 4,
        defaultNumberOfBalls: 2,
        pathsVisibleInitially: false,
      );

  factory BallSystem.inelastic(PlayArea playArea) => BallSystem(
        initialBallStates: inelasticInitialBallStates,
        playArea: playArea,
        minBalls: 2,
        maxBalls: 2,
        defaultNumberOfBalls: 2,
        pathsVisibleInitially: false,
        supportsInelasticPreset: true,
      );

  // --- Default BallStates from PhET source ---

  static const introInitialBallStates = [
    BallState(position: ClVec(-1, 0), velocity: ClVec(1, 0), mass: 0.5),
    BallState(position: ClVec(1, 0), velocity: ClVec(-0.5, 0), mass: 1.5),
  ];

  static const explore1dInitialBallStates = [
    BallState(position: ClVec(-1.8, 0), velocity: ClVec(1, 0), mass: 0.5),
    BallState(position: ClVec(-0.1, 0), velocity: ClVec(-0.5, 0), mass: 1.5),
    BallState(position: ClVec(0.8, 0), velocity: ClVec(-0.5, 0), mass: 1.0),
    BallState(position: ClVec(1.3, 0), velocity: ClVec(1.10, 0), mass: 1.0),
    BallState(position: ClVec(1.8, 0), velocity: ClVec(-1.10, 0), mass: 1.0),
  ];

  static const explore2dInitialBallStates = [
    BallState(position: ClVec(-1.0, 0.000), velocity: ClVec(1.00, 0.300), mass: 0.50),
    BallState(position: ClVec(0.00, 0.500), velocity: ClVec(-0.5, -0.50), mass: 1.50),
    BallState(position: ClVec(-1.0, -0.50), velocity: ClVec(-0.25, -0.5), mass: 1.00),
    BallState(position: ClVec(0.20, -0.65), velocity: ClVec(1.10, 0.200), mass: 1.00),
  ];

  static const inelasticInitialBallStates = [
    BallState(position: ClVec(-1.0, 0.000), velocity: ClVec(1.00, 0.300), mass: 0.50),
    BallState(position: ClVec(0.00, 0.500), velocity: ClVec(-0.5, -0.50), mass: 1.50),
  ];

  final PlayArea playArea;
  final int minBalls;
  final int maxBalls;
  final bool pathsVisibleInitially;
  final bool supportsChangeInMomentum;
  final bool supportsInelasticPreset;

  late final List<Ball> prepopulatedBalls;
  late final CenterOfMass centerOfMass;

  late int _defaultNumberOfBalls;
  int numberOfBalls = 2;

  final List<Ball> balls = [];

  bool ballsConstantSize = false;
  bool pathsVisible = false;
  bool centerOfMassVisible = false;

  // --- Intro: Change in Momentum ---
  bool changeInMomentumVisible = false;
  double changeInMomentumOpacity = 0;
  ClVec? collisionPoint;
  double? collisionContactTime;
  final Map<Ball, ClVec> changeInMomentum = {};

  // --- Inelastic presets ---
  InelasticPreset inelasticPreset = InelasticPreset.custom;

  bool get ballSystemUserControlled => balls.any((b) => b.userControlled);

  bool get ballsNotInsidePlayArea =>
      balls.isNotEmpty && balls.every((b) => !b.insidePlayArea);

  double get totalKineticEnergy => BallUtils.kineticEnergyOf(
        balls.map((b) => (mass: b.mass, velocity: b.velocity)),
      );

  void setNumberOfBalls(int n) {
    final clamped = n.clamp(minBalls, maxBalls);
    if (clamped == numberOfBalls) return;
    numberOfBalls = clamped;
    _syncBallsToNumber();
  }

  void _syncBallsToNumber() {
    balls
      ..clear()
      ..addAll(prepopulatedBalls.take(numberOfBalls));
  }

  void stepUniformMotion(double dt, double elapsedTime) {
    for (final ball in balls) {
      ball.stepUniformMotion(dt);
    }
    updatePaths(elapsedTime);
  }

  void updatePaths(double elapsedTime) {
    for (final ball in balls) {
      ball.path.updatePath(elapsedTime, ball.position, pathsVisible);
    }
    centerOfMass.path
        .updatePath(elapsedTime, centerOfMass.position, pathsVisible);
  }

  void setPathsVisible(bool visible) {
    pathsVisible = visible;
    if (!visible) {
      for (final ball in prepopulatedBalls) {
        ball.path.clear();
      }
      centerOfMass.path.clear();
    }
  }

  void tryToSaveBallStates() {
    if (!ballSystemUserControlled && balls.every((b) => b.insidePlayArea)) {
      for (final ball in balls) {
        if (ball.insidePlayArea) ball.saveState();
        ball.path.clear();
        ball.rotation = 0;
      }
      centerOfMass.path.clear();
    }
  }

  /// L = Σ r × p relative to COM — InelasticBallSystem.js
  double getTotalAngularMomentum() {
    var total = 0.0;
    final comPos = centerOfMass.position;
    final comVel = centerOfMass.velocity;
    for (final ball in balls) {
      final r = ball.position - comPos;
      final p = (ball.velocity - comVel) * ball.mass;
      total += r.crossScalar(p);
    }
    return total;
  }

  /// Intro: register contact for Δp fade. IntroCollisionEngine.js
  void registerChangeInMomentumCollision(ClVec contactPoint, double contactTime) {
    if (!changeInMomentumVisible) return;
    collisionContactTime = contactTime;
    collisionPoint = contactPoint;
  }

  /// Record Δp when a ball's momentum changes (call from engine after collision).
  void recordMomentumChange(Ball ball, ClVec previousMomentum) {
    if (!supportsChangeInMomentum || !changeInMomentumVisible) return;
    if (ball.userControlled) return;
    changeInMomentum[ball] = ball.momentum - previousMomentum;
  }

  void updateChangeInMomentumOpacity(double elapsedTime) {
    if (!supportsChangeInMomentum) return;
    final contact = collisionContactTime;
    if (contact == null || !contact.isFinite) return;

    final timeSinceCollision = elapsedTime - contact;
    if (timeSinceCollision < 0) {
      clearChangeInMomentum();
      return;
    }
    const visible = CollisionLabConstants.changeInMomentumVisiblePeriod;
    const fade = CollisionLabConstants.changeInMomentumFadePeriod;
    if (timeSinceCollision <= visible) {
      changeInMomentumOpacity = 1;
    } else {
      final total = visible + fade;
      final t = timeSinceCollision.clamp(visible, total);
      // linear from 1→0 over [visible, total]
      changeInMomentumOpacity = 1 - (t - visible) / fade;
    }
  }

  void clearChangeInMomentum() {
    collisionPoint = null;
    changeInMomentumOpacity = 0;
    collisionContactTime = null;
    for (final ball in changeInMomentum.keys.toList()) {
      changeInMomentum[ball] = ClVec.zero;
    }
  }

  void applyInelasticPreset(InelasticPreset preset) {
    inelasticPreset = preset;
    preset.applyToBalls(balls);
  }

  /// Clamp ball into play area when reflecting border is on — BallSystem.js
  void bumpBallIntoPlayArea(Ball ball) {
    if (playArea.reflectingBorder) {
      ball.position = playArea.bounds
          .eroded(ball.radius)
          .closestPointTo(ball.position);
    }
    tryToSaveBallStates();
  }

  /// After user finishes controlling radius/position — BallSystem.bumpBallAwayFromOthers
  void bumpBallAwayFromOthers(Ball ball) {
    assert(balls.contains(ball));
    bumpBallIntoPlayArea(ball);

    var overlappingBall = BallUtils.getClosestOverlappingBall(ball, balls);
    final bumpedAwayFromBalls = <Ball>[];
    var count = 0;
    final random = math.Random();

    while (overlappingBall != null) {
      var directionVector = ball.position != overlappingBall.position
          ? (ball.position - overlappingBall.position).normalized()
          : ClVec.xUnit;

      directionVector = CollisionLabUtils.roundUpVectorToNearest(
        directionVector,
        math.pow(10, -CollisionLabConstants.displayDecimalPlaces).toDouble(),
      );

      if (bumpedAwayFromBalls.contains(overlappingBall)) {
        directionVector = directionVector * -1;
      }

      if (bumpedAwayFromBalls.length > 5) {
        if (ball.position.y == 0) {
          directionVector = ClVec(random.nextBool() ? 1.0 : -1.0, 0);
        } else {
          directionVector =
              ClVec.xUnit.rotated(2 * math.pi * random.nextDouble());
        }
      }

      BallUtils.moveBallNextToBall(ball, overlappingBall, directionVector);
      bumpBallIntoPlayArea(ball);

      bumpedAwayFromBalls.add(overlappingBall);
      overlappingBall = BallUtils.getClosestOverlappingBall(ball, balls);

      if (overlappingBall != null && ++count > 10) {
        repelBalls();
        overlappingBall = null;
      }
    }

    tryToSaveBallStates();
  }

  /// Pairwise slow separation — BallSystem.repelBalls
  void repelBalls() {
    var hadOverlap = true;
    final pairs = <(Ball, Ball)>[];
    for (var i = 0; i < balls.length - 1; i++) {
      for (var j = i + 1; j < balls.length; j++) {
        pairs.add((balls[i], balls[j]));
      }
    }

    while (hadOverlap) {
      hadOverlap = false;
      for (final pair in pairs) {
        final a = pair.$1;
        final b = pair.$2;
        if (!BallUtils.areBallsOverlappingBalls(a, b)) continue;
        hadOverlap = true;

        final directionVector = a.position != b.position
            ? (a.position - b.position).normalized()
            : ClVec.xUnit;

        var pair0 = a.position + directionVector * 0.05;
        var pair1 = b.position + directionVector * -0.05;

        if (playArea.reflectingBorder) {
          pair0 = a.playArea.bounds.eroded(a.radius).closestPointTo(pair0);
          pair1 = b.playArea.bounds.eroded(b.radius).closestPointTo(pair1);
        }
        a.position = pair0;
        b.position = pair1;
      }
    }
  }

  void reset() {
    ballsConstantSize = false;
    centerOfMassVisible = false;
    pathsVisible = pathsVisibleInitially;
    numberOfBalls = _defaultNumberOfBalls;
    _syncBallsToNumber();
    for (final ball in prepopulatedBalls) {
      ball.reset();
    }
    centerOfMass.reset();
    if (supportsChangeInMomentum) {
      changeInMomentumVisible = false;
      clearChangeInMomentum();
    }
    if (supportsInelasticPreset) {
      inelasticPreset = InelasticPreset.custom;
    }
  }

  void restart() {
    for (final ball in balls) {
      ball.restart();
    }
    centerOfMass.reset();
    if (supportsChangeInMomentum) {
      clearChangeInMomentum();
    }
  }
}
