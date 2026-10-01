import 'package:flutter/material.dart';

/// Colors from PhET `EFACConstants.ts`.
class EfacColors {
  EfacColors._();

  static const Color accent = Color(0xFFE67E22);

  static const Color screenBackground = Color.fromARGB(255, 249, 244, 205);
  static const Color controlPanelBackground = Color.fromARGB(255, 229, 236, 255);
  static const Color controlPanelOutline = Color.fromARGB(255, 120, 120, 120);
  static const Color clockControlBackground = Color.fromARGB(255, 160, 160, 160);

  static const Color waterOpaque = Color.fromARGB(255, 175, 238, 238);
  static const Color waterInBeaker = Color.fromARGB(178, 175, 238, 238); // ≈0.7
  static const Color waterSteam = Color(0xFFFFFFFF);
  static const Color oliveOilInBeaker = Color.fromARGB(255, 255, 210, 0);
  static const Color oliveOilSteam = Color.fromARGB(255, 230, 230, 230);

  static const Color temperatureSensorInactive = Colors.white;
  static const Color flameOrange = Color(0xFFFFA500);
  static const Color iceBlue = Color(0xFF87CEFA);
}
