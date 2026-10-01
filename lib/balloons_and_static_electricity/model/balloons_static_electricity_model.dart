import 'package:flutter/foundation.dart';

import 'balloon_model.dart';
import 'balloons_static_electricity_constants.dart';
import 'base_vec2.dart';
import 'sweater_model.dart';
import 'wall_model.dart';

/// Main model container — PhET `BASEModel.ts`.
class BalloonsStaticElectricityModel extends ChangeNotifier {
  BalloonsStaticElectricityModel() {
    sweater = SweaterModel();

    yellowBalloon = BalloonModel(
      initialPosition: BaseConstants.yellowInitialPosition,
      defaultVisibility: true,
    );
    greenBalloon = BalloonModel(
      initialPosition: BaseConstants.greenInitialPosition,
      defaultVisibility: false,
    );

    yellowBalloon.other = greenBalloon;
    greenBalloon.other = yellowBalloon;
    balloons = [yellowBalloon, greenBalloon];

    wall = WallModel(
      yellowBalloon: yellowBalloon,
      greenBalloon: greenBalloon,
    );

    playAreaMaxX = BaseConstants.wallX;

    for (final balloon in balloons) {
      balloon.sweater = sweater;
      balloon.wallVisible = () => wall.isVisible;
      balloon.playAreaMaxX = () => playAreaMaxX;
      balloon.closestChargeInWallFinder = wall.getClosestChargeToBalloon;
      balloon.onStateChanged = _onBalloonStateChanged;
      balloon.closestChargeInWall =
          wall.getClosestChargeToBalloon(balloon);
    }

    reset();
  }

  late final SweaterModel sweater;
  late final BalloonModel yellowBalloon;
  late final BalloonModel greenBalloon;
  late final List<BalloonModel> balloons;
  late final WallModel wall;

  ShowCharges showCharges = ShowCharges.allCharges;
  bool balloonsAdjacent = false;
  double playAreaMaxX = BaseConstants.wallX;

  final List<void Function(double dt)> _stepListeners = [];

  void addStepListener(void Function(double dt) listener) =>
      _stepListeners.add(listener);

  void removeStepListener(void Function(double dt) listener) =>
      _stepListeners.remove(listener);

  void _onBalloonStateChanged() {
    _syncDerivedBalloonState();
    wall.updateChargePositions();
    notifyListeners();
  }

  void _syncDerivedBalloonState() {
    for (final balloon in balloons) {
      balloon.closestChargeInWall =
          wall.getClosestChargeToBalloon(balloon);
      balloon.touchingWall = balloon.computeTouchingWall();
      balloon.inducingCharge =
          balloon.inducingChargeForWall(wall.isVisible);
    }
    balloonsAdjacent = getBalloonsAdjacent();
  }

  /// Animation loop entry — PhET `BASEModel.step`.
  void step(double dtSeconds) {
    for (final balloon in balloons) {
      if (balloon.isVisible) {
        balloon.step(dtSeconds);
      }
    }
    wall.updateChargePositions();
    _syncDerivedBalloonState();
    for (final listener in _stepListeners) {
      listener(dtSeconds);
    }
    notifyListeners();
  }

  // --- Controls ---

  void setShowCharges(ShowCharges value) {
    if (showCharges == value) return;
    showCharges = value;
    notifyListeners();
  }

  void setTwoBalloons(bool two) {
    greenBalloon.isVisible = two;
    wall.updateChargePositions();
    _syncDerivedBalloonState();
    notifyListeners();
  }

  bool get twoBalloonsVisible => greenBalloon.isVisible;

  void setWallVisible(bool visible) {
    wall.setVisible(visible);
    playAreaMaxX =
        visible ? BaseConstants.wallX : BaseConstants.width;
    for (final balloon in balloons) {
      if (visible) {
        final clamped = balloon.clampToDragBoundsVec(balloon.position);
        if (clamped != balloon.position) {
          balloon.setPosition(clamped);
        }
      }
      balloon.touchingWall = balloon.computeTouchingWall();
      balloon.inducingCharge =
          balloon.inducingChargeForWall(wall.isVisible);
    }
    wall.updateChargePositions();
    notifyListeners();
  }

  void removeWall() => setWallVisible(false);
  void addWall() => setWallVisible(true);

  /// Drag balloon upper-left to [upperLeft].
  /// View is responsible for pointer − grabOffset (Scenery offset semantics).
  void dragBalloonTo(BalloonModel balloon, BaseVec2 upperLeft) {
    if (!balloon.isVisible) return;
    if (!balloon.userControlled) {
      balloon.beginDrag();
    }
    balloon.setPosition(upperLeft, clampToDragBounds: true);
  }

  void releaseBalloon(BalloonModel balloon) {
    if (balloon.userControlled) {
      balloon.endDrag();
    }
  }

  /// PhET ControlPanel `resetBalloonButtonListener`.
  void resetBalloons() {
    sweater.reset();
    for (final balloon in balloons) {
      balloon.reset(resetVisibility: false);
    }
    wall.updateChargePositions();
    _syncDerivedBalloonState();
    notifyListeners();
  }

  /// PhET `BASEModel.reset` / ResetAllButton.
  void reset() {
    showCharges = ShowCharges.allCharges;
    for (final balloon in balloons) {
      balloon.reset(resetVisibility: true);
    }
    sweater.reset();
    wall.reset();
    playAreaMaxX = BaseConstants.wallX;
    wall.updateChargePositions();
    _syncDerivedBalloonState();
    notifyListeners();
  }

  bool bothBalloonsVisible() =>
      greenBalloon.isVisible && yellowBalloon.isVisible;

  bool getBalloonsAdjacent() {
    final distance =
        yellowBalloon.getCenter().distance(greenBalloon.getCenter());
    return distance < BaseConstants.balloonWidth && bothBalloonsVisible();
  }
}
