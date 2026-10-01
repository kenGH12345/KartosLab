import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../../model/single_spring_system.dart';
import '../parametric_spring_geometry.dart';

/// Colors from `HookesLawColors.ts` defaults used by Intro.
class IntroColors {
  const IntroColors._();

  static const wall = Color.fromRGBO(180, 180, 180, 1);
  static const panelFill = Color.fromRGBO(243, 243, 243, 1);
  static const panelStroke = Color.fromRGBO(125, 125, 125, 1);
  static const springFront = Color.fromRGBO(150, 150, 255, 1);
  static const springMiddle = Color.fromRGBO(0, 0, 255, 1);
  static const springBack = Color.fromRGBO(0, 0, 200, 1);
  static const appliedForce = Color.fromRGBO(255, 85, 0, 1);
  static const displacement = Color.fromRGBO(0, 180, 0, 1);
  static const equilibrium = Color.fromRGBO(0, 180, 0, 1);
  static const armFill = Color.fromRGBO(210, 210, 210, 1);
  static const hinge = Color.fromRGBO(236, 35, 23, 1);
  static const iconFront = Color.fromRGBO(100, 100, 100, 1);
  static const iconMiddle = Color.fromRGBO(50, 50, 50, 1);
  static const iconBack = Color.fromRGBO(0, 0, 0, 1);
  static const valueScrim = Color.fromRGBO(255, 255, 255, 0.8);
  static const track = Color.fromRGBO(160, 160, 160, 1);
}

/// Play-area paint for one Intro system. Local origin is the top-left of the
/// wall. Spring axis is `y = wallHeight / 2`. Attachment x is [wallWidth].
class IntroPlayPainter extends CustomPainter {
  IntroPlayPainter({
    required this.system,
    required this.equilibriumVisible,
    required this.appliedForceVisible,
    required this.springForceVisible,
    required this.displacementVisible,
    required this.grippersOpen,
  });

  final SingleSpringSystem system;
  final bool equilibriumVisible;
  final bool appliedForceVisible;
  final bool springForceVisible;
  final bool displacementVisible;
  final bool grippersOpen;

  static double get axisY => HookesLawConstants.wallHeight / 2;

  /// `appliedForceVectorNode.bottom = spring.y - 50`.
  static double get forceTailY =>
      axisY - HookesLawConstants.introForceVectorGap - HookesLawConstants.vectorHeadWidth / 2;

  /// `displacementVectorNode.top = spring.y + 50`.
  static double get displacementTailY =>
      axisY + HookesLawConstants.introDisplacementVectorGap + HookesLawConstants.vectorHeadWidth / 2;

  static double get attachmentX => HookesLawConstants.wallWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final spring = system.spring;
    final unit = HookesLawConstants.unitDisplacementX;
    final origin = Offset(attachmentX, axisY);
    final springRight = origin.dx + unit * spring.right;
    final equilibriumX = origin.dx + unit * spring.equilibriumX;
    final armX = origin.dx + unit * system.roboticArm.right;

    if (equilibriumVisible) {
      _paintDashedLine(
        canvas,
        Offset(equilibriumX, 0),
        Offset(equilibriumX, HookesLawConstants.wallHeight),
      );
    }

    paintRoboticArm(
      canvas,
      armOriginX: armX,
      handX: springRight,
      axisY: axisY,
      grippersOpen: grippersOpen,
    );

    _paintSpring(canvas, origin, spring.length, spring.springConstant, spring.springConstantRange.min);
    _paintWall(canvas);
    _paintNib(canvas, springRight, axisY);

