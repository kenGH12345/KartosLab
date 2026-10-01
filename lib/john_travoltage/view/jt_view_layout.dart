import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/john_travoltage_constants.dart';

/// View layout constants from PhET `BackgroundNode` / `AppendageNode` / `ArmNode` / `LegNode` / `JohnTravoltageView`.
abstract final class JtViewLayout {
  static const Color backgroundColor = Color(0xFFE4D8C2);

  static const double layoutWidth = JohnTravoltageConstants.layoutWidth;
  static const double layoutHeight = JohnTravoltageConstants.layoutHeight;

  // BackgroundNode.js
  static const double wallpaperLeft = -1000;
  static const double wallpaperTop = -300;
  static const double wallpaperWidth = 3000;
  static const double wallpaperHeight = 1100;

  static const double windowX = 50;
  static const double windowY = 60;
  static const double windowScale = 0.93;

  static const double floorLeft = -1000;
  static const double floorTop = 440;
  static const double floorWidth = 3000;
  static const double floorHeight = 1100;

  static const double rugX = 110;
  static const double rugY = 446;
  static const double rugScale = 0.58;

  static const double doorX = 513.5;
  static const double doorY = 48;
  static const double doorScale = 0.785;

  static const double bodyX = 260;
  static const double bodyY = 60;
  static const double bodyScale = 0.85;

  // ArmNode.js → AppendageNode(dx, dy, angleOffset)
  static const double armDx = 4;
  static const double armDy = 45;
  static const double armAngleOffset = -0.1;

  // LegNode.js
  static const double legDx = 25;
  static const double legDy = 28;
  static const double legAngleOffset = math.pi / 2 * 0.7;

  // Intrinsic PNG sizes (source images/)
  static const Size armImageSize = Size(112, 68);
  static const Size legImageSize = Size(130, 157);
  static const Size bodyImageSize = Size(238, 513);
  static const Size doorImageSize = Size(309, 500);
  static const Size windowImageSize = Size(180, 183);
  static const Size rugImageSize = Size(834, 94);

  // ResetAllButton in JohnTravoltageView.js
  static const double resetRadius = 23;
  static const double resetInset = 8;

  // AppendageNode border
  static const Color borderColor = Color(0xFF008000); // 'green'
  static const double borderLineWidth = 2;
  static const double borderCornerRadius = 10;
  static const List<double> borderDash = [10, 10];

  // ElectronChargeNode default radius (visual); model Electron.radius=8 is clearance.
  static const double electronChargeRadius = 10;

  // SparkNode
  static const int sparkSegmentCount = 10;
  static const double sparkWhiteWidth = 4;
  static const double sparkBlueWidth = 1;
}
