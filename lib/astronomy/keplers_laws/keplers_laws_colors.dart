/// Colors from KeplersLawsColors + SolarSystemCommonColors (default profile only).
///
/// [已确认] `js/common/KeplersLawsColors.ts`
/// [已确认] `solar-system-common/js/SolarSystemCommonColors.ts`
library;

import 'package:flutter/material.dart';

class KeplersLawsColors {
  KeplersLawsColors._();

  static const Color foreground = Colors.white;
  static const Color background = Colors.black;

  /// panelFill default Color(40,40,40)
  static const Color panelFill = Color.fromARGB(255, 40, 40, 40);

  /// brighter(0.65) of panel fill — [已确认] panelStroke default
  static const Color panelStroke = Color.fromARGB(255, 61, 61, 61);

  static const Color orbit = Color(0xFFFF00FF); // fuchsia
  static const Color area = Color(0xFFFF00FF);
  static const Color sun = Color(0xFFFFFF00); // yellow
  static const Color planet = Color(0xFFFF00FF); // magenta

  static const Color semiMajorAxis = Color(0xFFFF9500);
  static const Color semiMinorAxis = Color(0xFFB0EE86);
  static const Color focalDistance = Color(0xFFE6C7FF);
  static const Color period = Color(0xFF00FFFF); // cyan
  static const Color distances = Color(0xFFCCB285);
  static const Color foci = Color(0xFF29ABE2);
  static const Color periapsis = Color(0xFFFFD700); // gold
  static const Color apoapsis = Color(0xFF00FFFF); // cyan
  static const Color targetOrbit = Color(0xFF808080);
  static const Color timeDisplayBackground = Color(0xFFAAFFFF);

  /// [已确认] PhetColorScheme.VELOCITY = Color(50, 255, 50)
  static const Color velocity = Color.fromARGB(255, 50, 255, 50);

  /// [已确认] PhetColorScheme.GRAVITATIONAL_FORCE = Color(50, 130, 215)
  static const Color gravity = Color.fromARGB(255, 50, 130, 215);

  static const Color warning = Colors.white;

  /// [已确认] PhetColorScheme.RESET_ALL_BUTTON_BASE_COLOR = Color(247, 151, 34)
  static const Color resetOrange = Color.fromARGB(255, 247, 151, 34);

  /// [已确认] PhetColorScheme.PHET_LOGO_BLUE = Color(106, 206, 245)
  static const Color playBlue = Color.fromARGB(255, 106, 206, 245);

  /// [已确认] ORBITAL_AREA_COLORS
  static const List<Color> orbitalAreaColors = [
    Color(0xFFFF92FF),
    Color(0xFFFF6DFF),
    Color(0xFFFF24FF),
    Color(0xFFC800C8),
    Color(0xFFA400A4),
    Color(0xFF80007F),
  ];
}
