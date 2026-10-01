import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../../model/parallel_system.dart';
import '../../model/series_system.dart';
import '../../model/spring.dart';
import 'systems_paint.dart';
import 'systems_view_properties.dart';

double systemsX(double meters) =>
    HookesLawConstants.wallWidth + HookesLawConstants.unitDisplacementX * meters;

class ParallelScenePainter extends CustomPainter {
  ParallelScenePainter({
    required this.system,
    required this.properties,
    required this.grippersOpen,
  });

  final ParallelSystem system;
  final SystemsViewProperties properties;
  final bool grippersOpen;

  static double get wallHeight => HookesLawConstants.parallelWallHeight;

  static double get axisY => wallHeight / 2;

  static double get topSpringY => wallHeight * HookesLawConstants.parallelTopSpringFraction;

  static double get bottomSpringY => wallHeight - topSpringY;

  /// `appliedForceVectorNode.bottom = topSpring.y - 80`. Tail is the node center.
  static double get appliedForceBottom =>
      topSpringY - HookesLawConstants.parallelForceAboveTopSpring;

  static double get totalForceY =>
      appliedForceBottom - HookesLawConstants.vectorHeadWidth / 2;

  /// `topComponent.centerY = total.top`.
  static double get topComponentY => totalForceY - HookesLawConstants.vectorHeadWidth / 2;

  /// `bottomComponent.centerY = total.bottom`.
  static double get bottomComponentY => totalForceY + HookesLawConstants.vectorHeadWidth / 2;

  static double get displacementTailY =>
      bottomSpringY +
      HookesLawConstants.introDisplacementVectorGap +
      HookesLawConstants.vectorHeadWidth / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = HookesLawConstants.unitDisplacementX;
    final equivalent = system.equivalentSpring;
    final top = system.topSpring;
    final bottom = system.bottomSpring;
    final rightX = systemsX(equivalent.right);
    final equilibriumX = systemsX(equivalent.equilibriumX);
    final armX = HookesLawConstants.wallWidth + unit * system.roboticArm.right;

    if (properties.equilibriumPositionVisible) {
      paintSystemsDash(canvas, equilibriumX, wallHeight);
    }
    paintSystemsArm(
      canvas,
      armOriginX: armX,
      handX: rightX,
      axisY: axisY,
      grippersOpen: grippersOpen,
    );
    _spring(canvas, top, topSpringY, SystemsColors.spring1Front, SystemsColors.spring1Middle, SystemsColors.spring1Back);
    _spring(canvas, bottom, bottomSpringY, SystemsColors.spring2Front, SystemsColors.spring2Middle, SystemsColors.spring2Back);
    paintSystemsWall(canvas, wallHeight);
    canvas.drawLine(
      Offset(rightX, topSpringY - HookesLawConstants.trussOverlap),
      Offset(rightX, bottomSpringY + HookesLawConstants.trussOverlap),
      Paint()
        ..color = const Color(0xFF000000)
        ..strokeWidth = HookesLawConstants.trussLineWidth,
    );
    paintSystemsNib(canvas, rightX, axisY, const Color(0xFF000000));

    if (properties.showComponentSpringForces) {
      paintSystemsForceArrow(
        canvas,
        Offset(systemsX(top.right), topComponentY),
        top.springForce,
        SystemsColors.spring1Middle,
      );
      paintSystemsForceArrow(
        canvas,
        Offset(systemsX(bottom.right), bottomComponentY),
        bottom.springForce,
        SystemsColors.spring2Middle,
      );
    }
    if (properties.appliedForceVectorVisible) {
      paintSystemsForceArrow(
        canvas,
        Offset(rightX, totalForceY),
        equivalent.appliedForce,
        SystemsColors.appliedForce,
      );
    }
    if (properties.showTotalSpringForce) {
      paintSystemsForceArrow(
        canvas,
        Offset(rightX, totalForceY),
        equivalent.springForce,
        SystemsColors.totalSpringForce,
      );
    }
    if (properties.displacementVectorVisible) {
      paintSystemsDisplacementArrow(
        canvas,
        Offset(equilibriumX, displacementTailY),
        equivalent.displacement,
      );
    }
  }

  void _spring(Canvas canvas, Spring spring, double y, Color front, Color middle, Color back) {
    paintColoredSpring(
      canvas,
      origin: Offset(systemsX(spring.left), y),
      lengthMeters: spring.length,
      springConstant: spring.springConstant,
      minK: spring.springConstantRange.min,
      loops: HookesLawConstants.parallelSpringLoops,
      front: front,
      middle: middle,
      back: back,
    );
  }

  @override
  bool shouldRepaint(covariant ParallelScenePainter oldDelegate) => true;
}