    if (appliedForceVisible && spring.appliedForce != 0) {
      _paintForceArrow(
        canvas,
        tail: Offset(springRight, forceTailY),
        newtons: spring.appliedForce,
        color: IntroColors.appliedForce,
      );
    }
    if (springForceVisible && spring.springForce != 0) {
      _paintForceArrow(
        canvas,
        tail: Offset(springRight, forceTailY),
        newtons: spring.springForce,
        color: IntroColors.springMiddle,
      );
    }
    if (displacementVisible && spring.displacement != 0) {
      _paintDisplacementArrow(
        canvas,
        tail: Offset(equilibriumX, displacementTailY),
        meters: spring.displacement,
      );
    }
  }

  void _paintWall(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, HookesLawConstants.wallWidth, HookesLawConstants.wallHeight),
      const Radius.circular(HookesLawConstants.wallCornerRadius),
    );
    canvas.drawRRect(rect, Paint()..color = IntroColors.wall);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintSpring(
    Canvas canvas,
    Offset origin,
    double lengthMeters,
    double springConstant,
    double minK,
  ) {
    final geometry = ParametricSpringGeometry.intro(
      lengthMeters: lengthMeters,
      springConstant: springConstant,
      minK: minK,
    );
    final (back, front) = geometry.toPaths();
    final yRadius = HookesLawConstants.springRadius * HookesLawConstants.springAspectRatio;
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.drawPath(back, _springPaint(geometry.lineWidth, _backGradient(yRadius)));
    canvas.drawPath(front, _springPaint(geometry.lineWidth, _frontGradient(yRadius)));
    canvas.restore();
  }

  Paint _springPaint(double width, Shader shader) {
    return Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  Shader _frontGradient(double yRadius) {
    return ui.Gradient.linear(
      Offset(0, -yRadius),
      Offset(0, yRadius),
      const [
        IntroColors.springMiddle,
        IntroColors.springFront,
        IntroColors.springFront,
        IntroColors.springMiddle,
      ],
      const [0, 0.35, 0.65, 1],
    );
  }

  Shader _backGradient(double yRadius) {
    return ui.Gradient.linear(
      Offset(0, -yRadius),
      Offset(0, yRadius),
      const [
        IntroColors.springMiddle,
        IntroColors.springBack,
        IntroColors.springMiddle,
      ],
      const [0, 0.5, 1],
    );
  }

  void _paintNib(Canvas canvas, double springRight, double axis) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        springRight,
        axis - HookesLawConstants.nibHeight / 2,
        HookesLawConstants.nibWidth,
        HookesLawConstants.nibHeight,
      ),
      const Radius.circular(HookesLawConstants.nibCornerRadius),
    );
    canvas.drawRRect(rect, Paint()..color = IntroColors.springMiddle);
  }

  void _paintForceArrow(
    Canvas canvas, {
    required Offset tail,
    required double newtons,
    required Color color,
  }) {
    final length = newtons * HookesLawConstants.unitForceX;
    final path = _filledArrow(length);
    canvas.save();
    canvas.translate(tail.dx, tail.dy);
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  void _paintDisplacementArrow(
    Canvas canvas, {
    required Offset tail,
    required double meters,
  }) {
    final length = meters * HookesLawConstants.unitDisplacementX;
    canvas.save();
    canvas.translate(tail.dx, tail.dy);
    final paint = Paint()
      ..color = IntroColors.displacement
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.butt;
    final head = math.min(HookesLawConstants.vectorHeadHeight, length.abs());
    final dir = length.sign;
    final shaftEnd = length - dir * head;
    canvas.drawLine(Offset.zero, Offset(shaftEnd, 0), paint);
    final headPath = Path()
      ..moveTo(shaftEnd, -HookesLawConstants.vectorHeadWidth / 2)
      ..lineTo(length, 0)
      ..lineTo(shaftEnd, HookesLawConstants.vectorHeadWidth / 2);
    canvas.drawPath(headPath, paint..strokeJoin = StrokeJoin.miter);
    canvas.drawLine(const Offset(0, -10), const Offset(0, 10), Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 2);
    canvas.restore();
  }

  void _paintDashedLine(Canvas canvas, Offset from, Offset to) {
    const dash = 3.0;
    const gap = 3.0;
    final paint = Paint()
      ..color = IntroColors.equilibrium
      ..strokeWidth = 2;
    var y = from.dy;
    while (y < to.dy) {
      final y2 = math.min(y + dash, to.dy);
      canvas.drawLine(Offset(from.dx, y), Offset(from.dx, y2), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(IntroPlayPainter oldDelegate) {
    return oldDelegate.system.spring.displacement != system.spring.displacement ||
        oldDelegate.system.spring.springConstant != system.spring.springConstant ||
        oldDelegate.system.spring.appliedForce != system.spring.appliedForce ||
        oldDelegate.equilibriumVisible != equilibriumVisible ||
        oldDelegate.appliedForceVisible != appliedForceVisible ||
        oldDelegate.springForceVisible != springForceVisible ||
        oldDelegate.displacementVisible != displacementVisible ||
        oldDelegate.grippersOpen != grippersOpen;
  }
}

Path _filledArrow(double length) {
  final dir = length.sign == 0 ? 1.0 : length.sign;
  final mag = length.abs();
  final head = math.min(HookesLawConstants.vectorHeadHeight, mag);
  final shaft = mag - head;
  final tail = HookesLawConstants.forceTailWidth / 2;
  final headHalf = HookesLawConstants.vectorHeadWidth / 2;
  final path = Path();
  if (dir > 0) {
    path
      ..moveTo(0, -tail)
      ..lineTo(shaft, -tail)
      ..lineTo(shaft, -headHalf)
      ..lineTo(mag, 0)
      ..lineTo(shaft, headHalf)
      ..lineTo(shaft, tail)
      ..close();
  } else {
    path
      ..moveTo(0, -tail)
      ..lineTo(-shaft, -tail)
      ..lineTo(-shaft, -headHalf)
      ..lineTo(-mag, 0)
      ..lineTo(-shaft, headHalf)
      ..lineTo(-shaft, tail)
      ..close();
  }
  return path;
}

void paintRoboticArm(
  Canvas canvas, {
  required double armOriginX,
  required double handX,
  required double axisY,
  required bool grippersOpen,
}) {
  final redLeft = armOriginX;
  final red = Rect.fromLTWH(
    redLeft,
    axisY - HookesLawConstants.armRedBoxHeight / 2,
    HookesLawConstants.armRedBoxWidth,
    HookesLawConstants.armRedBoxHeight,
  );
  final gradient = Rect.fromLTWH(
    red.right - 1,
    axisY - HookesLawConstants.armGradientBoxHeight / 2,
    HookesLawConstants.armGradientBoxWidth,
    HookesLawConstants.armGradientBoxHeight,
  );
  final handRight = handX + _closedGripperLocalRight();
  final armRight = gradient.left + HookesLawConstants.armOverlap;
  final armLeft = handRight - HookesLawConstants.armOverlap;
  final armWidth = math.max(1.0, armRight - armLeft);
  final armRect = Rect.fromLTWH(
    armLeft,
    axisY - HookesLawConstants.armHeight / 2,
    armWidth,
    HookesLawConstants.armHeight,
  );
  final armPaint = Paint()
    ..shader = ui.Gradient.linear(
      armRect.topCenter,
      armRect.bottomCenter,
      const [IntroColors.armFill, Color(0xFFFFFFFF), IntroColors.armFill],
      const [0, 0.3, 1],
    );
  canvas.drawRect(armRect, armPaint);
  canvas.drawRect(
    armRect,
    Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5,
  );
  canvas.drawRect(red, Paint()..color = IntroColors.hinge);
  canvas.drawRect(
    red,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0xFF000000),
  );
  final boxPaint = Paint()
    ..shader = ui.Gradient.linear(
      gradient.topCenter,
      gradient.bottomCenter,
      const [IntroColors.armFill, Color(0xFFFFFFFF), IntroColors.armFill],
      const [0, 0.5, 1],
    );
  canvas.drawRect(gradient, boxPaint);
  canvas.drawRect(
    gradient,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0xFF000000),
  );
  _paintHand(canvas, Offset(handX, axisY), grippersOpen);
}

/// Hit rect of `RoboticHandNode` in hand-local coordinates.
///
/// The drag listener is on the whole hand. The red hinge is the right side
/// of that node. Touch area is `localBounds.dilatedXY(0.3 * width, 0.2 * height)`.
Rect roboticHandHitRect() {
  final top = _closedTopGripper();
  final bottom = _closedBottomGripper();
  final stroke = HookesLawConstants.gripperLineWidth / 2;
  var bounds = top.bounds.expandToInclude(bottom.bounds).inflate(stroke);
  bounds = bounds.expandToInclude(_hingeLocalBounds(top.bounds.right - 12));
  final dx = 0.3 * bounds.width;
  final dy = 0.2 * bounds.height;
  return Rect.fromLTRB(bounds.left - dx, bounds.top - dy, bounds.right + dx, bounds.bottom + dy);
}

/// Drag target aligned with the painted hand, including the red hinge.
Widget roboticHandDragTarget({
  required Key key,
  required double handX,
  required double axisY,
  required GestureDragStartCallback onPanStart,
  required GestureDragUpdateCallback onPanUpdate,
  required GestureDragEndCallback onPanEnd,
  required GestureDragCancelCallback onPanCancel,
}) {
  final hit = roboticHandHitRect();
  return Positioned(
    left: handX + hit.left,
    top: axisY + hit.top,
    width: hit.width,
    height: hit.height,
    child: GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      onPanCancel: onPanCancel,
      child: const SizedBox.expand(),
    ),
  );
}

