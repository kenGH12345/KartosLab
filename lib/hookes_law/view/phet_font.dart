import 'package:flutter/material.dart';

/// scenery-phet `PhetFont`. Family is Arial, then sans-serif.
class PhetFont {
  const PhetFont._();

  static TextStyle of(
    double size, {
    Color color = const Color(0xFF000000),
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TextStyle(
      fontFamily: 'Arial',
      fontFamilyFallback: const ['sans-serif'],
      fontSize: size,
      fontWeight: fontWeight,
      fontStyle: FontStyle.normal,
      color: color,
      height: 1,
    );
  }
}
