import 'package:flutter/material.dart';

/// Colors from `PendulumLabConstants.js`.
class PlColors {
  PlColors._();

  static const Color background = Color.fromRGBO(255, 255, 255, 1);
  static const Color panelFill = Color.fromRGBO(230, 230, 230, 1);
  static const Color firstPendulum = Color.fromRGBO(0, 0, 255, 1);
  static const Color secondPendulum = Color.fromRGBO(255, 0, 0, 1);

  static const Color accelerationArrow = Color.fromRGBO(255, 253, 56, 1);
  static const Color velocityArrow = Color.fromRGBO(41, 253, 46, 1);

  static const Color kineticEnergy = Color.fromRGBO(31, 202, 46, 1);
  static const Color potentialEnergy = Color.fromRGBO(55, 132, 213, 1);
  static const Color thermalEnergy = Color.fromRGBO(253, 87, 31, 1);
  static const Color totalEnergy = Color.fromRGBO(0, 0, 0, 1);

  static const Color sliderTrack = Color.fromRGBO(50, 145, 184, 1);
  static const Color thumbFill = Color(0xFF00C4DF);
  static const Color thumbFillHighlighted = Color(0xFF71EDFF);

  static const Color rectangularButtonBase = Color.fromRGBO(230, 231, 232, 1);
  static const Color stopButtonBase = Color.fromRGBO(231, 232, 233, 1);

  static const Color playPauseFace = Color(0xFFFED700);
  static const Color playPauseEdge = Color(0xFFCC9900);

  static const Color resetAll = Color.fromRGBO(247, 151, 34, 1);

  static const Color rulerFill = Color.fromRGBO(237, 225, 121, 1);
  static const Color separator = Color.fromRGBO(160, 160, 160, 1);

  static const Color accent = Color(0xFF1D4ED8);

  static const List<Color> pendulumColors = [firstPendulum, secondPendulum];

  /// PhET `Color.colorUtilsBrighter(amount)` — lerp toward white.
  static Color brighter(Color color, double amount) {
    int ch(double component) =>
        (component * 255.0 + (255 - component * 255.0) * amount)
            .round()
            .clamp(0, 255);
    return Color.fromARGB(
      (color.a * 255.0).round().clamp(0, 255),
      ch(color.r),
      ch(color.g),
      ch(color.b),
    );
  }
}
