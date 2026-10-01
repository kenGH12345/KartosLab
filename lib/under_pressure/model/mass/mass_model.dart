import 'dart:ui' show Offset, Rect;

import 'package:kratos/under_pressure/model/pool/chamber_pool_model.dart';

/// Source: `MassModel.js`
class MassModel {
  MassModel({
    required this.chamber,
    required this.mass,
    required double x,
    required double y,
    required this.width,
    required this.height,
  })  : position = Offset(x, y),
        _initialPosition = Offset(x, y);

  static const double frictionCoefficient = 0.98;
  static const double epsilonVelocity = 0.05;

  final ChamberPoolModel chamber;
  final double mass;
  final double width;
  final double height;
  final Offset _initialPosition;

  Offset position;
  bool isDragging = false;
  bool isFalling = false;
  double velocity = 0;

  void setDragging(bool dragging) {
    if (isDragging == dragging) return;
    isDragging = dragging;
    if (!isDragging) {
      if (isInTargetDroppedArea()) {
        chamber.pushToStack(this);
      } else if (cannotFall()) {
        reset();
      } else {
        isFalling = true;
      }
    } else {
      if (chamber.stack.contains(this)) {
        chamber.removeFromStack(this);
      }
    }
  }

  void step(double dt) {
    if (chamber.stack.contains(this)) {
      final m = chamber.stackMass;
      final rho = chamber.host.fluidDensity;
      final g = chamber.host.gravity;
      final h = chamber.leftDisplacement +
          chamber.leftDisplacement / chamber.lengthRatio;
      final gravityForce = -m * g;
      final pressureForce = rho * h * g;
      final force = gravityForce + pressureForce;
      final acceleration = force / m;
      velocity = (velocity + acceleration * dt) * frictionCoefficient;
      if (velocity.abs() > epsilonVelocity) {
        position = Offset(position.dx, position.dy + velocity * dt);
      }
    } else if (isFalling && !isDragging) {
      final acceleration = -chamber.host.gravity;
      velocity = velocity + acceleration * dt;
      if (velocity.abs() > epsilonVelocity) {
        position = Offset(position.dx, position.dy + velocity * dt);
        final floorY = chamber.maxY + height / 2;
        if (position.dy < floorY) {
          position = Offset(position.dx, floorY);
          isFalling = false;
          velocity = 0;
        }
      }
    }
  }

  bool isInTargetDroppedArea() {
    final waterLine = chamber.leftOpening.y2 +
        chamber.leftWaterHeight -
        chamber.leftDisplacement;
    final bottomLine =
        waterLine + chamber.stack.fold<double>(0, (a, b) => a + b.height);
    final massRect = Rect.fromLTRB(
      position.dx - width / 2,
      position.dy - height / 2,
      position.dx + width,
      position.dy + height,
    );
    final dropArea = Rect.fromLTRB(
      chamber.leftOpening.x1,
      bottomLine,
      chamber.leftOpening.x2,
      bottomLine + height,
    );
    return massRect.overlaps(dropArea);
  }

  bool cannotFall() {
    return position.dy < chamber.maxY - height / 2 || isMassOverOpening();
  }

  bool isMassOverOpening() {
    final left = position.dx;
    final right = position.dx + width / 2;
    final dims = chamber.poolDimensions;
    final lo = dims['leftOpening']!;
    final ro = dims['rightOpening']!;
    return (lo.x1 < left && left < lo.x2) ||
        (lo.x1 < right && right < lo.x2) ||
        (ro.x1 < left && left < ro.x2) ||
        (ro.x1 < right && right < ro.x2);
  }

  void reset() {
    position = _initialPosition;
    isDragging = false;
    isFalling = false;
    velocity = 0;
  }
}
