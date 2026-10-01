import '../collision_lab_constants.dart';
import '../solver/ball_utils.dart';
import 'ball.dart';
import 'cl_vec.dart';
import 'play_area.dart';

/// Single momenta vector — `js/common/model/MomentaDiagramVector.js`
class MomentaDiagramVector {
  ClVec tailPosition = ClVec.zero;
  ClVec components = ClVec.zero;

  ClVec get tipPosition => tailPosition + components;
  ClVec get center => tailPosition + components * 0.5;
  double get magnitude => components.magnitude;

  void reset() {
    tailPosition = ClVec.zero;
    components = ClVec.zero;
  }
}

/// Momenta diagram model — `js/common/model/MomentaDiagram.js`
class MomentaDiagram {
  MomentaDiagram({
    required List<Ball> prepopulatedBalls,
    required this.balls,
    required this.dimension,
  }) {
    for (final ball in prepopulatedBalls) {
      ballToMomentaVector[ball] = MomentaDiagramVector();
    }
  }

  static const double _default1dVerticalSpacing = 0.3;
  static const double _zoomMultiplier = 2;

  final List<Ball> balls;
  final PlayAreaDimension dimension;

  double zoom = CollisionLabConstants.momentaZoomDefault;
  bool expanded = false;

  final Map<Ball, MomentaDiagramVector> ballToMomentaVector = {};
  final MomentaDiagramVector totalMomentumVector = MomentaDiagramVector();

  ClBounds get bounds {
    final w = CollisionLabConstants.momentaDiagramAspectW / 2 / zoom;
    final h = CollisionLabConstants.momentaDiagramAspectH / 2 / zoom;
    return ClBounds(minX: -w, minY: -h, maxX: w, maxY: h);
  }

  void reset() {
    zoom = CollisionLabConstants.momentaZoomDefault;
    expanded = false;
    for (final v in ballToMomentaVector.values) {
      v.reset();
    }
    totalMomentumVector.reset();
  }

  void zoomIn() {
    zoom = (zoom * _zoomMultiplier).clamp(
      CollisionLabConstants.momentaZoomMin,
      CollisionLabConstants.momentaZoomMax,
    );
  }

  void zoomOut() {
    zoom = (zoom / _zoomMultiplier).clamp(
      CollisionLabConstants.momentaZoomMin,
      CollisionLabConstants.momentaZoomMax,
    );
  }

  /// Update components + layout when accordion is expanded.
  void updateVectors() {
    if (!expanded || balls.isEmpty) return;

    for (final ball in balls) {
      ballToMomentaVector[ball]!.components = ball.momentum;
    }

    var totalPx = 0.0;
    var totalPy = 0.0;
    for (final ball in balls) {
      final m = ball.momentum;
      totalPx += m.x;
      totalPy += m.y;
    }
    totalMomentumVector.components = ClVec(totalPx, totalPy);

    final first = ballToMomentaVector[balls[0]]!;
    final verticalSpacing = _default1dVerticalSpacing /
        zoom *
        CollisionLabConstants.momentaZoomDefault;

    if (dimension == PlayAreaDimension.two) {
      final origin = bounds.center;
      first.tailPosition = origin;
      totalMomentumVector.tailPosition = origin;
    } else {
      first.tailPosition = ClVec(
        0,
        verticalSpacing * (balls.length / 2 + 0.9),
      );
      totalMomentumVector.tailPosition = ClVec(
        0,
        first.tailPosition.y - balls.length * verticalSpacing,
      );
    }

    CollisionLabUtils.forEachAdjacentPair(balls, (ball, previousBall) {
      final momentaVector = ballToMomentaVector[ball]!;
      final previous = ballToMomentaVector[previousBall]!;
      if (dimension == PlayAreaDimension.two) {
        momentaVector.tailPosition = previous.tipPosition;
      } else {
        momentaVector.tailPosition = ClVec(
          previous.tipPosition.x,
          previous.tailPosition.y - verticalSpacing,
        );
      }
    });
  }
}
