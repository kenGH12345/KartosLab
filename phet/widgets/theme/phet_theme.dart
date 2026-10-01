/// PhET Simulation Theme
///
/// Centralised color and text style definitions for all PhET simulations.
/// Individual simulations can override specific colors by passing a custom
/// [PhetThemeData] to their widgets.
library;

import 'package:flutter/material.dart';

class PhetThemeData {
  // ── Backgrounds ──
  final Color canvasBackground;
  final Color panelBackground;
  final Color panelBorder;
  final Color panelShadow;

  // ── Controls ──
  final Color buttonPrimary;
  final Color buttonOnPrimary;
  final Color buttonSecondary;
  final Color buttonBorder;
  final Color sliderActive;
  final Color sliderInactive;
  final Color sliderThumb;
  final Color checkboxActive;
  final Color radioButtonActive;

  // ── Text ──
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnDark;

  // ── Field & compass ──
  final Color fieldArrowHead;
  final Color fieldArrowTail;
  final Color compassNeedleNorth;
  final Color compassNeedleSouth;
  final Color electron;

  // ── Radii & borders ──
  final double panelRadius;
  final double buttonRadius;
  final double borderWidth;

  // ── Shadows ──
  final double shadowBlur;
  final Offset shadowOffset;

  const PhetThemeData({
    this.canvasBackground = const Color(0xff000000),
    this.panelBackground = const Color(0xffe8f0fe),
    this.panelBorder = const Color(0xffbdbdbd),
    this.panelShadow = const Color(0x42000000),
    this.buttonPrimary = const Color(0xff1a237e),
    this.buttonOnPrimary = Colors.white,
    this.buttonSecondary = Colors.white,
    this.buttonBorder = const Color(0xff9e9e9e),
    this.sliderActive = const Color(0xff1a237e),
    this.sliderInactive = const Color(0xffc0c0c0),
    this.sliderThumb = const Color(0xff311b92),
    this.checkboxActive = const Color(0xff1a237e),
    this.radioButtonActive = const Color(0xff1a237e),
    this.textPrimary = const Color(0xff212121),
    this.textSecondary = const Color(0xff757575),
    this.textOnDark = Colors.white,
    this.fieldArrowHead = const Color(0xffcc2222),
    this.fieldArrowTail = const Color(0xffcccccc),
    this.compassNeedleNorth = const Color(0xffee3333),
    this.compassNeedleSouth = const Color(0xffaaaaaa),
    this.electron = const Color(0xff42a5f5),
    this.panelRadius = 10,
    this.buttonRadius = 6,
    this.borderWidth = 1,
    this.shadowBlur = 8,
    this.shadowOffset = const Offset(2, 3),
  });

  /// Default PhET theme.
  static const PhetThemeData defaultTheme = PhetThemeData();

  /// Dark variant (for simulations with dark panels).
  static const PhetThemeData dark = PhetThemeData(
    panelBackground: Color(0xff0d2255),
    panelBorder: Color(0xff1a237e),
    textPrimary: Colors.white,
    textSecondary: Color(0xffb0bec5),
  );
}

/// Inherited widget that provides [PhetThemeData] to descendants.
class PhetTheme extends InheritedWidget {
  final PhetThemeData data;
  const PhetTheme({
    super.key,
    this.data = PhetThemeData.defaultTheme,
    required super.child,
  });

  static PhetThemeData of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<PhetTheme>();
    return w?.data ?? PhetThemeData.defaultTheme;
  }

  @override
  bool updateShouldNotify(PhetTheme old) => old.data != data;
}
