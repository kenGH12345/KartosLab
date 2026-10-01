import 'dart:ui' show Rect;

import 'balloon_model.dart';
import 'balloons_static_electricity_constants.dart';
import 'base_vec2.dart';
import 'force_utils.dart';
import 'point_charge_model.dart';

/// Wall model — PhET `WallModel.ts`.
class WallModel {
  WallModel({
    required this.yellowBalloon,
    required this.greenBalloon,
  }) {
    _buildCharges();
  }

  final BalloonModel yellowBalloon;
  final BalloonModel greenBalloon;

  bool isVisible = true;

  final double y = 0;
  final double x = BaseConstants.wallX;
  final double width = BaseConstants.wallWidth;
  final double height = BaseConstants.height;

  final int numX = BaseConstants.wallNumX;
  final int numY = BaseConstants.wallNumY;

  late final Rect bounds = Rect.fromLTRB(x, y, x + width, y + height);

  late final double dx = (width / numX + 2).roundToDouble();
  late final double dy = height / numY;

  final List<PointChargeModel> plusCharges = [];
  final List<MovablePointChargeModel> minusCharges = [];

  void _buildCharges() {
    for (var i = 0; i < numX; i++) {
      for (var k = 0; k < numY; k++) {
        final position = _calculatePosition(i, k);
        plusCharges.add(PointChargeModel(x + position.$1, position.$2));
        minusCharges.add(MovablePointChargeModel(
          x + position.$1 - PointChargeModel.radius,
          position.$2 - PointChargeModel.radius,
        ));
      }
    }
  }

  (double, double) _calculatePosition(int i, int k) {
    final y0 = i % 2 == 0 ? dy / 2 : 1.0;
    return (
      i * dx + PointChargeModel.radius + 1,
      k * dy + y0,
    );
  }

  /// Update minus charge positions from balloon forces (PhET Property.link body).
  void updateChargePositions() {
    const k = BaseConstants.coulombsLawConstant;

    for (final entry in minusCharges) {
      var dv1 = BaseVec2.zero;
      var dv2 = BaseVec2.zero;
      final defaultPosition = entry.initialPosition;

      if (yellowBalloon.isVisible) {
        dv1 = ForceUtils.getForce(
          defaultPosition,
          yellowBalloon
              .getChargeCenter()
              .minusXY(0, 2 * PointChargeModel.radius),
          k * PointChargeModel.charge * yellowBalloon.charge,
          power: 2.35,
        );
      }
      if (greenBalloon.isVisible) {
        dv2 = ForceUtils.getForce(
          defaultPosition,
          greenBalloon
              .getChargeCenter()
              .minusXY(0, 2 * PointChargeModel.radius),
          k * PointChargeModel.charge * greenBalloon.charge,
          power: 2.35,
        );
      }
      entry.setPosition(BaseVec2(
        defaultPosition.x + dv1.x + dv2.x,
        defaultPosition.y + dv1.y + dv2.y,
      ));
    }
  }

  MovablePointChargeModel getClosestChargeToBalloon(BalloonModel balloon) {
    MovablePointChargeModel? closestCharge;
    var chargeDistance = double.infinity;
    final balloonChargeCenter = balloon.getChargeCenter();

    for (final charge in minusCharges) {
      final newChargeDistance =
          charge.initialPosition.distance(balloonChargeCenter);
      if (newChargeDistance < chargeDistance) {
        chargeDistance = newChargeDistance;
        closestCharge = charge;
      }
    }
    return closestCharge!;
  }

  bool forceIndicatesInducedCharge(BaseVec2 force) =>
      force.magnitude > BaseConstants.forceMagnitudeThreshold;

  void setVisible(bool visible) {
    if (isVisible == visible) return;
    isVisible = visible;
    if (!visible) {
      for (final balloon in [yellowBalloon, greenBalloon]) {
        if (balloon.isVisible &&
            balloon.getCenterX() == BaseConstants.atWallCenterX &&
            balloon.isCharged()) {
          balloon.timeSinceRelease = 0;
        }
      }
    }
  }

  void reset() {
    isVisible = true;
    for (final entry in minusCharges) {
      entry.reset();
    }
  }
}
