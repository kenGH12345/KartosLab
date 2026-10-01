/// [MSS] `MySolarSystemColors.ts` default profile only (no projector).
library;

import 'package:flutter/material.dart';

class MySolarSystemColors {
  MySolarSystemColors._();

  static const Color background = Color(0xFF000000);
  static const Color panel = Color(0xFF282828);
  static const Color foreground = Color(0xFFFFFFFF);

  /// [KEPLER-SECONDARY] PhetColorScheme.VELOCITY
  static const Color velocity = Color.fromARGB(255, 50, 255, 50);

  /// [KEPLER-SECONDARY] PhetColorScheme.GRAVITATIONAL_FORCE
  static const Color gravity = Color.fromARGB(255, 50, 130, 215);

  /// [Kepler二次] PhetColorScheme.PHET_LOGO_BLUE
  static const Color playBlue = Color.fromARGB(255, 106, 206, 245);

  /// [Kepler二次] PhetColorScheme.RESET_ALL_BUTTON_BASE_COLOR
  static const Color resetOrange = Color.fromARGB(255, 247, 151, 34);

  /// [MSS] yellow / magenta / cyan / green
  static const List<Color> bodyColors = [
    Color(0xFFFFFF00),
    Color(0xFFFF00FF),
    Color(0xFF00FFFF),
    Color(0xFF008000),
  ];

  static Color bodyColor(int index) {
    final i = (index - 1).clamp(0, bodyColors.length - 1);
    return bodyColors[i];
  }
}
