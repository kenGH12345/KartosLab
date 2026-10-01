import 'package:flutter/material.dart';

/// Colors from EnergySkateParkColors.ts + PhetColorScheme / classic ESP bar palette.
///
/// Note: current scenery-phet remaps KE→green / Total→purple for a11y patterns.
/// Bar/pie here keep the classic ESP teaching palette (yellow / blue / red / green)
/// that matches user expectations and historical ESP screenshots.
class EspColors {
  EspColors._();

  static const Color accent = Color(0xFF0E7490);

  /// KE — yellow-ish (classic ESP bar)
  static const Color kineticEnergy = Color(0xFFF7E22A);

  /// PE — blue (PhetColorScheme.GRAVITATIONAL_POTENTIAL_ENERGY ≈ 41,98,255)
  static const Color potentialEnergy = Color(0xFF2962FF);

  /// Thermal — red / RED_COLORBLIND
  static const Color thermalEnergy = Color(0xFFFF5500);

  /// Total — green (classic ESP bar)
  static const Color totalEnergy = Color(0xFF41B04B);

  static const Color pathFill = Color.fromRGBO(220, 175, 250, 1);
  static const Color pathStroke = Colors.black;
  static const Color haloFill = Color.fromRGBO(225, 231, 86, 0.75);

  static const Color roadFill = Color(0xFF808080);
  static const Color roadLine = Colors.black;

  static const Color referenceLineFill = Color.fromRGBO(74, 133, 208, 1);
  static const Color panelFill = Color(0xFFF0F0F0);
  static const Color panelStroke = Color(0xFFABABAB);
  static const Color chartPanelFill = Colors.white;

  static const Color skyTop = Color(0xFF87CEEB);
  static const Color skyBottom = Color(0xFFE8F4FC);
  static const Color ground = Color(0xFF5D8A3E);
  static const Color groundLine = Color(0xFF3D5A27);

  static const Color skaterBody = Color(0xFFE85D04);
  static const Color skaterOutline = Color(0xFF1E3A5F);
  static const Color particleCircle = Colors.red;
  static const Color particleDot = particleCircle;
  static const Color referenceLineStroke = Colors.black;

  static const Color screenBackground = Color(0xFFF4FAFF);
  static const Color gridLine = Color(0xFFD4D4D4);
  static const Color radioSelected = Color.fromRGBO(87, 178, 226, 1);
}
