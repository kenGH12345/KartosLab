import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/arm.dart';
import '../model/electron.dart';
import '../model/jt_vec2.dart';
import '../model/leg.dart';

/// Electron screen mapping — port of PhET `ElectronNode.js` history / appendage logic.
abstract final class ElectronScreenMapper {
  /// Leg region AABB from ElectronNode.js.
  static final Rect legBounds = Rect.fromLTWH(
    368.70275791624107,
    332.0122574055158,
    600,
    600,
  );

  /// Arm region AABB (updated bounds in ElectronNode.js).
  static final Rect armBounds = Rect.fromLTRB(
    427.83601359003404,
    154.03488108720273,
    558.1263873159684,
    294.67542468856175,
  );

  /// Updates [electron.history] and returns ScreenView position for drawing.
  static JtVec2 mapScreenPosition({
    required Electron electron,
    required Leg leg,
    required Arm arm,
  }) {
    final position = electron.position;

    final region = legBounds.contains(Offset(position.x, position.y))
        ? ElectronHistory.leg
        : armBounds.contains(Offset(position.x, position.y))
            ? ElectronHistory.arm
            : ElectronHistory.body;

    electron.history.add(region);
    if (electron.history.length > 10) {
      electron.history.removeAt(0);
    }

    var inLegCount = 0;
    var inBodyCount = 0;
    var inArmCount = 0;
    for (final element in electron.history) {
      if (element == ElectronHistory.leg) {
        inLegCount++;
      } else if (element == ElectronHistory.arm) {
        inArmCount++;
      } else {
        inBodyCount++;
      }
    }

    if (inBodyCount == electron.history.length) {
      return position;
    }

    if (inLegCount >= inArmCount) {
      final legPoint = leg.position;
      var dr = JtVec2(position.x - legPoint.x, position.y - legPoint.y);
      final deltaAngle = leg.deltaAngle();
      dr = dr.rotated(deltaAngle).plus(legPoint);

      if (inLegCount == electron.history.length) {
        return dr;
      }
      final a = dr;
      final b = position;
      return a.blend(b, inBodyCount / electron.history.length);
    }

    final armPoint = arm.position;
    var dr = JtVec2(position.x - armPoint.x, position.y - armPoint.y);
    final deltaAngle = arm.angle;
    dr = dr.rotated(deltaAngle).plus(armPoint);

    if (inArmCount == electron.history.length) {
      return dr;
    }
    final a = dr;
    final b = position;
    return a.blend(b, inBodyCount / electron.history.length);
  }
}

/// Spark zigzag path — port of PhET `SparkNode.js`.
abstract final class SparkPathBuilder {
  static List<JtVec2> build({
    required JtVec2 finger,
    required JtVec2 knob,
    required math.Random random,
    int numSegments = 10,
  }) {
    final points = <JtVec2>[finger];
    var point = finger;
    final distanceToTarget = knob.distance(point);
    var segmentLength = distanceToTarget / numSegments;

    for (var i = 0; i < numSegments; i++) {
      if (i == numSegments - 1) {
        point = knob;
      } else {
        var delta = knob.minus(point).normalize().timesScalar(segmentLength);
        delta = delta.rotated(random.nextDouble() - 0.5);
        point = point.plus(delta);
      }
      points.add(point);
    }
    return points;
  }

  static Path toFlutterPath(List<JtVec2> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.x, points.first.y);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].x, points[i].y);
    }
    return path;
  }
}

/// Appendage image transform matching Scenery:
/// `translate(pivot - (dx,dy)); rotateAround(pivot, angle - angleOffset)`.
abstract final class AppendageTransform {
  static Matrix4 matrix({
    required Offset pivot,
    required double angle,
    required double angleOffset,
    required double dx,
    required double dy,
  }) {
    return Matrix4.identity()
      ..translateByDouble(pivot.dx, pivot.dy, 0, 1)
      ..rotateZ(angle - angleOffset)
      ..translateByDouble(-dx, -dy, 0, 1);
  }

  /// Axis-aligned bounds of the image after transform (for green border).
  static Rect imageBounds({
    required Offset pivot,
    required double angle,
    required double angleOffset,
    required double dx,
    required double dy,
    required Size imageSize,
  }) {
    final m = matrix(
      pivot: pivot,
      angle: angle,
      angleOffset: angleOffset,
      dx: dx,
      dy: dy,
    );
    final corners = <Offset>[
      Offset.zero,
      Offset(imageSize.width, 0),
      Offset(imageSize.width, imageSize.height),
      Offset(0, imageSize.height),
    ];
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    for (final c in corners) {
      final v = MatrixUtils.transformPoint(m, c);
      minX = math.min(minX, v.dx);
      minY = math.min(minY, v.dy);
      maxX = math.max(maxX, v.dx);
      maxY = math.max(maxY, v.dy);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

/// ElectronChargeNode visual (scenery-phet) — radial sphere + white minus.
class ElectronChargePainter extends CustomPainter {
  const ElectronChargePainter({this.radius = 10});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shader = ui.Gradient.radial(
      center + const Offset(2, -3),
      7,
      const [
        Color(0xFF4FCFFF),
        Color(0xFF2CBEF5),
        Color(0xFF00A9E8),
      ],
      const [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()..shader = shader,
    );
    // Minus sign 11×2 centered (ElectronChargeNode.ts)
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 11, height: 2),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant ElectronChargePainter oldDelegate) =>
      oldDelegate.radius != radius;
}
