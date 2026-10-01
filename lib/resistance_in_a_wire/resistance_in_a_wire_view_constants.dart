import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'model/resistance_in_a_wire_constants.dart';

/// View geometry / chrome from PhET Resistance in a Wire 1.8.0-dev.0.
///
/// Model physics ranges live in [ResistanceInAWireConstants]; this is View-only.
abstract final class ResistanceInAWireViewConstants {
  /// Joist `ScreenView.DEFAULT_LAYOUT_BOUNDS` — sim does **not** override.
  static const Size layoutSize = Size(1024, 618);
  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;

  /// `BACKGROUND_COLOR: '#ffffdf'`
  static const Color background = Color(0xFFFFFFDF);

  static const Color blue = Color(0xFF0F0FFB);
  static const Color red = Color(0xFFFF2222);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  static const String fontFamily = 'Times New Roman';
  static const String uiFontFamily = 'Arial';

  // --- FormulaNode (local coords; equals center = (100, 0)) ---
  static const double equalsLocalX = 100;
  static const double equalsLocalY = 0;
  static const double rLocalX = equalsLocalX - 100; // 0
  static const double rhoLocalX = equalsLocalX + 120; // 220
  static const double rhoLocalY = -90;
  static const double lengthLocalX = equalsLocalX + 220; // 320
  static const double lengthLocalY = -90;
  static const double areaLocalX = equalsLocalX + 170; // 270
  static const double areaLocalY = 90;
  static const double formulaLetterBaseSize = 15;
  static const double equalsFontSize = 90;
  static const double fractionLineY = 8;
  static const double fractionLineStartX = 150;
  static const double fractionLineEndX = 400;
  static const double fractionLineWidth = 6;
  static const double formulaOutlineWidth = 0.2;

  /// Formula paint area (letters can grow large; Stack uses Clip.none).
  static const Size formulaPaintSize = Size(520, 360);

  // --- WireShapeConstants ---
  static const double perspectiveFactor = 0.4;
  static const double wireViewWidthMin = 15;
  static const double wireViewWidthMax = 500;
  static const double wireViewHeightMin = 3;
  static const double wireViewHeightMax = 180;
  static const double dotRadius = 2;
  static const double areaPerDot = 200;

  static final double wireDiameterMax =
      math.sqrt(ResistanceInAWireConstants.areaRange.max / math.pi) * 2;

  static final double maxWidthIncludingRoundedEnds =
      wireViewWidthMax + 2 * wireViewHeightMax * perspectiveFactor;

  static final double numberOfDots =
      maxWidthIncludingRoundedEnds * wireViewHeightMax / areaPerDot;

  // Wire gradient stops (top → bottom of body in source: y height/2 → -height/2)
  static const Color wireDark = Color(0xFF8C4828);
  static const Color wireMid = Color(0xFFE8B282);
  static const Color wireHighlight = Color(0xFFFCF5EE);
  static const Color wireNearHighlight = Color(0xFFF8E8D9);

  // --- ArrowNode ---
  static const double tailLength = 140;
  static const double headHeight = 45;
  static const double headWidth = 30;
  static const double tailWidth = 10;

  // --- SliderUnit ---
  static const double sliderWidth = 70;
  static const double sliderHeight = 230;
  static const Size thumbSize = Size(45, 22);
  static const Size trackSize = Size(4, sliderHeight - 30); // 4×200
  static const Color thumbFill = Color(0xFFC3C4C5);
  static const Color thumbFillHighlighted = Color(0xFFDEDEDE);
  static const double symbolFontSize = 60;
  static const double nameFontSize = 16;
  static const double readoutFontSize = 28;
  static const double unitFontSize = 28;
  static const double sliderHeaderHeight = 90;
  static const double sliderNameTop = 62;

  // --- ControlPanel ---
  static const double controlXMargin = 30;
  static const double controlYMargin = 20;
  static const double controlLineWidth = 3;
  static const double controlSliderSpacing = 50;
  static const double resistanceReadoutGap = 12;

  // --- ScreenView layout ---
  static const double controlPanelTop = 40;
  static const double controlPanelRightMargin = 30;
  static const double formulaCenterY = 190;
  static const double wireCenterYOffset = 270; // formula.centerY + 270
  static const double arrowBottomOffset = 47; // layoutBounds.bottom - 47
  static const double resetBottomMargin = 20;
  static const double resetRadius = 30;

  static double get controlPanelRight => layoutWidth - controlPanelRightMargin;
  static double get resetBottom => layoutHeight - resetBottomMargin;
  static double get arrowY => layoutHeight - arrowBottomOffset;

  static double get controlPanelWidthEstimate =>
      sliderWidth * 3 +
      controlSliderSpacing * 2 +
      controlXMargin * 2 +
      controlLineWidth * 2;

  static double get controlPanelHeightEstimate =>
      readoutFontSize +
      resistanceReadoutGap +
      sliderHeaderHeight +
      5 +
      trackSize.height +
      70 + // value + unit + gaps under track
      controlYMargin * 2 +
      controlLineWidth * 2;

  /// LinearFunction(L_min→L_max → 15→500), clamp.
  static double lengthToWidth(double length) {
    final r = ResistanceInAWireConstants.lengthRange;
    final t = ((length - r.min) / r.length).clamp(0.0, 1.0);
    return wireViewWidthMin + t * (wireViewWidthMax - wireViewWidthMin);
  }

  /// `areaToHeight` from WireShapeConstants.
  static double areaToHeight(double area) {
    final radiusSquared = area / math.pi;
    final diameter = math.sqrt(radiusSquared) * 2;
    return wireViewHeightMax / wireDiameterMax * diameter;
  }

  /// LinearFunction(ρ_min→ρ_max → 0.05*N → N), clamp.
  static double resistivityToNumDots(double resistivity) {
    final r = ResistanceInAWireConstants.resistivityRange;
    final minD = numberOfDots * 0.05;
    final maxD = numberOfDots;
    final t = ((resistivity - r.min) / r.length).clamp(0.0, 1.0);
    return minD + t * (maxD - minD);
  }

}
