import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../collision_lab_constants.dart';
import '../model/cl_vec.dart';
import '../model/collision_lab_model.dart';
import '../model/inelastic_preset.dart';
import '../model/play_area.dart';
import '../solver/ball_utils.dart';
import 'view_properties.dart';

/// Shared controller for Collision Lab screens.
abstract class CollisionLabController extends ChangeNotifier {
  CollisionLabController(this.model);

  final CollisionLabModel model;
  final ViewProperties view = ViewProperties();

  int? draggingBallIndex;
  int? draggingVelocityTipIndex;

  /// PhET CollisionLabModel: remember play state across user-control pause.
  bool? _wasPlayingBeforeUserControl;

  bool get canStepBackward =>
      !model.isPlaying &&
      model.playArea.elasticityPercent == 100 &&
      model.elapsedTime > 0;

  bool get showReturnBalls => model.ballSystem.ballsNotInsidePlayArea;

  bool get velocityTipsInteractive =>
      !model.isPlaying && view.velocityVectorVisible;

  void tick(double dt) {
    if (!model.isPlaying) return;
    model.step(dt);
    notifyListeners();
  }

  void playPause() {
    model.isPlaying = !model.isPlaying;
    notifyListeners();
  }

  void stepForward() {
    if (model.isPlaying) return;
    model.stepForwards();
    notifyListeners();
  }

  void stepBackward() {
    if (!canStepBackward) return;
    model.stepBackwards();
    notifyListeners();
  }

  void setTimeSpeed(TimeSpeed speed) {
    model.timeSpeed = speed;
    notifyListeners();
  }

  void reset() {
    model.reset();
    view.reset();
    draggingBallIndex = null;
    draggingVelocityTipIndex = null;
    _wasPlayingBeforeUserControl = null;
    notifyListeners();
  }

  void restart() {
    model.restart();
    draggingBallIndex = null;
    draggingVelocityTipIndex = null;
    _wasPlayingBeforeUserControl = null;
    notifyListeners();
  }

  void returnBalls() {
    model.returnBalls();
    draggingBallIndex = null;
    draggingVelocityTipIndex = null;
    notifyListeners();
  }

  void _beginUserControl() {
    if (_wasPlayingBeforeUserControl != null) return;
    _wasPlayingBeforeUserControl = model.isPlaying;
    model.isPlaying = false;
    model.elapsedTime = 0;
  }

  void _endUserControl() {
    final restore = _wasPlayingBeforeUserControl;
    _wasPlayingBeforeUserControl = null;
    if (restore != null) {
      model.isPlaying = restore;
    }
  }

  void dragBall(int index, ClVec modelPos) {
    final balls = model.ballSystem.balls;
    if (index < 0 || index >= balls.length) return;
    if (draggingBallIndex == null) _beginUserControl();
    draggingBallIndex = index;
    final ball = balls[index];
    ball.xPositionUserControlled = true;
    ball.yPositionUserControlled = true;
    ball.dragToPosition(modelPos);
    notifyListeners();
  }

  /// BallNode.js end: round position, bumpAway, clear userControlled.
  void endDrag() {
    final index = draggingBallIndex;
    draggingBallIndex = null;
    if (index != null &&
        index >= 0 &&
        index < model.ballSystem.balls.length) {
      final ball = model.ballSystem.balls[index];
      final multiple =
          math.pow(10, -CollisionLabConstants.displayDecimalPlaces).toDouble();
      final constrained = BallUtils.getBallGridSafeConstrainedBounds(
        ball.playArea.bounds,
        ball.radius,
        gridLineSpacing: multiple,
      );
      ball.position = CollisionLabUtils.roundVectorToNearest(
        constrained.closestPointTo(ball.position),
        multiple,
      );
      if (ball.playArea.dimension == PlayAreaDimension.one) {
        ball.position = ball.position.withY(0);
      }
      model.ballSystem.bumpBallAwayFromOthers(ball);
      ball.xPositionUserControlled = false;
      ball.yPositionUserControlled = false;
    } else {
      for (final ball in model.ballSystem.balls) {
        ball.xPositionUserControlled = false;
        ball.yPositionUserControlled = false;
      }
    }
    _endUserControl();
    notifyListeners();
  }

  /// BallVelocityVectorNode tip drag start.
  void beginVelocityTipDrag(int index) {
    final balls = model.ballSystem.balls;
    if (index < 0 || index >= balls.length) return;
    if (!velocityTipsInteractive) return;
    _beginUserControl();
    draggingVelocityTipIndex = index;
    final ball = balls[index];
    ball.xVelocityUserControlled = true;
    if (model.playArea.dimension == PlayAreaDimension.two) {
      ball.yVelocityUserControlled = true;
    }
    notifyListeners();
  }

  /// Tip drag: view delta from ball center → model velocity, clamp to VELOCITY_RANGE.
  /// Position is NOT changed. Mapping via [viewToModelDelta] (not pixel guessing).
  void dragVelocityTip(int index, ClVec velocityFromViewDelta) {
    final balls = model.ballSystem.balls;
    if (index < 0 || index >= balls.length) return;
    if (draggingVelocityTipIndex != index) return;

    final clamped = ClVec(
      velocityFromViewDelta.x.clamp(
        CollisionLabConstants.velocityMin,
        CollisionLabConstants.velocityMax,
      ),
      velocityFromViewDelta.y.clamp(
        CollisionLabConstants.velocityMin,
        CollisionLabConstants.velocityMax,
      ),
    );

    final ball = balls[index];
    ball.setXVelocity(clamped.x);
    if (model.playArea.dimension == PlayAreaDimension.two) {
      ball.setYVelocity(clamped.y);
    } else {
      ball.setYVelocity(0);
    }
    notifyListeners();
  }

