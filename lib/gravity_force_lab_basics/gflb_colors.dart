import 'package:flutter/material.dart';

/// Colors from PhET GFLB / Mass / force arrows.
class GflbColors {
  GflbColors._();

  /// Screen background `#ffffc2`.
  static const Color screenBackground = Color(0xFFFFFFC2);

  /// AppBar accent — same warm field color.
  static const Color accent = screenBackground;

  static const Color mass1Base = Color(0xFF0000FF);
  static const Color mass2Base = Color(0xFFFF0000);

  static const Color forceArrow1 = Color(0xFF6666FF);
  static const Color forceArrow2 = Color(0xFFFF6666);

  static const Color distanceArrow = Color(0xFFBFBFBF);
  static const Color panelFill = Color(0xFFF1F1F2);
  static const Color rope = Color(0xFF666666);
  static const Color shadow = Color(0xFF777777);
  static const Color forceLabel = Colors.black;
  static const Color forceLabelBackground = Color(0x4DFFFFC2);
}
