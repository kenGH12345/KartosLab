import 'dart:math' as math;
import 'dart:ui' show Rect;

import 'balloons_static_electricity_constants.dart';
import 'base_vec2.dart';
import 'charge_positions.dart';
import 'force_utils.dart';
import 'point_charge_model.dart';
import 'sweater_model.dart';

/// Balloon model — PhET `BalloonModel.ts`.
class BalloonModel {
  BalloonModel({
    required this.initialPosition,
    required this.defaultVisibility,
  }) {
    position = initialPosition.copy();
    oldPosition = position.copy();
    _buildCharges();
    _updateBounds();
    reset(resetVisibility: true);
  }

  final BaseVec2 initialPosition;
  final bool defaultVisibility;

  late BalloonModel other;
  late SweaterModel sweater;
  bool Function() wallVisible = () => true;
  double Function() playAreaMaxX = () => BaseConstants.wallX;
  MovablePointChargeModel? Function(BalloonModel balloon)
      closestChargeInWallFinder = (_) => null;
  void Function() onStateChanged = () {};

  // --- Observable state ---
  late BaseVec2 position;
  BaseVec2 velocity = BaseVec2.zero;
  BaseVec2 dragVelocity = BaseVec2.zero;
  int charge = 0;
  late bool isVisible;
  bool userControlled = false;
  bool draggingWithPointer = false;
  bool onSweater = false;
  bool touchingWall = false;
  bool inducingCharge = false;
  String? direction;
  late BaseVec2 oldPosition;
  double timeSinceRelease = 0;
  bool jumping = false;
  bool successfulPickUp = false;
  MovablePointChargeModel? closestChargeInWall;

  late Rect bounds;

  final List<PointChargeModel> plusCharges = [];
  final List<PointChargeModel> minusCharges = [];

  // Rolling velocity buffers for charge pickup.
  final List<double> _xVelocityArray =
      List<double>.filled(BaseConstants.velocityArrayLength, 0);
  final List<double> _yVelocityArray =
      List<double>.filled(BaseConstants.velocityArrayLength, 0);
  int _xVelocityCounter = 0;
  int _yVelocityCounter = 0;

  void _buildCharges() {
    for (final entry in ChargePositions.balloonStartChargePositions) {
      plusCharges.add(PointChargeModel(entry.x, entry.y));
      minusCharges.add(PointChargeModel(
        entry.x + PointChargeModel.radius,
        entry.y + PointChargeModel.radius,
      ));
    }
    for (final entry in ChargePositions.balloonCollectedMinusChargePositions) {
      minusCharges.add(PointChargeModel(entry.x, entry.y));
    }
  }

  void _updateBounds() {
    bounds = Rect.fromLTRB(
      position.x,
      position.y,
      position.x + BaseConstants.balloonWidth,
      position.y + BaseConstants.balloonHeight,
    );
  }

  BaseVec2 getCenter() => BaseVec2(
        position.x + BaseConstants.balloonWidth / 2,
        position.y + BaseConstants.balloonHeight / 2,
      );

  double getCenterX() => position.x + BaseConstants.balloonWidth / 2;
  double getCenterY() => position.y + BaseConstants.balloonHeight / 2;

  double getRight() => position.x + BaseConstants.balloonWidth;
  double getLeft() => position.x;

  BaseVec2 getChargeCenter() => BaseVec2(
        getCenter().x,
        position.y + ChargePositions.averageBalloonChargeY,
      );

  void setCenter(BaseVec2 center) {
    setPosition(BaseVec2(
      center.x - BaseConstants.balloonWidth / 2,
      center.y - BaseConstants.balloonHeight / 2,
    ));
  }

  /// Set upper-left position, optionally clamp to current drag bounds.
  void setPosition(BaseVec2 next, {bool clampToDragBounds = false}) {
    var p = next;
    if (clampToDragBounds) {
      p = clampToDragBoundsVec(p);
    }
    final previous = position;
    position = p;
    _updateBounds();
    _afterPositionChanged(previous);
    onStateChanged();
  }

  BaseVec2 clampToDragBoundsVec(BaseVec2 p) {
    final maxX = wallVisible()
        ? BaseConstants.dragMaxXWithWall
        : BaseConstants.dragMaxXWithoutWall;
    final maxY = BaseConstants.dragMaxY;
    return BaseVec2(
      p.x.clamp(0, maxX).toDouble(),
      p.y.clamp(0, maxY).toDouble(),
    );
  }

  Rect get dragBounds {
    final maxX = wallVisible()
        ? BaseConstants.dragMaxXWithWall
        : BaseConstants.dragMaxXWithoutWall;
    return Rect.fromLTRB(0, 0, maxX, BaseConstants.dragMaxY);
  }

