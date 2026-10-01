/// PhetFont mapping for Quantum Measurement — QuantumMeasurementConstants.ts
library;

import 'package:flutter/material.dart';

/// PhET `PhetFont` uses Arial / Helvetica / sans-serif.
abstract final class QmTypography {
  static const String fontFamily = 'Arial';

  static const TextStyle header = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: Colors.black,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black,
    height: 1.2,
  );

  static const TextStyle control = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black,
    height: 1.2,
  );

  static const TextStyle smallLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.black,
    height: 1.2,
  );

  static const TextStyle tinyLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 8,
    fontWeight: FontWeight.w400,
    color: Colors.black,
    height: 1.1,
  );

  static const TextStyle sceneSelector = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    height: 1.15,
  );

  static const TextStyle boldHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    height: 1.2,
  );

  static const TextStyle boldTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    height: 1.2,
  );

  static const TextStyle boldControl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    height: 1.2,
  );

  static TextStyle controlColored(Color color) => control.copyWith(color: color);
}
