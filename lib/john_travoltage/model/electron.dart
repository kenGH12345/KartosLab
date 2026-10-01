import 'dart:math' as math;

import 'john_travoltage_constants.dart';
import 'jt_geometry.dart';
import 'jt_vec2.dart';
import 'line_segment.dart';

/// Electron history region tags (ElectronNode / Electron.js).
abstract final class ElectronHistory {
  static const String leg = 'leg';
  static const String arm = 'arm';
  static const String body = 'body';
}

/// Single electron — PhET `Electron.js`.
class Electron {
  Electron({
    required double x,
    required double y,
    required this.model,
    required this.id,
  })  : position = JtVec2(x, y),
        velocity = JtMutableVec2(
          JohnTravoltageConstants.electronInitialVelocity.x,
          JohnTravoltageConstants.electronInitialVelocity.y,
        ) {
    for (var i = 0; i < 10; i++) {
      history.add(ElectronHistory.leg);
    }
  }

  final int id;

  /// Owning model (for forceLines / lineSegments / electronsToRemove).
  final JohnTravoltageElectronHost model;

  JtVec2 position;
  final JtMutableVec2 velocity;

  bool exiting = false;
  LineSegment? segment;
  LineSegment? lastSegment;

  final List<String> history = [];

  final double maxSpeed = JohnTravoltageConstants.maxSpeed;
  final double maxForceSquared = JohnTravoltageConstants.maxForceSquared;

  void step(double dt) {
    if (exiting) {
      stepInSpark(dt);
    } else {
      stepInBody(dt);
    }
  }

  /// Discharge path along force lines — `Electron.stepInSpark`.
  void stepInSpark(double dt) {
    if (segment == null) {
      LineSegment? closest;
      var best = double.infinity;
      for (final forceLine in model.forceLines) {
        final d = forceLine.p0.distanceSquared(position);
        if (d < best) {
          best = d;
          closest = forceLine;
        }
      }
      segment = closest;

      if (identical(lastSegment, segment)) {
        model.electronsToRemove.add(this);
        return;
      }
    }

    final currentSegment = segment!;
    final target = currentSegment.p1;
    final current = position;
    final delta = target.minus(current);

    if (delta.magnitude <=
        JohnTravoltageConstants.sparkArriveDistancePerSecond * dt) {
      lastSegment = segment;
      segment = null;
    } else {
      final jitter = model.random.nextDouble() - 0.5;
      velocity.set(
        JtVec2.createPolar(
          JohnTravoltageConstants.sparkSpeed,
          delta.angle + jitter,
        ),
      );
      position = velocity.timesScalar(dt).plus(position);
    }
  }

  /// Body repulsion + bounce — `Electron.stepInBody`.
  void stepInBody(double dt) {
    final x1 = position.x;
    final y1 = position.y;

    var netForceX = 0.0;
    var netForceY = 0.0;

    final length = model.electrons.length;
    for (var i = 0; i < length; i++) {
      final electron = model.electrons[i];
      if (!identical(electron, this) &&
          model.random.nextDouble() <
              JohnTravoltageConstants.interactionProbability) {
        final electronPosition = electron.position;
        final deltaVectorX = electronPosition.x - position.x;
        final deltaVectorY = electronPosition.y - position.y;

        if (deltaVectorX != 0 && deltaVectorY != 0) {
          final scale = JohnTravoltageConstants.repulsionScale /
              math.pow(electronPosition.distance(position), 3);
          var fx = deltaVectorX * scale;
          var fy = deltaVectorY * scale;
          final forceMagnitudeSquared = fx * fx + fy * fy;
          if (forceMagnitudeSquared > maxForceSquared) {
            // Faithful to Electron.js (divides by maxForceSquared, not normalize).
            fx = fx / maxForceSquared;
            fy = fy / maxForceSquared;
          }
          netForceX = netForceX - fx;
          netForceY = netForceY - fy;
        }
      }
    }

    var vx2 = velocity.x + netForceX * dt;
    var vy2 = velocity.y + netForceY * dt;

    final d = math.sqrt(vx2 * vx2 + vy2 * vy2);
    if (d > maxSpeed) {
      vx2 = vx2 / d * maxSpeed;
      vy2 = vy2 / d * maxSpeed;
    }
    vx2 = vx2 * JohnTravoltageConstants.frictionFactor;
    vy2 = vy2 * JohnTravoltageConstants.frictionFactor;

    final x2 = x1 + vx2 * dt;
    final y2 = y1 + vy2 * dt;

    velocity.setXY(vx2, vy2);

    final segments = model.lineSegments;
    var bounced = false;
    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      if (JtGeometry.lineSegmentIntersection(
            x1,
            y1,
            x2,
            y2,
            seg.x1,
            seg.y1,
            seg.x2,
            seg.y2,
          ) !=
          null) {
        final normal = seg.normalVector;
        // reflect velocity, lose energy (×0.8)
        final v = velocity.toVec2();
        final reflected = v
            .minus(normal.times(2 * normal.dot(v)))
            .timesScalar(JohnTravoltageConstants.bounceEnergyRetain);
        velocity.set(reflected);
        bounced = true;
        break;
      }
    }

    if (!bounced) {
      position = JtVec2(x2, y2);
    }
  }
}

/// Minimal host interface so Electron does not circular-import the full model API.
abstract class JohnTravoltageElectronHost {
  List<Electron> get electrons;
  List<LineSegment> get forceLines;
  List<LineSegment> get lineSegments;
  List<Electron> get electronsToRemove;
  math.Random get random;
}
