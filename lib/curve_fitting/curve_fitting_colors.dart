import 'package:flutter/material.dart';

/// Colors from PhET Curve Fitting (`CurveFittingConstants.js`, Screen bg).
class CurveFittingColors {
  CurveFittingColors._();

  /// Screen background `rgb(187, 230, 246)` — also suitable AppBar accent.
  static const Color accent = Color.fromRGBO(187, 230, 246, 1);
  static const Color screenBackground = accent;

  /// Panel fill `rgb(254, 235, 214)`.
  static const Color panelBackground = Color.fromRGBO(254, 235, 214, 1);

  /// Point fill `rgb(252, 151, 64)`.
  static const Color pointFill = Color.fromRGBO(252, 151, 64, 1);

  /// Curve / equation blue `rgb(19, 52, 248)`.
  static const Color blue = Color.fromRGBO(19, 52, 248, 1);

  static const Color gray = Color.fromRGBO(107, 107, 107, 1);
  static const Color lightGray = Color.fromRGBO(201, 201, 202, 1);

  static const Color pointStroke = Colors.black;
  static const Color graphBackground = Colors.white;
  static const Color graphBorder = Color.fromRGBO(214, 223, 226, 1);

  static const Color bucket = Color.fromRGBO(65, 63, 117, 1);
}