  void _afterPositionChanged(BaseVec2? oldPos) {
    if (oldPos != null) {
      direction = directionBetween(position, oldPos);
      final nowOnSweater = computeOnSweater();
      if (nowOnSweater != onSweater) {
        onSweater = nowOnSweater;
      }
      final nowTouching = computeTouchingWall();
      if (nowTouching != touchingWall) {
        touchingWall = nowTouching;
      }
    }
    closestChargeInWall = closestChargeInWallFinder(this);
  }

  bool computeOnSweater() => sweater.intersectsBalloonBounds(bounds);

  bool centerInSweaterChargedArea() =>
      sweater.chargedAreaContainsPoint(getCenter());

  bool computeTouchingWall() {
    final atWall = getCenterX() == BaseConstants.atWallCenterX;
    return atWall && wallVisible();
  }

  bool isCharged() => charge < 0;

  bool inducingChargeAndVisible() => isVisible && inducingCharge;

  bool inducingChargeForWall(bool wallIsVisible) {
    if (closestChargeInWall == null) return false;
    final balloonForce = forceToClosestWallCharge(this);
    final forceLargeEnough =
        balloonForce.magnitude > BaseConstants.forceMagnitudeThreshold;
    return wallIsVisible && isVisible && forceLargeEnough;
  }

  /// Ellipse body + nub — PhET `BalloonNode` pointer area (local coords).
  bool hitTestLocal(BaseVec2 local) {
    final w = BaseConstants.balloonWidth;
    final h = BaseConstants.balloonHeight;
    final centerX = w / 2;
    final centerY = h / 2;
    final ex = centerX;
    final ey = centerY * 0.91;
    final rx = w * 0.51;
    final ry = h * 0.465;
    final dx = (local.x - ex) / rx;
    final dy = (local.y - ey) / ry;
    final inEllipse = dx * dx + dy * dy <= 1;
    final nubLeft = centerX - w * 0.05;
    final nubTop = h * 0.9;
    final nubRight = nubLeft + w * 0.1;
    final nubBottom = nubTop + h * 0.1;
    final inNub = local.x >= nubLeft &&
        local.x <= nubRight &&
        local.y >= nubTop &&
        local.y <= nubBottom;
    return inEllipse || inNub;
  }

  bool hitTestGlobal(BaseVec2 global) =>
      hitTestLocal(BaseVec2(global.x - position.x, global.y - position.y));

  void beginDrag() {
    userControlled = true;
    velocity = BaseVec2.zero;
    draggingWithPointer = true;
    onStateChanged();
  }

  void endDrag() {
    userControlled = false;
    velocity = BaseVec2.zero;
    dragVelocity = BaseVec2.zero;
    timeSinceRelease = 0;
    draggingWithPointer = false;
    onStateChanged();
  }

  /// Animation step — PhET `BalloonModel.step`.
  void step(double dtSeconds) {
    if (!isVisible) return;

    var dt = dtSeconds * BaseConstants.msScaleFactor;
    if (dt > 500) {
      dt = 1 / 60 * 1000;
    }

    if (userControlled) {
      dragBalloon(dt);
    } else {
      applyForce(dt);
      timeSinceRelease += dt;
    }
    oldPosition = position.copy();
  }

  /// During drag: compute speed and transfer charges. Returns if charge found.
  bool dragBalloon(double dt) {
    final vx = (position.x - oldPosition.x) / dt;
    final vy = (position.y - oldPosition.y) / dt;

    _xVelocityArray[_xVelocityCounter++] = vx * vx;
    _xVelocityCounter %= BaseConstants.velocityArrayLength;
    _yVelocityArray[_yVelocityCounter++] = vy * vy;
    _yVelocityCounter %= BaseConstants.velocityArrayLength;

    var averageX = 0.0;
    var averageY = 0.0;
    for (var i = 0; i < BaseConstants.velocityArrayLength; i++) {
      averageX += _xVelocityArray[i];
      averageY += _yVelocityArray[i];
    }
    averageX /= BaseConstants.velocityArrayLength;
    averageY /= BaseConstants.velocityArrayLength;

    final speed = math.sqrt(averageX * averageX + averageY * averageY);
    dragVelocity = BaseVec2(vx, vy);

    var chargeFound = false;
    if (speed > 0) {
      chargeFound = sweater.checkAndTransferCharges(this);
    }
    if (chargeFound) {
      onStateChanged();
    }
    return chargeFound;
  }

  BaseVec2 getSweaterForce() {
    return ForceUtils.getForce(
      sweater.center,
      getCenter(),
      -BaseConstants.forceConstant * sweater.charge * charge,
    );
  }

  BaseVec2 getOtherBalloonForce() {
    if (userControlled || !isVisible || !other.isVisible) {
      return BaseVec2.zero;
    }
    final kqq = BaseConstants.forceConstant * charge * other.charge;
    return ForceUtils.getForce(getCenter(), other.getCenter(), kqq);
  }

