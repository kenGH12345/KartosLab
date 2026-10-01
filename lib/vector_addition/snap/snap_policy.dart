import 'dart:math' as math;

import '../model/enums.dart';
import '../model/va_vec.dart';
import '../vector_addition_constants.dart';

/// Snap invariants for tip/tail — mirrors `Vector.setTip/TailPositionWithInvariants`.
///
/// Painters must not call this; Interaction / Vector model owns snap.
class SnapPolicy {
  SnapPolicy({
    required this.mode,
    required this.orientation,
    required this.graphBounds,
    this.polarSnapDistance = VectorAdditionConstants.polarSnapDistance,
    this.polarAngleIntervalDegrees =
        VectorAdditionConstants.polarAngleIntervalDegrees,
    this.tailDragMargin = VectorAdditionConstants.vectorTailDragMargin,
  });

  final CoordinateSnapMode mode;
  final GraphOrientation orientation;
  final VaBounds graphBounds;
  final double polarSnapDistance;
  final double polarAngleIntervalDegrees;
  final double tailDragMargin;

  VaBounds get constrainedTailBounds => graphBounds.eroded(tailDragMargin);

  /// Returns snapped tip, or `null` if update should be rejected (zero magnitude).
  VaVec? snapTip({
    required VaVec tail,
    required VaVec proposedTip,
  }) {
    var tip = proposedTip;

    if (mode == CoordinateSnapMode.cartesian) {
      tip = graphBounds.closestPointTo(tip).roundedSymmetric();
    } else {
      tip = _snapTipPolar(tail, proposedTip);
    }

    if (orientation == GraphOrientation.horizontal) {
      tip = tip.withY(tail.y);
    } else if (orientation == GraphOrientation.vertical) {
      tip = tip.withX(tail.x);
    }

    if (tip.equalsEpsilon(tail, VectorAdditionConstants.zeroThreshold)) {
      return null;
    }
    return tip;
  }

  VaVec _snapTipPolar(VaVec tail, VaVec proposedTip) {
    var xy = proposedTip - tail;
    final roundedMagnitude = VaVec.roundSymmetric(xy.magnitude);
    final angleInRadians = polarAngleIntervalDegrees * math.pi / 180;
    var roundedAngle =
        angleInRadians * VaVec.roundSymmetric(xy.angle / angleInRadians);

    // Ensure non-negative angle (PhET issue #429).
    while (roundedAngle < 0) {
      roundedAngle += 2 * math.pi;
    }

    var polar = VaVec.createPolar(roundedMagnitude, roundedAngle);

    while (!graphBounds.containsPoint(tail + polar) && polar.magnitude > 0) {
      polar = polar.withMagnitude(polar.magnitude - 1);
    }

    return tail + polar;
  }

  /// Snap tail. [otherEndpoints] = other active + resultant tip/tail pairs for polar attract.
  VaVec snapTail({
    required VaVec proposedTail,
    required VaVec xyComponents,
    List<({VaVec tail, VaVec tip})> otherEndpoints = const [],
  }) {
    final constrained = constrainedTailBounds;
    final tailOnGraph = constrained.closestPointTo(proposedTail);

    if (mode == CoordinateSnapMode.polar) {
      final tipOnGraph = tailOnGraph + xyComponents;

      for (final other in otherEndpoints) {
        if (other.tail.distance(tailOnGraph) < polarSnapDistance) {
          return other.tail;
        }
        if (other.tip.distance(tailOnGraph) < polarSnapDistance) {
          return other.tip;
        }
        if (other.tail.distance(tipOnGraph) < polarSnapDistance) {
          return other.tail - xyComponents;
        }
      }
    }

    return tailOnGraph.roundedSymmetric();
  }
}
