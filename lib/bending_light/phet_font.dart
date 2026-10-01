import 'package:flutter/material.dart';

/// Scenery-phet `PhetFont`.
///
/// `sceneryPhetQueryParameters.fontFamily` defaultValue is `'Arial'`.
/// `PhetFont` then appends `', sans-serif'`. Weight and style stay at the
/// scenery Font default (`normal`) unless a call site passes `fontWeight`.
class PhetFont {
  PhetFont._();

  static const String family = 'Arial';
  static const List<String> fallback = ['sans-serif'];

  static TextStyle of(
    double size, {
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double? height,
  }) {
    return TextStyle(
      fontFamily: family,
      fontFamilyFallback: fallback,
      fontSize: size,
      fontWeight: fontWeight,
      fontStyle: FontStyle.normal,
      color: color,
      height: height,
    );
  }
}