_PlacedArc _closedTopGripper() {
  return _arcPlacement(
    radius: HookesLawConstants.gripperRadius,
    start: -0.9 * math.pi,
    sweep: 0.8 * math.pi,
    left: 0,
    bottom: HookesLawConstants.gripperOverlap,
  );
}

_PlacedArc _closedBottomGripper() {
  return _arcPlacement(
    radius: HookesLawConstants.gripperRadius,
    start: 0.9 * math.pi,
    sweep: -0.8 * math.pi,
    left: 0,
    top: -HookesLawConstants.gripperOverlap,
  );
}

/// Painted hinge bounds. Arc center matches [_paintHinge].
Rect _hingeLocalBounds(double pivotLeft) {
  const pivotW = 26.0;
  const bodyH = 40.0;
  const bodyW = 9.0;
  final theta = math.atan((0.5 * bodyH) / bodyW);
  final radius = (0.5 * bodyH) / math.sin(theta);
  final bodyLeft = pivotLeft + pivotW - 1;
  return Rect.fromLTRB(pivotLeft, -0.5 * bodyH, bodyLeft + radius, 0.5 * bodyH);
}

/// Right edge of the closed gripper in the hand's local coordinates.
double _closedGripperLocalRight() {
  return _closedTopGripper().bounds.right;
}

