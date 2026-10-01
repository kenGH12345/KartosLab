import 'base_vec2.dart';
import 'balloons_static_electricity_constants.dart';

/// Fixed point charge — PhET `PointChargeModel`.
class PointChargeModel {
  PointChargeModel(double x, double y)
      : position = BaseVec2(x, y),
        initialPosition = BaseVec2(x, y);

  final BaseVec2 position;
  final BaseVec2 initialPosition;

  /// Whether this sweater minus charge has transferred to a balloon.
  bool moved = false;

  static double get radius => BaseConstants.pointChargeRadius;
  static double get charge => BaseConstants.pointCharge;

  BaseVec2 getCenter() =>
      BaseVec2(position.x + radius, position.y + radius);

  void reset() {
    moved = false;
  }
}

/// Movable wall minus charge — PhET `MovablePointChargeModel`.
class MovablePointChargeModel extends PointChargeModel {
  MovablePointChargeModel(super.x, super.y)
      : positionMutable = BaseVec2(x, y);

  BaseVec2 positionMutable;

  @override
  BaseVec2 get position => positionMutable;

  double getDisplacement() => positionMutable.distance(initialPosition);

  @override
  BaseVec2 getCenter() =>
      BaseVec2(positionMutable.x + PointChargeModel.radius,
          positionMutable.y + PointChargeModel.radius);

  @override
  void reset() {
    super.reset();
    positionMutable = initialPosition.copy();
  }

  void setPosition(BaseVec2 p) {
    positionMutable = p;
  }
}
