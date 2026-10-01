import 'package:flutter/material.dart';

/// Colors from `js/common/CollisionLabColors.js`.
class CollisionLabColors {
  CollisionLabColors._();

  static const Color accent = Color(0xFF166534);
  static const Color screenBackground = Color.fromRGBO(244, 250, 255, 1);
  static const Color gridBackground = Color.fromRGBO(255, 254, 255, 1);
  static const Color majorGridline = Color.fromRGBO(212, 212, 212, 1);
  static const Color minorGridline = Color.fromRGBO(225, 225, 225, 1);
  static const Color tickLine = Color.fromRGBO(220, 219, 220, 1);
  static const Color reflectingBorder = Color.fromRGBO(41, 41, 128, 1);
  static const Color nonReflectingBorder = Colors.black;
  static const Color panelStroke = Color.fromRGBO(190, 190, 190, 1);
  static const Color panelFill = Color.fromRGBO(240, 240, 240, 1);

  static const List<Color> ballColors = [
    Color.fromRGBO(37, 221, 222, 1),
    Color.fromRGBO(255, 37, 173, 1),
    Color.fromRGBO(149, 27, 235, 1),
    Color.fromRGBO(255, 90, 0, 1),
    Color.fromRGBO(247, 248, 16, 1),
  ];

  static const Color velocityVectorFill = Color(0xFF1E90FF);
  static const Color momentumVectorFill = Color(0xFFD32F2F);
  static const Color totalMomentumVectorFill = Colors.black;
  static const Color centerOfMassFill = Color.fromRGBO(70, 70, 70, 1);
  static const Color changeInMomentumDashed = Color.fromRGBO(182, 181, 182, 1);
  static const Color highlightedNumberDisplay = Color(0xFFF9E444);
  static const Color restartButton = Color(0xFFB3E5FC);
  static const Color returnBallsButton = Color(0xFFF9E444);
  static const Color scaleBar = Colors.black;
}
