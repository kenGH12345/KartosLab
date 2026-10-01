import 'package:flutter/material.dart';

/// Colors from PhET `PlinkoProbabilityConstants.js`.
class PlinkoColors {
  PlinkoColors._();

  static const Color background = Color.fromRGBO(186, 231, 249, 1);
  static const Color ball = Color.fromRGBO(237, 28, 36, 1);
  static const Color ballHighlight = Colors.white;
  static const Color peg = Color.fromRGBO(115, 99, 87, 1);

  static const Color controlPanelBackground = Color.fromRGBO(255, 245, 238, 1);
  static const Color panelBackground = Colors.white;

  static const Color sampleFont = Color.fromRGBO(237, 28, 36, 1);
  static const Color theoreticalFont = Colors.blue;

  static const Color histogramBarFill = Color.fromRGBO(237, 28, 36, 1);
  static const Color histogramBarStroke = Color.fromRGBO(193, 39, 45, 1);
  static const Color binomialBarStroke = Colors.blue;

  static const Color cylinderBase = Color.fromRGBO(171, 189, 196, 0.5);
  static const Color sideCylinderStroke = Color.fromRGBO(120, 120, 100, 1);
  static const Color topCylinderStroke = Color.fromRGBO(120, 120, 100, 1);
  static const Color topCylinderFill = Color.fromRGBO(212, 230, 238, 1);

  /// Approximate board fill (Board.js uses a tan-ish panel).
  static const Color boardFill = Color.fromRGBO(222, 184, 135, 1);
}