  BaseVec2 getTotalForce() {
    if (wallVisible()) {
      final distFromWall = BaseConstants.wallX - position.x;
      if (charge < -5) {
        final relDist = distFromWall - BaseConstants.balloonWidth;
        const fright = BaseConstants.wallAttractionFright;
        if (relDist <= 40 + charge / 8) {
          return BaseVec2(-fright * charge / 20.0, 0);
        }
      }
    }

    final force = getSweaterForce();
    final otherForce = getOtherBalloonForce();
    return ForceUtils.capMagnitude(
      force.plus(otherForce),
      BaseConstants.maxForceMagnitude,
    );
  }

  void applyForce(double dt) {
    if (!centerInSweaterChargedArea()) {
      final rightBound = playAreaMaxX();
      final force = getTotalForce();
      var newVelocity = velocity.plus(force.timesScalar(dt));
      var newPosition = position.plus(velocity.timesScalar(dt));

      if (newPosition.x + BaseConstants.balloonWidth >= rightBound) {
        newPosition = BaseVec2(
          rightBound - BaseConstants.balloonWidth,
          newPosition.y,
        );
        if (newVelocity.x > 0) {
          newVelocity = BaseVec2(0, newVelocity.y);
          if (touchingWall) {
            newVelocity = BaseVec2.zero;
          }
        }
      }
      if (newPosition.y + BaseConstants.balloonHeight >=
          BaseConstants.height) {
        newPosition = BaseVec2(
          newPosition.x,
          BaseConstants.height - BaseConstants.balloonHeight,
        );
        if (newVelocity.y > 0) {
          newVelocity = BaseVec2(newVelocity.x, 0);
        }
      }
      if (newPosition.x <= 0) {
        newPosition = BaseVec2(0, newPosition.y);
        if (newVelocity.x < 0) {
          newVelocity = BaseVec2(0, newVelocity.y);
        }
      }
      if (newPosition.y <= 0) {
        newPosition = BaseVec2(newPosition.x, 0);
        if (newVelocity.y < 0) {
          newVelocity = BaseVec2(newVelocity.x, 0);
        }
      }

      final previous = position;
      position = newPosition;
      _updateBounds();
      _afterPositionChanged(previous);
      velocity = newVelocity;
      onStateChanged();
    } else {
      velocity = BaseVec2.zero;
    }
  }

  /// [notResetVisibility] matches PhET `reset(notResetVisibility)`.
  void reset({bool resetVisibility = true}) {
    _xVelocityArray.fillRange(0, _xVelocityArray.length, 0);
    _yVelocityArray.fillRange(0, _yVelocityArray.length, 0);
    _xVelocityCounter = 0;
    _yVelocityCounter = 0;

    charge = 0;
    velocity = BaseVec2.zero;
    dragVelocity = BaseVec2.zero;
    position = initialPosition.copy();
    oldPosition = position.copy();
    direction = null;
    if (resetVisibility) {
      isVisible = defaultVisibility;
    }
    userControlled = false;
    draggingWithPointer = false;
    successfulPickUp = false;
    timeSinceRelease = 0;
    onSweater = false;
    touchingWall = false;
    inducingCharge = false;
    _updateBounds();
    onStateChanged();
  }

  static BaseVec2 forceToClosestWallCharge(BalloonModel balloon) {
    final closest = balloon.closestChargeInWall!;
    return ForceUtils.getForce(
      closest.position,
      balloon.getCenter(),
      BaseConstants.coulombsLawConstant *
          balloon.charge *
          PointChargeModel.charge,
      power: 2.35,
    );
  }

  /// Approximate PhET `BalloonModel.getDirection` (axis buckets for a11y).
  static String? directionBetween(BaseVec2 pointA, BaseVec2 pointB) {
    final dx = pointA.x - pointB.x;
    final dy = pointA.y - pointB.y;
    if (dx == 0 && dy == 0) return null;
    final angle = math.atan2(dy, dx);
    // Map to 8 directions similar to MovementAlerter.
    const pi = math.pi;
    if (angle > -pi / 8 && angle <= pi / 8) return 'RIGHT';
    if (angle > pi / 8 && angle <= 3 * pi / 8) return 'DOWN_RIGHT';
    if (angle > 3 * pi / 8 && angle <= 5 * pi / 8) return 'DOWN';
    if (angle > 5 * pi / 8 && angle <= 7 * pi / 8) return 'DOWN_LEFT';
    if (angle > 7 * pi / 8 || angle <= -7 * pi / 8) return 'LEFT';
    if (angle > -7 * pi / 8 && angle <= -5 * pi / 8) return 'UP_LEFT';
    if (angle > -5 * pi / 8 && angle <= -3 * pi / 8) return 'UP';
    return 'UP_RIGHT';
  }
}