class SeriesScenePainter extends CustomPainter {
  SeriesScenePainter({
    required this.system,
    required this.properties,
    required this.grippersOpen,
  });

  final SeriesSystem system;
  final SystemsViewProperties properties;
  final bool grippersOpen;

  static double get wallHeight => HookesLawConstants.wallHeight;

  static double get axisY => wallHeight / 2;

  /// `leftSpringForceVectorNode.bottom = leftSpring.y - 65`.
  static double get leftForceBottom => axisY - HookesLawConstants.seriesForceAboveAxis;

  static double get leftForceY => leftForceBottom - HookesLawConstants.vectorHeadWidth / 2;

  /// `rightSpringForceVectorNode.bottom = leftSpringForceVectorNode.top - 10`.
  static double get rightForceBottom =>
      (leftForceY - HookesLawConstants.vectorHeadWidth / 2) -
      HookesLawConstants.seriesComponentStackGap;

  static double get rightForceY => rightForceBottom - HookesLawConstants.vectorHeadWidth / 2;

  static double get displacementTailY =>
      axisY +
      HookesLawConstants.introDisplacementVectorGap +
      HookesLawConstants.vectorHeadWidth / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = HookesLawConstants.unitDisplacementX;
    final left = system.leftSpring;
    final right = system.rightSpring;
    final equivalent = system.equivalentSpring;
    final rightEndX = systemsX(right.right);
    final junctionX = systemsX(left.right);
    final equilibriumX = systemsX(equivalent.equilibriumX);
    final armX = HookesLawConstants.wallWidth + unit * system.roboticArm.right;

    if (properties.equilibriumPositionVisible) {
      paintSystemsDash(canvas, equilibriumX, wallHeight);
    }
    paintSystemsArm(
      canvas,
      armOriginX: armX,
      handX: rightEndX,
      axisY: axisY,
      grippersOpen: grippersOpen,
    );
    paintColoredSpring(
      canvas,
      origin: Offset(systemsX(left.left), axisY),
      lengthMeters: left.length,
      springConstant: left.springConstant,
      minK: left.springConstantRange.min,
      loops: HookesLawConstants.seriesSpringLoops,
      front: SystemsColors.spring1Front,
      middle: SystemsColors.spring1Middle,
      back: SystemsColors.spring1Back,
    );
    paintColoredSpring(
      canvas,
      origin: Offset(systemsX(right.left), axisY),
      lengthMeters: right.length,
      springConstant: right.springConstant,
      minK: right.springConstantRange.min,
      loops: HookesLawConstants.seriesSpringLoops,
      front: SystemsColors.spring2Front,
      middle: SystemsColors.spring2Middle,
      back: SystemsColors.spring2Back,
    );
    paintSystemsWall(canvas, wallHeight);
    paintSystemsNib(canvas, rightEndX, axisY, SystemsColors.spring2Middle);

    if (properties.showComponentSpringForces) {
      paintSystemsForceArrow(
        canvas,
        Offset(junctionX, leftForceY),
        left.springForce,
        SystemsColors.spring1Middle,
      );
      // Source uses spring2's yellow for the left spring's applied-force arrow.
      paintSystemsForceArrow(
        canvas,
        Offset(junctionX, leftForceY),
        left.appliedForce,
        SystemsColors.spring2Middle,
      );
      paintSystemsForceArrow(
        canvas,
        Offset(rightEndX, rightForceY),
        right.springForce,
        SystemsColors.spring2Middle,
      );
    }
    if (properties.appliedForceVectorVisible) {
      paintSystemsForceArrow(
        canvas,
        Offset(rightEndX, rightForceY),
        equivalent.appliedForce,
        SystemsColors.appliedForce,
      );
    }
    if (properties.showTotalSpringForce) {
      paintSystemsForceArrow(
        canvas,
        Offset(rightEndX, rightForceY),
        equivalent.springForce,
        SystemsColors.totalSpringForce,
      );
    }
    if (properties.displacementVectorVisible) {
      paintSystemsDisplacementArrow(
        canvas,
        Offset(equilibriumX, displacementTailY),
        equivalent.displacement,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SeriesScenePainter oldDelegate) => true;
}
