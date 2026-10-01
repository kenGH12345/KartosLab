import 'package:flutter/material.dart';

/// Layout constants copied from the local bending-light 1.3.0-dev.0 sources.
///
/// Pixel numbers that scenery only knows after measuring text are not invented
/// here. Those stay as anchor formulas.
class SourceLayout {
  SourceLayout._();

  static const double layoutWidth = 834;
  static const double layoutHeight = 504;

  /// `FloatingLayout` `leftRightPadding`.
  static const double edgePadding = 10;

  /// `FloatingLayout` `topBottomPadding`. At layout bounds this is also the
  /// distance from the stage bottom to a `floatBottom` node.
  static const double topBottomPadding = 15;

  static const double inset = 10;

  /// View x of the origin before the intro offset. `388 - horizontalPlayAreaOffset`.
  static const double stageOriginX = 388;

  /// Intro `horizontalPlayAreaOffset`.
  static const double introPlayAreaOffset = 102;
  static const double introNormalX = stageOriginX - introPlayAreaOffset;

  /// `modelToViewY(0)` when `verticalPlayAreaOffset` is 0.
  static const double interfaceY = layoutHeight / 2;

  /// Bottom edge of the top medium panel.
  /// `modelToViewY(0) - 2*INSET + 4`.
  static const double introTopPanelBottom = interfaceY - 2 * inset + 4;

  /// Top edge of the bottom medium panel.
  /// `modelToViewY(0) + 2*INSET + 1`.
  static const double introBottomPanelTop = interfaceY + 2 * inset + 1;

  static const Color panelFill = Color(0xFFEEEEEE);
  static const Color panelStroke = Color(0xFF696969);
  static const double panelLineWidth = 1.5;
  static const double panelCornerRadius = 5;

  /// Inner `Panel` in `MediumControlPanel.ts`, not the unused options default.
  static const double mediumXMargin = 13.5;
  static const double mediumYMarginIntro = 7;
  static const double mediumYMarginPrisms = 6;

  /// `sliderWidth` when the index readout is visible.
  static const double sliderTrackWidth = 210;

  static const double mediumPanelWidth = sliderTrackWidth + 2 * mediumXMargin;

  static const double toolboxXMargin = 10;
  static const double toolboxYMargin = 10;
  static const double toolboxSpacing = 10;

  /// `PrismToolboxNode` `left: layoutBounds.minX + 12`.
  static const double prismToolboxLeft = 12;

  static const double chartOuterWidth = 135;
  static const double chartOuterHeight = 100;
  static const double chartBodyScale = 0.93;
  static const Color chartFillTop = Color(0xFF5EB4DE);
  static const Color chartFillBottom = Color(0xFF005B86);
  static const Color chartStrokeTop = Color(0xFF2F9BCE);
  static const Color chartStrokeBottom = Color(0xFF00486A);
  static const double chartStrokeWidth = 2;
  static const double chartCornerRadius = 5;

  /// `innerMostRectangle` before the body scale, then `eroded(3)` for the chart.
  static const double chartPlotLeft = 6.35;
  static const double chartPlotTop = 8.5;
  static const double chartPlotWidth = 122.3;
  static const double chartPlotHeight = 63;
  static const double chartPlotErode = 3;

  static const double timeLabelFraction = 0.82;

  static const double protractorScaleIntro = 0.8;
  static const double protractorScalePrisms = 0.46;
  static const double protractorIconScale = 0.24;

  static Rect chartPlotLocal(Size scaledBody) {
    final sx = scaledBody.width / chartOuterWidth;
    final sy = scaledBody.height / chartOuterHeight;
    return Rect.fromLTWH(
      (chartPlotLeft + chartPlotErode) * sx,
      (chartPlotTop + chartPlotErode) * sy,
      (chartPlotWidth - 2 * chartPlotErode) * sx,
      (chartPlotHeight - 2 * chartPlotErode) * sy,
    );
  }
}
