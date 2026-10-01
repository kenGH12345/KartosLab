import 'package:flutter/material.dart';

/// Projectile Motion 色板（Constants.ts / ScreenView 提取）
abstract final class PmColors {
  static const Color background = Colors.white;
  static const Color accent = Color(0xFFFF8C00);

  // 背景
  static const Color skyTop = Color(0xFF02ACE4);
  static const Color skyBottom = Color(0xFFCFECFC);
  static const Color road = Color(0xFF4D4D4B);

  // 炮
  static const Color cannonCylinder = Color(0xFF3D3D3D);
  static const Color heightIndicator = Color(0xFFFF6B00);
  static const Color angleIndicator = Color(0xFFFFD600);

  // 轨迹
  static const Color trajectoryPath = Colors.black;
  static const Color trajectoryDot = Colors.black;

  // 向量（Constants:93-114 图标色；FBD fill:'black'）
  static const Color velocityVectorFill = Color(0xFF32FF32); // rgb(50,255,50)
  static const Color accelerationVectorFill = Color(0xFFFFFF32); // rgb(255,255,50)
  static const Color forceVectorFill = Color(0xFF000000);
  static const Color apexDot = Color(0xFF32FF32); // TrajectoryNode DOT_GREEN

  // 面板（Constants:143-166）
  static const Color panelFill = Color(0xFFFFEEDA); // rgb(255,238,218)
  static const Color initialValuePanelFill = Color(0xFFEBEBEB); // rgb(235,235,235)
  static const Color rightSidePanelFill = Color(0xFFFFEEDA);
  static const Color separator = Color(0xFF888888);

  // 工具（MeasuringTapeNode / DataProbeNode）
  static const Color tapeLine = Color(0xFF808080); // lineColor: 'gray'
  static const Color tapeCrosshair = Color(0xFFE05F20); // rgb(224, 95, 32)
  static const Color tipCircle = Color(0x1A000000); // rgba(0,0,0,0.1)
  static const Color targetFill = Color(0xFFFF2222);
  /// DataProbeNode OPAQUE_BLUE（fill，再乘 opacity 0.8）
  static const Color dataProbeOpaqueBlue = Color(0xFF294296);

  // Painter 细节色（CannonNode:57-68 / BackgroundNode / VectorNode）
  static const Color cannonBrightGray = Color(0xFFE6E6E6); // rgb(230,230,230)
  static const Color cannonDarkGray = Color(0xFF676767); // rgb(103,103,103)
  static const Color flameOuter = Color(0xFFFF8C00);
  static const Color flameInner = Color(0xFFFFF200);
  static const Color cueArrowFill = Color(0xFF64C8FF); // rgb(100,200,255)
  static const Color labelBackground = Color(0x99FFFFFF); // rgba(255,255,255,0.6)
  static const Color grass = Color(0xFF00AD4E);
  static const Color roadDashedLine = Color(0xFFEBEA30);
  static const Color numberDisplayBackground = Color(0xFFFFFFFF);
  static const Color numberDisplayStroke = Color(0xFFD3D3D3); // lightGray
  static const Color fireButtonBase = Color(0xFFEA2126); // rgb(234,33,38)
}
