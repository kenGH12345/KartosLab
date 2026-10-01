import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../parametric_spring_geometry.dart';
import '../intro/intro_play_painter.dart';

/// spring1 is purple (parallel top, series left). spring2 is yellow.
class SystemsColors {
  const SystemsColors._();

  static const spring1Front = Color.fromRGBO(
    HookesLawConstants.spring1FrontR,
    HookesLawConstants.spring1FrontG,
    HookesLawConstants.spring1FrontB,
    1,
  );
  static const spring1Middle = Color.fromRGBO(
    HookesLawConstants.spring1MiddleR,
    HookesLawConstants.spring1MiddleG,
    HookesLawConstants.spring1MiddleB,
    1,
  );
  static const spring1Back = Color.fromRGBO(
    HookesLawConstants.spring1BackR,
    HookesLawConstants.spring1BackG,
    HookesLawConstants.spring1BackB,
    1,
  );
  static const spring2Front = Color.fromRGBO(
    HookesLawConstants.spring2FrontR,
    HookesLawConstants.spring2FrontG,
    HookesLawConstants.spring2FrontB,
    1,
  );
  static const spring2Middle = Color.fromRGBO(
    HookesLawConstants.spring2MiddleR,
    HookesLawConstants.spring2MiddleG,
    HookesLawConstants.spring2MiddleB,
    1,
  );
  static const spring2Back = Color.fromRGBO(
    HookesLawConstants.spring2BackR,
    HookesLawConstants.spring2BackG,
    HookesLawConstants.spring2BackB,
    1,
  );

  /// Total spring-force arrow. `SpringForceVectorNode` default fill.
  static const totalSpringForce = Color.fromRGBO(0, 0, 255, 1);
  static const appliedForce = Color.fromRGBO(255, 85, 0, 1);
  static const displacement = Color.fromRGBO(0, 180, 0, 1);
  static const equilibrium = Color.fromRGBO(0, 180, 0, 1);
  static const wall = Color.fromRGBO(180, 180, 180, 1);
  static const valueScrim = Color.fromRGBO(255, 255, 255, 0.8);
}

void paintColoredSpring(
  Canvas canvas, {
  required Offset origin,
  required double lengthMeters,
  required double springConstant,
  required double minK,
  required int loops,
  required Color front,
  required Color middle,
  required Color back,
}) {
  final geometry = ParametricSpringGeometry.sample(
    loops: loops,
    pointsPerLoop: HookesLawConstants.springPointsPerLoop,
    radius: HookesLawConstants.springRadius,
    aspectRatio: HookesLawConstants.springAspectRatio,
    leftEndLength: HookesLawConstants.springLeftEndLength,
    rightEndLength: HookesLawConstants.springRightEndLength,
    xScale: ParametricSpringGeometry.xScaleForLength(lengthMeters, loops: loops),
    lineWidth: ParametricSpringGeometry.lineWidthFor(springConstant, minK: minK),
  );
  final (backPath, frontPath) = geometry.toPaths();
  final yRadius = HookesLawConstants.springRadius * HookesLawConstants.springAspectRatio;
  canvas.save();
  canvas.translate(origin.dx, origin.dy);
  canvas.drawPath(backPath, _stroke(geometry.lineWidth, _back(yRadius, middle, back)));
  canvas.drawPath(frontPath, _stroke(geometry.lineWidth, _front(yRadius, middle, front)));
  canvas.restore();
}

Paint _stroke(double width, Shader shader) {
  return Paint()
    ..shader = shader
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
}

Shader _front(double yRadius, Color middle, Color front) {
  return ui.Gradient.linear(
    Offset(0, -yRadius),
    Offset(0, yRadius),
    [middle, front, front, middle],
    const [0, 0.35, 0.65, 1],
  );
}

Shader _back(double yRadius, Color middle, Color back) {
  return ui.Gradient.linear(
    Offset(0, -yRadius),
    Offset(0, yRadius),
    [middle, back, middle],
    const [0, 0.5, 1],
  );
}

void paintSystemsWall(Canvas canvas, double height) {
  final rect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, HookesLawConstants.wallWidth, height),
    const Radius.circular(HookesLawConstants.wallCornerRadius),
  );
  canvas.drawRRect(rect, Paint()..color = SystemsColors.wall);
  canvas.drawRRect(
    rect,
    Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1,
  );
}

void paintSystemsNib(Canvas canvas, double x, double y, Color fill) {
  final rect = RRect.fromRectAndRadius(
    Rect.fromLTWH(
      x,
      y - HookesLawConstants.nibHeight / 2,
      HookesLawConstants.nibWidth,
      HookesLawConstants.nibHeight,
    ),
    const Radius.circular(HookesLawConstants.nibCornerRadius),
  );
  canvas.drawRRect(rect, Paint()..color = fill);
}

void paintSystemsForceArrow(Canvas canvas, Offset tail, double newtons, Color color) {
  if (newtons == 0) {
    return;
  }
  final path = _filledArrow(newtons * HookesLawConstants.unitForceX);
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

void paintSystemsDisplacementArrow(Canvas canvas, Offset tail, double meters) {
  if (meters == 0) {
    return;
  }
  final length = meters * HookesLawConstants.unitDisplacementX;
  canvas.save();
  canvas.translate(tail.dx, tail.dy);
  final paint = Paint()
    ..color = SystemsColors.displacement
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeJoin = StrokeJoin.miter;
  final head = math.min(HookesLawConstants.vectorHeadHeight, length.abs());
  final dir = length.sign;
  final shaftEnd = length - dir * head;
  canvas.drawLine(Offset.zero, Offset(shaftEnd, 0), paint);
  final headPath = Path()
    ..moveTo(shaftEnd, -HookesLawConstants.vectorHeadWidth / 2)
    ..lineTo(length, 0)
    ..lineTo(shaftEnd, HookesLawConstants.vectorHeadWidth / 2);
  canvas.drawPath(headPath, paint);
  canvas.drawLine(
    const Offset(0, -10),
    const Offset(0, 10),
    Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 2,
  );
  canvas.restore();
}

void paintSystemsDash(Canvas canvas, double x, double height) {
  const dash = 3.0;
  const gap = 3.0;
  final paint = Paint()
    ..color = SystemsColors.equilibrium
    ..strokeWidth = 2;
  var y = 0.0;
  while (y < height) {
    final y2 = math.min(y + dash, height);
    canvas.drawLine(Offset(x, y), Offset(x, y2), paint);
    y += dash + gap;
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

/// Re-export so Systems can share the Intro arm without a second geometry.
void paintSystemsArm(
  Canvas canvas, {
  required double armOriginX,
  required double handX,
  required double axisY,
  required bool grippersOpen,
}) {
  paintRoboticArm(
    canvas,
    armOriginX: armOriginX,
    handX: handX,
    axisY: axisY,
    grippersOpen: grippersOpen,
  );
}
