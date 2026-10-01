import 'package:flutter/material.dart';

/// Source-explicit colors for Balancing Act Intro.
abstract final class BaColors {
  // SkyNode defaults
  static const Color skyTop = Color.fromRGBO(1, 172, 228, 1);
  static const Color skyBottom = Color.fromRGBO(208, 236, 251, 1);

  // GroundNode defaults
  static const Color groundTop = Color.fromRGBO(144, 199, 86, 1);
  static const Color groundBottom = Color.fromRGBO(103, 162, 87, 1);

  // FulcrumNode
  static const Color fulcrumFill = Color.fromRGBO(240, 240, 0, 1);

  // PlankNode
  static const Color plankFill = Color.fromRGBO(243, 203, 127, 1);

  // AttachmentBarNode
  static const Color attachmentBarFill = Color.fromRGBO(200, 200, 200, 1);
  static const Color attachmentBarStroke = Color.fromRGBO(50, 50, 50, 1);
  static const Color pivotFill = Color.fromRGBO(220, 220, 220, 1);

  // Panel
  static const Color panelFill = Color.fromRGBO(240, 240, 240, 1);

  // LevelIndicatorNode
  static const Color levelFill = Color.fromRGBO(173, 255, 47, 1);
  static const Color nonLevelFill = Color.fromRGBO(230, 230, 230, 1);

  // Column body gradient stops (LevelSupportColumnNode)
  static const Color column0 = Color(0xFFBFBEBF);
  static const Color column1 = Color(0xFFCECECE);
  static const Color column2 = Color(0xFFADAFAD);
  static const Color column3 = Color(0xFF979696);

  // Force vector
  static const Color forceArrow = Color.fromRGBO(0, 180, 0, 1);

  // BrickStackNode fill
  static const Color brickFill = Color.fromRGBO(205, 38, 38, 1);

  // RotatingRulerNode
  static const Color rulerFill = Color.fromRGBO(236, 225, 113, 0.5);

  // PositionMarkerNode
  static const Color positionMark = Color.fromRGBO(255, 153, 0, 1);
}
