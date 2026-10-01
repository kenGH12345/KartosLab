import 'dart:math' as math;
import 'dart:ui';

import '../constants/hookes_law_constants.dart';

/// One sample of scenery-phet `ParametricSpringNode` (prolate cycloid).
class SpringCoilPoint {
  const SpringCoilPoint(this.x, this.y, this.front);

  final double x;
  final double y;

  /// Front half of the coil. Source: the phase test is `> π`.
  final bool front;
}

/// scenery-phet `ParametricSpringNode` point loop, plus Hooke's Law end caps.
///
/// Not a sine wave. `x` includes `radius * cos(θ)`, so a loop folds backward
/// in x (prolate) whenever that term outruns the `xScale` step.
class ParametricSpringGeometry {
  const ParametricSpringGeometry({
    required this.points,
    required this.xScale,
    required this.lineWidth,
    required this.leftEndLength,
    required this.rightEndLength,
  });

  final List<SpringCoilPoint> points;
  final double xScale;
  final double lineWidth;
  final double leftEndLength;
  final double rightEndLength;

  /// View length of the coil body, excluding the horizontal end segments.
  /// [loops] defaults to the Intro coil count so existing callers stay put.
  /// Series and parallel springs use 8 loops; the right tip is still
  /// `lengthMeters * 225` because [xScale] absorbs the coil count.
  static double xScaleForLength(
    double lengthMeters, {
    int loops = HookesLawConstants.singleSpringLoops,
  }) {
    final viewLength = lengthMeters * HookesLawConstants.unitDisplacementX;
    final coilLength = viewLength -
        (HookesLawConstants.springLeftEndLength +
            HookesLawConstants.springRightEndLength);
    return coilLength / (loops * HookesLawConstants.springRadius);
  }

  /// `minLineWidth + deltaLineWidth * (k - kMin)`.
  static double lineWidthFor(double springConstant, {required double minK}) {
    return HookesLawConstants.springMinLineWidth +
        HookesLawConstants.springDeltaLineWidth * (springConstant - minK);
  }

  factory ParametricSpringGeometry.intro({
    required double lengthMeters,
    required double springConstant,
    required double minK,
  }) {
    return ParametricSpringGeometry.sample(
      loops: HookesLawConstants.singleSpringLoops,
      pointsPerLoop: HookesLawConstants.springPointsPerLoop,
      radius: HookesLawConstants.springRadius,
      aspectRatio: HookesLawConstants.springAspectRatio,
      leftEndLength: HookesLawConstants.springLeftEndLength,
      rightEndLength: HookesLawConstants.springRightEndLength,
      xScale: xScaleForLength(lengthMeters),
      lineWidth: lineWidthFor(springConstant, minK: minK),
    );
  }

  factory ParametricSpringGeometry.sample({
    required int loops,
    required int pointsPerLoop,
    required double radius,
    required double aspectRatio,
    required double leftEndLength,
    required double rightEndLength,
    required double xScale,
    required double lineWidth,
    double phase = math.pi,
    double deltaPhase = math.pi / 2,
  }) {
    final count = loops * pointsPerLoop + 1;
    final points = <SpringCoilPoint>[];
    for (var i = 0; i < count; i++) {
      final theta = 2 * math.pi * i / pointsPerLoop;
      final x = (leftEndLength + radius) +
          radius * math.cos(theta + phase) +
          xScale * (i / pointsPerLoop) * radius;
      final y = aspectRatio *
          radius *
          math.cos(theta + deltaPhase + phase);
      final side = (theta + phase + deltaPhase) % (2 * math.pi);
      points.add(SpringCoilPoint(x, y, side > math.pi));
    }
    return ParametricSpringGeometry(
      points: points,
      xScale: xScale,
      lineWidth: lineWidth,
      leftEndLength: leftEndLength,
      rightEndLength: rightEndLength,
    );
  }

  /// Horizontal segment at the left end, then the coil, then the right end.
  /// The right tip is `lengthMeters * 225` from the spring origin.
  double get rightTipX => points.last.x + rightEndLength;

  /// Back path then front path, matching the source paint order.
  (Path back, Path front) toPaths() {
    final back = Path();
    final front = Path();
    if (points.isEmpty) {
      return (back, front);
    }
    final first = points.first;
    final last = points.last;
    _addRun(first.front ? front : back, Offset(0, first.y), Offset(first.x, first.y));
    var runFront = first.front;
    var run = first.front ? front : back;
    run.moveTo(first.x, first.y);
    for (var i = 1; i < points.length; i++) {
      final point = points[i];
      if (point.front != runFront) {
        run.lineTo(point.x, point.y);
        runFront = point.front;
        run = point.front ? front : back;
        run.moveTo(point.x, point.y);
      } else {
        run.lineTo(point.x, point.y);
      }
    }
    _addRun(
      last.front ? front : back,
      Offset(last.x, last.y),
      Offset(last.x + rightEndLength, last.y),
    );
    return (back, front);
  }
}

void _addRun(Path path, Offset from, Offset to) {
  path.moveTo(from.dx, from.dy);
  path.lineTo(to.dx, to.dy);
}
