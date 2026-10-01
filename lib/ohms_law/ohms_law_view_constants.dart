import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'model/ohms_law_constants.dart';

/// View geometry / chrome from PhET `OhmsLawConstants.js` + `OhmsLawScreenView.js`.
///
/// Model physics ranges live in [OhmsLawConstants]; this file is View-only.
abstract final class OhmsLawViewConstants {
  /// Joist `ScreenView.DEFAULT_LAYOUT_BOUNDS` — ohms-law does **not** override.
  /// Source: `joist/js/ScreenView.ts` → `Bounds2( 0, 0, 1024, 618 )`.
  /// (VD-01 曾暂定 768×504，实为 HomeScreen 旧值；正式 sim 默认是 1024×618。)
  static const Size layoutSize = Size(1024, 618);
  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;

  /// `OhmsLawScreen` backgroundColor `#ffffe8`
  static const Color background = Color(0xFFFFFFE8);

  static const Color blue = Color.fromRGBO(0, 0, 225, 1);
  static const Color redColorblind = Color.fromRGBO(255, 85, 0, 1);
  static const Color black = Color(0xFF000000);

  static const String fontFamily = 'Times New Roman';
  static const String uiFontFamily = 'Arial';

  // --- FormulaNode ---
  static const double equalsLocalX = 300;
  static const double voltageLocalX = equalsLocalX - 150; // 150
  static const double currentLocalX = equalsLocalX + 80; // 380
  static const double resistanceLocalX = equalsLocalX + 240; // 540
  static const double formulaLetterBaseSize = 20;
  static const double equalsFontSize = 140;
  static const double currentScaleM = 150;
  static const double currentScaleB = 1;
  static const double othersScaleM = 16;
  static const double othersScaleB = 4;

  // --- WireBox ---
  static const double wireWidth = 505;
  static const double wireHeight = 165;
  static const double wireThickness = 10;
  static const double wireCornerRadius = 4;
  static const double arrowOffset = 10;

  // --- Battery ---
  static const double aaVoltage = 1.5;
  static const double batteriesOffset = 30;
  static const int maxBatteries = 6; // ceil(9/1.5)
  static const double batteryHeight = 38;
  static final double batteryWidth =
      (wireWidth - batteriesOffset * 2) / maxBatteries;
  static final double batteryMainBodyWidth = batteryWidth * 0.87;
  static final double batteryNubWidth = batteryWidth * 0.05;
  static final double batteryCopperWidth =
      batteryWidth - batteryMainBodyWidth - batteryNubWidth;

  // --- Resistor ---
  static final double resistorWidth = wireWidth / 2.123;
  static final double resistorHeight = wireHeight / 2.75;
  static const double perspectiveFactor = 0.3;
  static const double dotRadius = 2;
  static const double areaPerDot = 40;

  static final double maxWidthIncludingRoundedEnds =
      resistorWidth + resistorHeight * perspectiveFactor;
  static final double numberOfDots =
      maxWidthIncludingRoundedEnds * resistorHeight / areaPerDot;

  static int get dotGridRows =>
      _roundSymmetric(resistorHeight / math.sqrt(areaPerDot));
  static int get dotGridColumns =>
      _roundSymmetric(resistorWidth / math.sqrt(areaPerDot));
  static int get maxDots => dotGridColumns * dotGridRows;

  // --- SliderUnit ---
  static const double sliderWidth = 89;
  static const double sliderHeight = 210;
  static const Size thumbSize = Size(45, 22);
  static const Size trackSize = Size(4, sliderHeight);
  static const Color thumbFill = Color(0xFFC3C4C5);
  static const Color thumbFillHighlighted = Color(0xFFDEDEDE);
  static const double symbolFontSize = 60;
  static const double nameFontSize = 16;
  static const double readoutFontSize = 28;
  static const double unitFontSize = 28;
  /// Source `UNIT_MAX_WIDTH` — i18n unit next to value.
  static const double unitMaxWidth = 45;
  /// Source header packing: name under symbol (`name.centerY ≈ symbol.y + 18`).
  /// Keep compact so ControlPanel clears Units on 1024×618.
  static const double sliderHeaderHeight = 72;
  /// Name baseline under large symbol (readable; still shorter than Column stack).
  static const double sliderNameTop = 50;

