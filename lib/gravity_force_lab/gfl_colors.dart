import 'dart:ui' show Color;

/// Full Gravity Force Lab colors (not Basics yellow field).
class GflColors {
  GflColors._();

  static const Color screenBackground = Color(0xFFFFFFFF);
  /// Home card / AppBar accent — Full panel yellow (not Basics `#ffffc2`).
  static const Color accent = Color(0xFFFDF498);
  static const Color mass1Base = Color(0xFF0000FF);
  static const Color mass2Base = Color(0xFFFF0000);
  /// Vertical dashed stem colors (`ISLCObjectNode.arrowColor`).
  static const Color forceStem1 = Color(0xFF6666FF);
  static const Color forceStem2 = Color(0xFFFF6666);
  /// Full MassNode sets `arrowFill: '#000'` (not stem color).
  static const Color forceArrowFill = Color(0xFF000000);
  /// Kept for call sites that still name "arrow" — stem semantics.
  static const Color forceArrow1 = forceStem1;
  static const Color forceArrow2 = forceStem2;
  static const Color panelFill = Color(0xFFFDF498);
  static const Color rope = Color(0xFF666666);
  static const Color shadow = Color(0xFF777777);
  static const Color forceLabel = Color(0xFF000000);
  static const Color forceLabelBackground = Color(0x4DFFFFFF);
  static const Color rulerBackground = Color.fromRGBO(236, 225, 113, 1);
  static const Color separator = Color(0xFF888888);
}