  /// Tip drag end: round to display decimals.
  void endVelocityTipDrag() {
    final index = draggingVelocityTipIndex;
    draggingVelocityTipIndex = null;
    if (index != null &&
        index >= 0 &&
        index < model.ballSystem.balls.length) {
      final ball = model.ballSystem.balls[index];
      final multiple =
          math.pow(10, -CollisionLabConstants.displayDecimalPlaces).toDouble();
      ball.velocity =
          CollisionLabUtils.roundVectorToNearest(ball.velocity, multiple);
      if (model.playArea.dimension == PlayAreaDimension.one) {
        ball.velocity = ball.velocity.withY(0);
      }
      ball.xVelocityUserControlled = false;
      ball.yVelocityUserControlled = false;
      model.ballSystem.tryToSaveBallStates();
    }
    _endUserControl();
    notifyListeners();
  }

  void setMass(int index, double mass) {
    final balls = model.ballSystem.balls;
    if (index < 0 || index >= balls.length) return;
    _beginUserControl();
    balls[index].mass = mass.clamp(
      CollisionLabConstants.massMin,
      CollisionLabConstants.massMax,
    );
    model.ballSystem.bumpBallAwayFromOthers(balls[index]);
    _endUserControl();
    notifyListeners();
  }

  void setVelocity(int index, ClVec velocity) {
    final balls = model.ballSystem.balls;
    if (index < 0 || index >= balls.length) return;
    _beginUserControl();
    final ball = balls[index];
    ball.setXVelocity(velocity.x.clamp(
      CollisionLabConstants.velocityMin,
      CollisionLabConstants.velocityMax,
    ));
    if (model.playArea.dimension == PlayAreaDimension.two) {
      ball.setYVelocity(velocity.y.clamp(
        CollisionLabConstants.velocityMin,
        CollisionLabConstants.velocityMax,
      ));
    } else {
      ball.setYVelocity(0);
    }
    model.ballSystem.tryToSaveBallStates();
    _endUserControl();
    notifyListeners();
  }

  void setPosition(int index, ClVec position) {
    final balls = model.ballSystem.balls;
    if (index < 0 || index >= balls.length) return;
    _beginUserControl();
    balls[index].dragToPosition(position);
    model.ballSystem.bumpBallAwayFromOthers(balls[index]);
    _endUserControl();
    notifyListeners();
  }

  void setElasticity(double percent) {
    model.playArea.setElasticityPercent(percent);
    model.elapsedTime = 0;
    notifyListeners();
  }

  void setReflectingBorder(bool v) {
    model.playArea.reflectingBorder = v;
    notifyListeners();
  }

  void setGridVisible(bool v) {
    if (!model.playArea.gridCheckboxEnabled) return;
    model.playArea.gridVisible = v;
    notifyListeners();
  }

  void setConstantSize(bool v) {
    model.ballSystem.ballsConstantSize = v;
    model.elapsedTime = 0;
    notifyListeners();
  }

  void setVelocityVectors(bool v) {
    view.velocityVectorVisible = v;
    notifyListeners();
  }

  void setMomentumVectors(bool v) {
    view.momentumVectorVisible = v;
    notifyListeners();
  }

  void setCenterOfMass(bool v) {
    model.ballSystem.centerOfMassVisible = v;
    notifyListeners();
  }

  void setKineticEnergy(bool v) {
    view.kineticEnergyVisible = v;
    notifyListeners();
  }

  void setValues(bool v) {
    view.valuesVisible = v;
    notifyListeners();
  }

  void setMoreData(bool v) {
    view.moreDataVisible = v;
    notifyListeners();
  }

  void setPathsVisible(bool v) {
    model.ballSystem.setPathsVisible(v);
    notifyListeners();
  }

  void setChangeInMomentum(bool v) {
    if (!model.ballSystem.supportsChangeInMomentum) return;
    model.ballSystem.changeInMomentumVisible = v;
    if (!v) model.ballSystem.clearChangeInMomentum();
    notifyListeners();
  }

  void setNumberOfBalls(int n) {
    model.ballSystem.setNumberOfBalls(n);
    model.collisionEngine.reset();
    model.elapsedTime = 0;
    notifyListeners();
  }

  void setMomentaExpanded(bool v) {
    model.momentaDiagram.expanded = v;
    if (v) model.momentaDiagram.updateVectors();
    notifyListeners();
  }

  void zoomMomentaIn() {
    model.momentaDiagram.zoomIn();
    if (model.momentaDiagram.expanded) model.momentaDiagram.updateVectors();
    notifyListeners();
  }

  void zoomMomentaOut() {
    model.momentaDiagram.zoomOut();
    if (model.momentaDiagram.expanded) model.momentaDiagram.updateVectors();
    notifyListeners();
  }

  void setPreset(InelasticPreset preset) {
    model.ballSystem.applyInelasticPreset(preset);
    model.collisionEngine.reset();
    notifyListeners();
  }

  void setStickSlip(InelasticCollisionType type) {
    model.playArea.inelasticCollisionType = type;
    model.collisionEngine.reset();
    notifyListeners();
  }
}
