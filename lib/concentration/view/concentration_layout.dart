import 'dart:ui';

import '../model/concentration_constants.dart';

/// Source-derived layout positions for Concentration play area (layoutBounds space).
///
/// Identity model-view transform — model coords == view coords inside 1100×700.
abstract final class ConcentrationLayout {
  static const Size layoutBounds = ConcentrationConstants.layoutBounds;

  static const Offset beakerPosition = ConcentrationConstants.beakerPosition;
  static const Size beakerSize = ConcentrationConstants.beakerSize;

  static double get beakerLeft => beakerPosition.dx - beakerSize.width / 2;
  static double get beakerRight => beakerPosition.dx + beakerSize.width / 2;
  static double get beakerTop => beakerPosition.dy - beakerSize.height;
  static double get beakerBottom => beakerPosition.dy;

  static const Offset shakerPosition = ConcentrationConstants.shakerPosition;
  static const Rect shakerDragBounds = ConcentrationConstants.shakerDragBounds;
  static const double shakerOrientation = ConcentrationConstants.shakerOrientation;
  static const double shakerImageScale = 0.75;

  static const Offset dropperPosition = ConcentrationConstants.dropperPosition;

  static const Offset solventFaucetPosition =
      ConcentrationConstants.solventFaucetPosition;
  static const double solventFaucetPipeMinX =
      ConcentrationConstants.solventFaucetPipeMinX;

  static const Offset drainFaucetPosition =
      ConcentrationConstants.drainFaucetPosition;

  static Offset get drainFaucetPipeMinXAsOffset =>
      Offset(beakerRight, drainFaucetPosition.dy);

  static double get drainFaucetPipeMinX => beakerRight;

  static const double faucetScale = 0.75;

  static const Offset meterBodyPosition =
      ConcentrationConstants.meterBodyPosition;
  static const Offset probeInitialPosition =
      ConcentrationConstants.probeInitialPosition;
  static const Rect probeDragBounds = ConcentrationConstants.probeDragBounds;

  /// Solute panel: `right = layout.right - 20`, `top = 20`.
  static const double solutePanelRight = 1100 - 20;
  static const double solutePanelTop = 20;

  /// Evaporation: left-aligned with beaker, `top = beaker.bottom + 30`.
  static double get evaporationLeft => beakerLeft;
  static double get evaporationTop => beakerBottom + 30;

  /// Reset All: `right = layout.right - 30`, `bottom = layout.bottom - 30`.
  static const double resetRight = 1100 - 30;
  static const double resetBottom = 700 - 30;
  static const double resetScale = 1.32;
  static const double resetRadius = 20.5;

  static const Color screenBackground = Color(0xFFFFFFFF);
  static const Color panelFill = Color.fromARGB(255, 240, 240, 240);
  static const Color meterBodyColor = Color.fromARGB(255, 135, 4, 72);
  static const Color removeSoluteBase = Color.fromARGB(255, 255, 200, 0);
  static const Color solutionStroke = Color.fromARGB(255, 148, 148, 148);
}
