import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../pl_constants.dart';
import '../transform/pendulum_lab_transform.dart';
import 'pendulum.dart';
import 'pl_vector2.dart';

/// Drag math from `PendulaNode.js` SimpleDragHandler.
class PendulumDragLogic {
  PendulumDragLogic._();

  static const transform = PendulumLabTransform();

  /// `viewToModel(p).angle + π/2`
  static double dragAngle(Offset viewPoint) {
    return transform.viewToModel(viewPoint).angle + math.pi / 2;
  }

  /// Nearest degree; never ±180°. https://github.com/phetsims/pendulum-lab/issues/195
  static double roundedAngle(double continuousAngle) {
    final wrapped = Pendulum.modAngle(continuousAngle);
    var deg = PlConstants.roundSymmetric(PlConstants.toDegrees(wrapped));
    if (deg.abs() == 180) {
      deg = deg.sign * 179;
    }
    return PlConstants.toRadians(deg);
  }

  /// Distance from cursor to bob AABB in bob-local model meters.
  static double distanceToBob({
    required Offset viewPoint,
    required double angle,
    required double length,
    required double mass,
  }) {
    final cursor = transform.viewToModel(viewPoint);
    final rotated = cursor.rotated(-angle);
    final local = PlVector2(rotated.x, rotated.y + length);
    final scale = PlConstants.massToScale(mass);
    final w = transform.viewToModelDeltaX(PlConstants.bobRectWidth * scale);
    final h = transform.viewToModelDeltaX(PlConstants.bobRectHeight * scale);
    return minDistanceToAabb(local.x, local.y, w / 2, h / 2);
  }

  static double minDistanceToAabb(
    double x,
    double y,
    double halfW,
    double halfH,
  ) {
    final dx = math.max(x.abs() - halfW, 0.0);
    final dy = math.max(y.abs() - halfH, 0.0);
    return math.sqrt(dx * dx + dy * dy);
  }
}
