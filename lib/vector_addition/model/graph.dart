import 'dart:ui';

import '../transform/math_coordinate_transform.dart';
import '../vector_addition_constants.dart';
import 'enums.dart';
import 'va_vec.dart';

/// Graph for a scene — bounds (origin-movable) + transform factory.
/// Mirrors PhET `Graph.ts`.
class Graph {
  Graph({
    required VaBounds initialBounds,
    this.orientation = GraphOrientation.twoDimensional,
    Offset? bottomLeft,
  })  : _initialBounds = initialBounds,
        bounds = initialBounds,
        bottomLeft = bottomLeft ??
            const Offset(
              VectorAdditionConstants.defaultGraphBottomLeftX,
              VectorAdditionConstants.defaultGraphBottomLeftY,
            );

  final VaBounds _initialBounds;
  final GraphOrientation orientation;
  final Offset bottomLeft;

  VaBounds bounds;

  MathCoordinateTransform get transform => MathCoordinateTransform.fromGraph(
        modelBounds: bounds,
        bottomLeft: bottomLeft,
      );

  Rect get viewBounds {
    final t = transform;
    return t.viewBounds;
  }

  /// PhET `moveOriginToPoint` — point must be inside bounds; rounded symmetrically.
  void moveOriginToPoint(VaVec point) {
    assert(bounds.containsPoint(point), 'point out of bounds: $point');
    final rounded = point.roundedSymmetric();
    bounds = bounds.shiftedXY(-rounded.x, -rounded.y);
  }

  void reset() {
    bounds = _initialBounds;
  }
}
