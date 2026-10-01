import 'package:flutter/material.dart';

/// PhET `PhetFont` defaults to Arial (`sceneryPhetQueryParameters.fontFamily`).
abstract final class PhScaleFonts {
  static const String family = 'Arial';

  static TextStyle style({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    double? height,
  }) =>
      TextStyle(
        fontFamily: family,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );

  static final TextStyle volume = style(fontSize: 24, fontWeight: FontWeight.bold);
  static final TextStyle neutral = style(fontSize: 30, fontWeight: FontWeight.bold);
  static final TextStyle combo = style(fontSize: 22);
  static final TextStyle beakerTick = style(fontSize: 24);
  static final TextStyle waterLabel = style(fontSize: 28);
  static final TextStyle accordionTitle =
      style(fontSize: 28, fontWeight: FontWeight.bold);
  static final TextStyle spinner = style(fontSize: 28, fontWeight: FontWeight.bold);
  static final TextStyle meterLabel =
      style(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white);
  static final TextStyle meterValue = style(fontSize: 28, fontWeight: FontWeight.bold);
  static final TextStyle scaleTick = style(fontSize: 22);
  static final TextStyle scaleNeutral =
      style(fontSize: 28, fontWeight: FontWeight.bold);
  static final TextStyle scaleWord = style(fontSize: 30, fontWeight: FontWeight.bold);
  static final TextStyle graphLogTick = style(fontSize: 22);
  static final TextStyle graphLinearTick = style(fontSize: 18);
  static final TextStyle abSwitch =
      style(fontSize: 18, fontWeight: FontWeight.bold);
  static final TextStyle particleCount = style(fontSize: 22);
  static final TextStyle controlPanel = style(fontSize: 20);
}
