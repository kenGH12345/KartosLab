import 'package:flutter/material.dart';

/// Source: `js/common/MPColors.ts`
abstract final class MpColors {
  static const Color screenBackground = Color.fromRGBO(180, 205, 255, 1);
  static const Color panelFill = Color.fromRGBO(238, 238, 238, 1);

  static const Color atomA = Color.fromRGBO(255, 255, 90, 1);
  static const Color atomB = Color.fromRGBO(0, 255, 0, 1);
  static const Color atomC = Color.fromRGBO(255, 175, 175, 1);
  static const Color bond = Color.fromRGBO(140, 140, 140, 1);

  static const Color bondDipole = Colors.black;
  static const Color molecularDipole = Color.fromRGBO(255, 200, 0, 1);

  static const Color plate = Color.fromRGBO(192, 192, 192, 1);

  static const double surfaceAlpha = 0.72;

  static const Color surfaceRwbRed = Color.fromRGBO(255, 0, 0, 1);
  static const Color surfaceRwbWhite = Color.fromRGBO(255, 255, 255, 1);
  static const Color surfaceRwbBlue = Color.fromRGBO(0, 0, 255, 1);
  static const Color surfaceBwBlack = Colors.black;
  static const Color surfaceBwWhite = Colors.white;

  /// Real-molecule element colors (design overrides where noted).
  static const Color hydrogen = Color(0xFFFFFFFF);
  static const Color boron = Color(0xFFFF1493); // approx Element.B
  static const Color carbon = Color(0xFF444444); // darkened vs Element.C
  static const Color nitrogen = Color(0xFF3050F8);
  static const Color oxygen = Color(0xFFFF0D0D);
  static const Color fluorine = Color(0xFF90E050);
  static const Color chlorine = Color(0xFF1FF01F);
}