  // --- Control panel ---
  static const double controlXMargin = 30;
  static const double controlYMargin = 10;
  static const double controlLineWidth = 3;
  static const double controlSliderSpacing = 30;

  // --- Readout ---
  static const double readoutFontSizePanel = 32;
  static const double readoutXMargin = 30;
  static const double readoutYMargin = 8;
  static const double readoutLineWidth = 3;
  static const double readoutSpacing = 11.3;

  // --- Reset ---
  static const double resetRadius = 28;

  // --- Arrow ---
  static const double arrowInitialScale = 0.85;

  /// Layout from `OhmsLawScreenView.js`
  static double get formulaCenterY => layoutHeight / 4.75;
  static double get wireBoxBottom => layoutHeight - 30;
  static double get controlPanelRight => layoutWidth - 50;
  static double get controlPanelTop => 20;
  static double get resetBottom => layoutHeight - 20;

  /// Expected ControlPanel width from source geometry (no Flutter +36 padding).
  static double get controlPanelWidthEstimate =>
      sliderWidth * 2 +
      controlSliderSpacing +
      controlXMargin * 2 +
      controlLineWidth * 2;

  /// Expected ControlPanel height with compact PhET header packing.
  static double get controlPanelHeightEstimate =>
      sliderHeaderHeight +
      5 + // VBox spacing
      sliderHeight +
      5 +
      readoutFontSize +
      controlYMargin * 2 +
      controlLineWidth * 2;

  /// Map resistance → visible dot count (`LinearFunction`, clamp).
  static double resistanceToNumDots(double resistance) {
    final minD = maxDots * 0.05;
    final maxD = maxDots.toDouble();
    final t = ((resistance - OhmsLawConstants.resistanceRange.min) /
            OhmsLawConstants.resistanceRange.length)
        .clamp(0.0, 1.0);
    return minD + t * (maxD - minD);
  }

  /// Battery body length scale: LinearFunction(0.1, 1.5, 0.0001, 1, clamp).
  static double voltageToBatteryScale(double cellVoltage) {
    const x0 = 0.1;
    const x1 = aaVoltage;
    const y0 = 0.0001;
    const y1 = 1.0;
    final x = cellVoltage.clamp(x0, x1);
    return y0 + (x - x0) / (x1 - x0) * (y1 - y0);
  }

  /// Arrow scale after first current change: `(I_mA * 0.1)^0.7`.
  static double arrowScaleForCurrent(double currentMa) {
    return math.pow(currentMa * 0.1, 0.7).toDouble();
  }

  /// PhET `roundSymmetric`.
  static int _roundSymmetric(double value) {
    if (value < 0) {
      return (value - 0.5).ceil();
    }
    return (value + 0.5).floor();
  }

  /// PhET `Utils.roundToInterval` with interval 0.1 (voltage sig figs).
  static double roundToVoltageInterval(double value) {
    const interval = 0.1;
    final n = value / interval;
    final rounded = n < 0 ? (n - 0.5).ceilToDouble() : (n + 0.5).floorToDouble();
    return rounded * interval;
  }
}

/// Right-angle arrow polygon (source `RightAngleArrow` POINTS), local coords.
abstract final class RightAngleArrowShape {
  static const List<Offset> points = [
    Offset(5, -30),
    Offset(13, -30),
    Offset(13, 13),
    Offset(-25, 13),
    Offset(-25, 17),
    Offset(-40, 8.5),
    Offset(-25, 0),
    Offset(-25, 5),
    Offset(5, 5),
  ];
}
