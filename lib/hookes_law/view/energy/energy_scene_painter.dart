import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../../model/spring.dart';
import '../intro/intro_play_painter.dart';
import '../systems/systems_paint.dart';

/// Play-area paint for the Energy spring. Local origin is the wall's top-left.
/// Attachment is `wallWidth` on the axis. Force arrows use
/// [HookesLawConstants.energyUnitForceX] (0.4), not the Intro 1.45 scale.
class EnergyScenePainter extends CustomPainter {
  EnergyScenePainter({
    required this.spring,
    required this.grippersOpen,
    required this.equilibriumVisible,
    required this.appliedForceVisible,
    required this.displacementVisible,
    required this.armRight,
  });

  final Spring spring;
  final bool grippersOpen;
  final bool equilibriumVisible;
  final bool appliedForceVisible;
  final bool displacementVisible;
  final double armRight;

  static double get axisY => HookesLawConstants.wallHeight / 2;

  static double get attachmentX => HookesLawConstants.wallWidth;

  static double get forceTailY =>
      axisY - HookesLawConstants.energySceneForceAboveAxis - HookesLawConstants.vectorHeadWidth / 2;

  static double get displacementTailY =>
      axisY + HookesLawConstants.introDisplacementVectorGap + HookesLawConstants.vectorHeadWidth / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = HookesLawConstants.unitDisplacementX;
    final origin = Offset(attachmentX, axisY);
    final springRight = origin.dx + unit * spring.right;
    final equilibriumX = origin.dx + unit * spring.equilibriumX;
    final armX = origin.dx + unit * armRight;

    if (equilibriumVisible) {
      paintSystemsDash(canvas, equilibriumX, HookesLawConstants.wallHeight);
    }
    paintSystemsArm(
      canvas,
      armOriginX: armX,
      handX: springRight,
      axisY: axisY,
      grippersOpen: grippersOpen,
    );
    paintColoredSpring(
      canvas,
      origin: origin,
      lengthMeters: spring.length,
      springConstant: spring.springConstant,
      minK: spring.springConstantRange.min,
      loops: HookesLawConstants.singleSpringLoops,
      front: IntroColors.springFront,
      middle: IntroColors.springMiddle,
      back: IntroColors.springBack,
    );
    paintSystemsWall(canvas, HookesLawConstants.wallHeight);
    paintSystemsNib(canvas, springRight, axisY, IntroColors.springMiddle);
    if (appliedForceVisible) {
      _paintForce(
        canvas,
        Offset(springRight, forceTailY),
        spring.appliedForce,
      );
    }
    if (displacementVisible) {
      paintSystemsDisplacementArrow(
        canvas,
        Offset(equilibriumX, displacementTailY),
        spring.displacement,
      );
    }
  }

  @override
  bool shouldRepaint(covariant EnergyScenePainter oldDelegate) => true;

  void _paintForce(Canvas canvas, Offset tail, double newtons) {
    if (newtons == 0) {
      return;
    }
    final length = newtons * HookesLawConstants.energyUnitForceX;
    final path = _arrow(length);
    canvas.save();
    canvas.translate(tail.dx, tail.dy);
    canvas.drawPath(path, Paint()..color = IntroColors.appliedForce);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();
  }
}

Path _arrow(double length) {
  final mag = length.abs();
  final head = math.min(HookesLawConstants.vectorHeadHeight, mag);
  final tail = HookesLawConstants.forceTailWidth / 2;
  final headHalf = HookesLawConstants.vectorHeadWidth / 2;
  final shaft = math.max(0.0, mag - head);
  final path = Path();
  if (length >= 0) {
    path
      ..moveTo(0, -tail)
      ..lineTo(shaft, -tail)
      ..lineTo(shaft, -headHalf)
      ..lineTo(mag, 0)
      ..lineTo(shaft, headHalf)
      ..lineTo(shaft, tail)
      ..lineTo(0, tail)
      ..close();
  } else {
    path
      ..moveTo(0, -tail)
      ..lineTo(-shaft, -tail)
      ..lineTo(-shaft, -headHalf)
      ..lineTo(-mag, 0)
      ..lineTo(-shaft, headHalf)
      ..lineTo(-shaft, tail)
      ..lineTo(0, tail)
      ..close();
  }
  return path;
}

/// Screen x of the spring attachment. Wall left is [energySystemLeft].
double energyAttachmentX() =>
    HookesLawConstants.energySystemLeft + HookesLawConstants.wallWidth;

/// Screen x of the plot origin: attachment + 225 * equilibriumX.
double energyPlotOriginX(Spring spring) =>
    energyAttachmentX() + HookesLawConstants.unitDisplacementX * spring.equilibriumX;
