import 'dart:ui';

import '../model/beers_law_constants.dart';

/// View chrome / asset colors for Beer's Law screen (from BLLColors + layout).
abstract final class BeersLawLayout {
  static const Size layoutBounds = BeersLawConstants.layoutBounds;
  static const Color screenBackground = Color(0xFFFFFFFF);
  static const Color panelFill = Color(0xFFF0F0F0); // gray(240)
  static const Color detectorColor = Color.fromARGB(255, 8, 133, 54);
  static const Color cuvetteArrowFill = Color(0xFFFFA500); // ORANGE
  static const Color cuvetteArrowHighlight = Color.fromARGB(255, 255, 255, 0);
  static const Color solutionStroke = Color.fromARGB(255, 148, 148, 148);

  /// LaserPointerNode sizes from LightNode.ts
  static const Size lightBodySize = Size(126, 78);
  static const Size lightNozzleSize = Size(16, 65);
  static const double lightButtonRadius = 26;

  /// Cuvette arrow from CuvetteNode.ts
  static const double arrowLength = 110;
  static const double arrowHeadHeight = 38;
  static const double arrowHeadWidth = 45;
  static const double arrowTailWidth = 23;
  static const double solutionPercentFull = 0.92;
  static const double solutionAlpha = 0.6;

  /// Detector probe from DetectorProbeNode.ts
  static const double probeRadius = 53;
  static const double probeInnerRadius = 40;
  static const double probeHandleWidth = 68;
  static const double probeHandleHeight = 60;

  /// Detector body min size from DetectorNode.ts
  static const Size detectorValueMin = Size(150, 36);
  static const Size detectorBodyMin = Size(185, 140);

  /// Reset All — source scale 1.32; project uses KratosResetAllButton.
  static const double resetRight = 1100 - 30;
  static const double resetBottom = 700 - 30;
  static const double resetRadius = 20.5;
  static const double resetScale = 1.32;

  static const double wavelengthPanelGap = 20;
  static const double solutionPanelGap = 60;
}