/// Returns the right edge of the closed gripper, in parent coordinates.
double _paintHand(Canvas canvas, Offset origin, bool open) {
  canvas.save();
  canvas.translate(origin.dx, origin.dy);
  final closedTop = _closedTopGripper();
  final closedBottom = _closedBottomGripper();
  final openTop = _arcPlacement(
    radius: HookesLawConstants.gripperRadius,
    start: -0.8 * math.pi,
    sweep: 0.8 * math.pi,
    right: closedTop.bounds.right,
    bottom: 0,
  );
  final openBottom = _arcPlacement(
    radius: HookesLawConstants.gripperRadius,
    start: 0.8 * math.pi,
    sweep: -0.8 * math.pi,
    right: closedBottom.bounds.right,
    top: 0,
  );
  final stroke = Paint()
    ..color = const Color(0xFF000000)
    ..style = PaintingStyle.stroke
    ..strokeWidth = HookesLawConstants.gripperLineWidth
    ..strokeCap = StrokeCap.round;
  if (open) {
    _drawArc(canvas, openTop, stroke);
    _drawArc(canvas, openBottom, stroke);
  } else {
    _drawArc(canvas, closedTop, stroke);
    _drawArc(canvas, closedBottom, stroke);
  }
  _paintHinge(canvas, closedTop.bounds.right - 12);
  canvas.restore();
  return origin.dx + closedTop.bounds.right;
}

