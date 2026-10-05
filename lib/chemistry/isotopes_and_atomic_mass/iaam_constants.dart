/// Isotopes and Atomic Mass — layout / view constants (PhET ScreenView).
library;

import 'package:flutter/material.dart';

import 'model/make_isotopes_constants.dart';

class IaamConstants {
  IaamConstants._();

  /// PhET `layoutBounds` for both screens.
  static const double layoutWidth = 768;
  static const double layoutHeight = 464;

  /// MVT: `createSinglePointScaleInvertedYMapping(ZERO, (0.4W, 0.49H), 1.0)`.
  static const double mvtScale = 1.0;
  static double get mvtViewX => (layoutWidth * 0.4).roundToDouble(); // 307
  static double get mvtViewY => (layoutHeight * 0.49).roundToDouble(); // 227

  /// Mix MVT: `(0.32W, 0.33H)` → (246, 153).
  static double get mixMvtViewX => (layoutWidth * 0.32).roundToDouble();
  static double get mixMvtViewY => (layoutHeight * 0.33).roundToDouble();

  static const double scaleImageWidth = 275;
  /// `scale.png` is 351×132; display width 275 → height 275×132/351.
  static const double scaleImageHeight = 275.0 * 132 / 351;
  /// PhET `scaleNode.setCenterBottom(..., layoutBounds.bottom - 13)`.
  static const double scaleBottomOffset = 13;
  /// `bottomOfAtomPosition.y = scaleNode.top + 15`.
  static const double atomBottomOnScaleOffset = 15;

  static const double periodicTableScale = 0.65;
  static const double mixPeriodicTableScale = 0.55;
  static const double periodicTableTop = 10;
  static const double periodicTableRightInset = 10;

  /// Accordion title strip ≈ padding + button + text (collapsed height).
  static const double accordionTitleH = 28;

  /// Make Symbol content (72) + vertical padding.
  static const double makeSymbolExpandedH = accordionTitleH + 72 + 8;

  /// Make Abundance content (96) + padding.
  static const double makeAbundanceExpandedH = accordionTitleH + 96 + 8;

  /// Mix Percent Composition (pie @0.6 ≈ 72) + padding.
  static const double mixCompositionExpandedH = accordionTitleH + 72 + 8;

  /// Mix Average Atomic Mass indicator + padding.
  static const double mixAverageExpandedH = accordionTitleH + 58 + 8;

  static const Color panelBackground = Color(0xFFFEFF99); // DISPLAY_PANEL_BACKGROUND
  static const Color selectedCell = Color(0xFFFA8072); // salmon
  static const Color proton = Color(0xFFD14600);
  static const Color neutron = Color(0xFF737373);
  static const Color electronCloud = Color(0xFF64B5F6);

  static const Color pieThisIsotope = Color(0xFF8666AC);
  static const Color pieOther = Color(0xFFD3D3D3);

  static const double nucleonRadius = kNucleonRadius;
  static const double resetRadius = 20.5 * 0.85; // ResetAllButton scale 0.85

  static const String scaleAsset =
      'assets/simulations/isotopes_and_atomic_mass/images/scale.png';
  static const String isotopesIconAsset =
      'assets/simulations/isotopes_and_atomic_mass/images/isotopesIcon.png';
  static const String mixturesIconAsset =
      'assets/simulations/isotopes_and_atomic_mass/images/mixturesIcon.png';
}
