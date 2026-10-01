import 'dart:math' as math;

import 'package:kratos/energy_skate_park/model/control_point.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/solver/hermite_spline.dart';
import 'package:kratos/energy_skate_park/solver/spline_evaluation.dart';

/// Curvature result {r, x, y} from Track.getCurvature.
class Curvature {
  Curvature({this.r = 0, this.x = 0, this.y = 0});
  double r;
  double x;
  double y;
}

/// Track model — key APIs from Track.ts.
class Track {
  Track(
    this.controlPoints, {
    this.draggable = false,
    this.configurable = false,
    this.splittable = false,
    this.attachable = false,
    this.slopeToGround = false,
    this.physical = false,
  }) {
    _parametricPosition = List<double>.filled(controlPoints.length, 0);
    _x = List<double>.filled(controlPoints.length, 0);
    _y = List<double>.filled(controlPoints.length, 0);
    updateLinSpace();
    updateSplines();
  }

  final List<ControlPoint> controlPoints;
  final bool draggable;
  final bool configurable;
  final bool splittable;
  final bool attachable;
  bool physical;
  bool slopeToGround;

  late List<double> _parametricPosition;
  late List<double> _x;
  late List<double> _y;

  HermiteSpline? xSpline;
  HermiteSpline? ySpline;
  HermiteSpline? xSplineDiff;
  HermiteSpline? ySplineDiff;
  HermiteSpline? xSplineDiffDiff;
  HermiteSpline? ySplineDiffDiff;

  List<double>? searchLinSpace;
  List<double>? xSearchPoints;
  List<double>? ySearchPoints;
  double? distanceBetweenSamplePoints;

  late double minPoint;
  late double maxPoint;

  void updateLinSpace() {
    minPoint = 0;
    maxPoint = (controlPoints.length - 1) / controlPoints.length;
    final prePoint = minPoint - 1e-6;
    final postPoint = maxPoint + 1e-6;
    final n = 20 * (controlPoints.length - 1);
    searchLinSpace = _linspace(prePoint, postPoint, n);
    distanceBetweenSamplePoints = (postPoint - prePoint) / n;
  }

  static List<double> _linspace(double a, double b, int n) {
    if (n <= 1) return [a];
    final out = List<double>.filled(n, 0);
    final step = (b - a) / (n - 1);
    for (var i = 0; i < n; i++) {
      out[i] = a + i * step;
    }
    return out;
  }

  /// parametricPosition[i]=i/n; xSpline=fit(u,x); ySpline=fit(u,y)
  void updateSplines() {
    for (var i = 0; i < controlPoints.length; i++) {
      _parametricPosition[i] = i / controlPoints.length;
      _x[i] = controlPoints[i].x;
      _y[i] = controlPoints[i].y;
    }
    xSpline = HermiteSpline.fit(_parametricPosition, _x);
    ySpline = HermiteSpline.fit(_parametricPosition, _y);
    xSearchPoints = null;
    ySearchPoints = null;
    xSplineDiff = null;
    ySplineDiff = null;
    xSplineDiffDiff = null;
    ySplineDiffDiff = null;
  }

  void _ensureDiff() {
    if (xSplineDiff == null) {
      xSplineDiff = xSpline!.diff();
      ySplineDiff = ySpline!.diff();
    }
  }

  void _ensureDiffDiff() {
    _ensureDiff();
    if (xSplineDiffDiff == null) {
      xSplineDiffDiff = xSplineDiff!.diff();
      ySplineDiffDiff = ySplineDiff!.diff();
    }
  }

  double getX(double parametricPosition) =>
      SplineEvaluation.atNumber(xSpline!, parametricPosition);

  double getY(double parametricPosition) =>
      SplineEvaluation.atNumber(ySpline!, parametricPosition);

  EspVec getPoint(double parametricPosition) =>
      EspVec(getX(parametricPosition), getY(parametricPosition));

  EspVec getUnitParallelVector(double parametricPosition) {
    _ensureDiff();
    return EspVec(
      SplineEvaluation.atNumber(xSplineDiff!, parametricPosition),
      SplineEvaluation.atNumber(ySplineDiff!, parametricPosition),
    ).normalize();
  }

  /// Normal = (-y', x') then normalize — Track.ts getUnitNormalVector.
  EspVec getUnitNormalVector(double parametricPosition) {
    _ensureDiff();
    return EspVec(
      -SplineEvaluation.atNumber(ySplineDiff!, parametricPosition),
      SplineEvaluation.atNumber(xSplineDiff!, parametricPosition),
    ).normalize();
  }

  double getModelAngleAt(double parametricPosition) {
    _ensureDiff();
    return math.atan2(
      SplineEvaluation.atNumber(ySplineDiff!, parametricPosition),
      SplineEvaluation.atNumber(xSplineDiff!, parametricPosition),
    );
  }

  double getViewAngleAt(double parametricPosition) {
    _ensureDiff();
    return math.atan2(
      -SplineEvaluation.atNumber(ySplineDiff!, parametricPosition),
      SplineEvaluation.atNumber(xSplineDiff!, parametricPosition),
    );
  }