void _drawArc(Canvas canvas, _PlacedArc arc, Paint paint) {
  canvas.drawArc(arc.oval, arc.start, arc.sweep, false, paint);
}

class _PlacedArc {
  const _PlacedArc(this.oval, this.start, this.sweep, this.bounds);

  final Rect oval;
  final double start;
  final double sweep;
  final Rect bounds;
}

_PlacedArc _arcPlacement({
  required double radius,
  required double start,
  required double sweep,
  double? left,
  double? right,
  double? top,
  double? bottom,
}) {
  final local = _arcBounds(radius, start, sweep);
  var dx = 0.0;
  var dy = 0.0;
  if (left != null) {
    dx = left - local.left;
  } else if (right != null) {
    dx = right - local.right;
  }
  if (bottom != null) {
    dy = bottom - local.bottom;
  } else if (top != null) {
    dy = top - local.top;
  }
  final bounds = local.shift(Offset(dx, dy));
  return _PlacedArc(
    Rect.fromCircle(center: Offset(dx, dy), radius: radius),
    start,
    sweep,
    bounds,
  );
}

Rect _arcBounds(double radius, double start, double sweep) {
  var minX = double.infinity;
  var minY = double.infinity;
  var maxX = -double.infinity;
  var maxY = -double.infinity;
  void take(double angle) {
    final x = radius * math.cos(angle);
    final y = radius * math.sin(angle);
    minX = math.min(minX, x);
    maxX = math.max(maxX, x);
    minY = math.min(minY, y);
    maxY = math.max(maxY, y);
  }

  const steps = 32;
  for (var i = 0; i <= steps; i++) {
    take(start + sweep * i / steps);
  }
  for (final extreme in [0.0, math.pi / 2, math.pi, -math.pi / 2, 3 * math.pi / 2]) {
    if (_angleInSweep(extreme, start, sweep)) {
      take(extreme);
    }
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

bool _angleInSweep(double angle, double start, double sweep) {
  final end = start + sweep;
  final lo = math.min(start, end);
  final hi = math.max(start, end);
  final wrapped = _wrap(angle);
  // Compare against the unwrapped interval by testing a few turns.
  for (final turn in [-2 * math.pi, 0.0, 2 * math.pi]) {
    final candidate = wrapped + turn;
    if (candidate >= lo - 1e-6 && candidate <= hi + 1e-6) {
      return true;
    }
  }
  return false;
}

double _wrap(double angle) {
  var a = angle % (2 * math.pi);
  if (a > math.pi) {
    a -= 2 * math.pi;
  } else if (a < -math.pi) {
    a += 2 * math.pi;
  }
  return a;
}

/// Scene-selection spring. `HookesLawIconFactory` + `ParametricSpringNode` defaults.
ParametricSpringGeometry sceneSelectionSpringGeometry() {
  return ParametricSpringGeometry.sample(
    loops: 3,
    pointsPerLoop: HookesLawConstants.springPointsPerLoop,
    radius: HookesLawConstants.springRadius,
    aspectRatio: HookesLawConstants.springAspectRatio,
    leftEndLength: HookesLawConstants.springLeftEndLength,
    rightEndLength: HookesLawConstants.springRightEndLength,
    xScale: 2.5,
    lineWidth: 5,
  );
}

const double sceneSelectionSpringScale = 0.3;

Size sceneSelectionSpringSize(ParametricSpringGeometry geometry) {
  final yRadius = HookesLawConstants.springRadius * HookesLawConstants.springAspectRatio;
  return Size(
    geometry.rightTipX * sceneSelectionSpringScale,
    (yRadius * 2 + geometry.lineWidth) * sceneSelectionSpringScale,
  );
}

/// Draws one icon spring in local coordinates, origin at the left end on the axis.
void paintSceneSelectionSpring(Canvas canvas, ParametricSpringGeometry geometry) {
  final (back, front) = geometry.toPaths();
  final yRadius = HookesLawConstants.springRadius * HookesLawConstants.springAspectRatio;
  Paint stroke(List<Color> colors, List<double> stops) {
    return Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, -yRadius),
        Offset(0, yRadius),
        colors,
        stops,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = geometry.lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  canvas.drawPath(
    back,
    stroke(
      const [IntroColors.iconMiddle, IntroColors.iconBack, IntroColors.iconMiddle],
      const [0, 0.5, 1],
    ),
  );
  canvas.drawPath(
    front,
    stroke(
      const [
        IntroColors.iconMiddle,
        IntroColors.iconFront,
        IntroColors.iconFront,
        IntroColors.iconMiddle,
      ],
      const [0, 0.35, 0.65, 1],
    ),
  );
}

void _paintHinge(Canvas canvas, double pivotLeft) {
  const pivotW = 26.0;
  const pivotH = 25.0;
  final pivot = Path()
    ..moveTo(pivotLeft, -0.25 * pivotH)
    ..lineTo(pivotLeft + pivotW, -0.5 * pivotH)
    ..lineTo(pivotLeft + pivotW, 0.5 * pivotH)
    ..lineTo(pivotLeft, 0.25 * pivotH)
    ..close();
  canvas.drawPath(pivot, Paint()..color = IntroColors.hinge);
  canvas.drawPath(
    pivot,
    Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF000000),
  );
  final pin = Offset(pivotLeft + 10, 0);
  canvas.drawCircle(pin, 3, Paint()..color = const Color(0xFFFFFFFF));
  canvas.drawCircle(
    pin,
    3,
    Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF000000),
  );
  canvas.drawCircle(pin, 1.35, Paint()..color = const Color(0xFF000000));

  const bodyH = 40.0;
  const bodyW = 9.0;
  final theta = math.atan((0.5 * bodyH) / bodyW);
  final radius = (0.5 * bodyH) / math.sin(theta);
  final bodyLeft = pivotLeft + pivotW - 1;
  final body = Path()
    ..addArc(
      Rect.fromCircle(center: Offset(bodyLeft, 0), radius: radius),
      -theta,
      2 * theta,
    )
    ..lineTo(bodyLeft, 0.5 * bodyH)
    ..lineTo(bodyLeft, -0.5 * bodyH)
    ..close();
  canvas.drawPath(body, Paint()..color = IntroColors.hinge);
  canvas.drawPath(
    body,
    Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF000000),
  );

  // `HingeNode` specular highlight: two arcs, scale 0.85, inset 3 px from the body.
  final highlight = Path()
    ..addArc(Rect.fromCircle(center: const Offset(0, 4), radius: 6), -0.75 * math.pi, 0.5 * math.pi)
    ..addArc(Rect.fromCircle(center: const Offset(0, -4), radius: 6), 0.25 * math.pi, 0.5 * math.pi)
    ..close();
  final highlightBounds = highlight.getBounds();
  canvas.save();
  canvas.translate(bodyLeft + 3, -0.5 * bodyH + 3);
  canvas.translate(-highlightBounds.left * 0.85, -highlightBounds.top * 0.85);
  canvas.scale(0.85);
  canvas.drawPath(highlight, Paint()..color = const Color(0xFFFFFFFF));
  canvas.restore();
}
