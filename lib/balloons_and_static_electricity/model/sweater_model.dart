import 'dart:math' as math;
import 'dart:ui' show Rect;

import 'balloon_model.dart';
import 'balloons_static_electricity_constants.dart';
import 'base_vec2.dart';
import 'charge_positions.dart';
import 'point_charge_model.dart';

/// Sweater model — PhET `SweaterModel.ts`.
///
/// Not draggable. Transfers minus charges to balloons via spatial sweep.
class SweaterModel {
  SweaterModel() {
    _buildCharges();
    chargedAreaVertices = _buildChargedAreaVertices();
    reset();
  }

  final double x = BaseConstants.sweaterPosition.x;
  final double y = BaseConstants.sweaterPosition.y;
  final double width = BaseConstants.sweaterWidth;
  final double height = BaseConstants.sweaterHeight;

  /// PhET `new Bounds2(x, y, width, height)` → (minX, minY, maxX, maxY).
  late final Rect bounds = Rect.fromLTRB(x, y, width, height);

  late final BaseVec2 center = BaseVec2(x + width / 2, y + height / 2);

  int charge = 0;

  final List<PointChargeModel> plusCharges = [];
  final List<PointChargeModel> minusCharges = [];

  /// Polygon outline of charge region (9-slice farthest-charge algorithm).
  late final List<BaseVec2> chargedAreaVertices;

  void _buildCharges() {
    for (final p in ChargePositions.sweaterChargePairPositions) {
      plusCharges.add(PointChargeModel(p.x, p.y));
      minusCharges.add(PointChargeModel(
        p.x + PointChargeModel.radius,
        p.y + PointChargeModel.radius,
      ));
    }
  }

  /// PhET SweaterModel chargedArea construction (numSlices = 9).
  static List<BaseVec2> _buildChargedAreaVertices() {
    final center = BaseVec2(
      BaseConstants.sweaterPosition.x + BaseConstants.sweaterWidth / 2,
      BaseConstants.sweaterPosition.y + BaseConstants.sweaterHeight / 2,
    );
    const numSlices = 9;
    final sliceWidth = (2 * math.pi) / numSlices;
    final shapeDefiningPoints =
        List<BaseVec2>.generate(numSlices, (_) => center.copy());

    for (var sliceNumber = 0; sliceNumber < numSlices; sliceNumber++) {
      final sliceMin = sliceNumber * sliceWidth;
      final sliceMax = (sliceNumber + 1) * sliceWidth;
      for (final chargePairPosition
          in ChargePositions.sweaterChargePairPositions) {
        var angle = math.atan2(
          chargePairPosition.y - center.y,
          chargePairPosition.x - center.x,
        );
        if (angle < 0) {
          angle += 2 * math.pi;
        }
        // PhET Range.contains: min <= value <= max
        if (angle >= sliceMin && angle <= sliceMax) {
          if (shapeDefiningPoints[sliceNumber] == center ||
              chargePairPosition.distance(center) >
                  shapeDefiningPoints[sliceNumber].distance(center)) {
            shapeDefiningPoints[sliceNumber] = chargePairPosition;
          }
        }
      }
    }
    return shapeDefiningPoints;
  }

  /// Point-in-polygon for chargedArea (ray casting).
  bool chargedAreaContainsPoint(BaseVec2 point) {
    final n = chargedAreaVertices.length;
    if (n < 3) return false;
    var inside = false;
    for (var i = 0, j = n - 1; i < n; j = i++) {
      final pi = chargedAreaVertices[i];
      final pj = chargedAreaVertices[j];
      final intersect = ((pi.y > point.y) != (pj.y > point.y)) &&
          (point.x <
              (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  bool boundsContainsPoint(BaseVec2 p) =>
      p.x >= bounds.left &&
      p.x <= bounds.right &&
      p.y >= bounds.top &&
      p.y <= bounds.bottom;

  bool intersectsBalloonBounds(Rect balloonBounds) =>
      bounds.overlaps(balloonBounds);

  /// Transfer sweater minus charges into [balloon] when swept.
  bool checkAndTransferCharges(BalloonModel balloon) {
    var chargeMoved = false;
    for (final minusCharge in minusCharges) {
      if (!minusCharge.moved &&
          _rectContains(balloon.bounds, minusCharge.position)) {
        moveChargeTo(minusCharge, balloon);
        chargeMoved = true;
      }
    }
    return chargeMoved;
  }

  static bool _rectContains(Rect r, BaseVec2 p) =>
      p.x >= r.left && p.x <= r.right && p.y >= r.top && p.y <= r.bottom;

  void moveChargeTo(PointChargeModel chargeSlot, BalloonModel balloon) {
    chargeSlot.moved = true;
    balloon.charge = balloon.charge - 1;
    charge = charge + 1;
  }

  void reset() {
    for (final entry in minusCharges) {
      entry.moved = false;
    }
    charge = 0;
  }
}