  /// k=(x'y''-y'x'')/(x'²+y'²)^(3/2); r=1/k; center = point + n/k
  void getCurvature(double parametricPosition, Curvature curvature) {
    _ensureDiffDiff();
    final xP = SplineEvaluation.atNumber(xSplineDiff!, parametricPosition);
    final xPP = SplineEvaluation.atNumber(xSplineDiffDiff!, parametricPosition);
    final yP = SplineEvaluation.atNumber(ySplineDiff!, parametricPosition);
    final yPP = SplineEvaluation.atNumber(ySplineDiffDiff!, parametricPosition);

    final k = (xP * yPP - yP * xPP) / math.pow(xP * xP + yP * yP, 1.5);

    final centerX = getX(parametricPosition);
    final centerY = getY(parametricPosition);
    final unitNormalVector = getUnitNormalVector(parametricPosition);
    curvature.r = 1 / k;
    curvature.x = unitNormalVector.x / k + centerX;
    curvature.y = unitNormalVector.y / k + centerY;
  }

  /// 4-segment polyline arc-length approx as in Track.ts.
  double getArcLength(double u0, double u1) {
    if (u1 == u0) return 0;
    if (u1 < u0) return -getArcLength(u1, u0);

    const numSegments = 4;
    final da = (u1 - u0) / (numSegments - 1);
    var prevX = SplineEvaluation.atNumber(xSpline!, u0);
    var prevY = SplineEvaluation.atNumber(ySpline!, u0);
    var sum = 0.0;
    for (var i = 1; i < numSegments; i++) {
      final a = u0 + i * da;
      final ptX = SplineEvaluation.atNumber(xSpline!, a);
      final ptY = SplineEvaluation.atNumber(ySpline!, a);
      final dx = prevX - ptX;
      final dy = prevY - ptY;
      sum += math.sqrt(dx * dx + dy * dy);
      prevX = ptX;
      prevY = ptY;
    }
    return sum;
  }

  /// Binary search for parametric distance given arc length ds.
  double getParametricDistance(double u0, double ds) {
    var lowerBound = -1.0;
    var upperBound = 2.0;
    var guess = (upperBound + lowerBound) / 2.0;
    var metricDelta = getArcLength(u0, guess);
    const epsilon = 1e-8;
    var count = 0;
    while ((metricDelta - ds).abs() > epsilon) {
      if (metricDelta > ds) {
        upperBound = guess;
      } else {
        lowerBound = guess;
      }
      guess = (upperBound + lowerBound) / 2.0;
      metricDelta = getArcLength(u0, guess);
      count++;
      if (count > 100) break;
    }
    return guess - u0;
  }

  bool isParameterInBounds(double parametricPosition) =>
      parametricPosition >= minPoint && parametricPosition <= maxPoint;

  /// Closest point search used when attaching / bouncing onto track.
  ({double parametricPosition, EspVec point, double distance})
      getClosestPositionAndParameter(EspVec point) {
    if (xSearchPoints == null) {
      xSearchPoints = SplineEvaluation.atArray(xSpline!, searchLinSpace!);
      ySearchPoints = SplineEvaluation.atArray(ySpline!, searchLinSpace!);
    }

    var bestU = 0.0;
    var bestDistanceSquared = double.infinity;
    var bestX = 0.0;
    var bestY = 0.0;
    for (var i = 0; i < xSearchPoints!.length; i++) {
      final distanceSquared =
          point.distanceSquaredXY(xSearchPoints![i], ySearchPoints![i]);
      if (distanceSquared < bestDistanceSquared) {
        bestDistanceSquared = distanceSquared;
        bestU = searchLinSpace![i];
        bestX = xSearchPoints![i];
        bestY = ySearchPoints![i];
      }
    }

    final distanceBetweenSearchPoints =
        (searchLinSpace![1] - searchLinSpace![0]).abs();
    var topU = bestU + distanceBetweenSearchPoints / 2;
    var bottomU = bestU - distanceBetweenSearchPoints / 2;
    var topX = SplineEvaluation.atNumber(xSpline!, topU);
    var topY = SplineEvaluation.atNumber(ySpline!, topU);
    var bottomX = SplineEvaluation.atNumber(xSpline!, bottomU);
    var bottomY = SplineEvaluation.atNumber(ySpline!, bottomU);

    const maxBinarySearchIterations = 40;
    for (var i = 0; i < maxBinarySearchIterations; i++) {
      final topDistanceSquared = point.distanceSquaredXY(topX, topY);
      final bottomDistanceSquared =
          point.distanceSquaredXY(bottomX, bottomY);
      if (topDistanceSquared < bottomDistanceSquared) {
        bottomU = bottomU + (topU - bottomU) / 4;
        bottomX = SplineEvaluation.atNumber(xSpline!, bottomU);
        bottomY = SplineEvaluation.atNumber(ySpline!, bottomU);
        bestDistanceSquared = topDistanceSquared;
      } else {
        topU = topU - (topU - bottomU) / 4;
        topX = SplineEvaluation.atNumber(xSpline!, topU);
        topY = SplineEvaluation.atNumber(ySpline!, topU);
        bestDistanceSquared = bottomDistanceSquared;
      }
    }
    bestU = (topU + bottomU) / 2;
    bestX = SplineEvaluation.atNumber(xSpline!, bestU);
    bestY = SplineEvaluation.atNumber(ySpline!, bestU);

    return (
      parametricPosition: bestU,
      point: EspVec(bestX, bestY),
      distance: bestDistanceSquared,
    );
  }
}