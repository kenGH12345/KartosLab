import 'package:flutter/material.dart';

/// Approximate PhET `PhetFont` — platform sans; provenance noted as P2.
class QwiTypography {
  QwiTypography._();

  /// PhET uses Arial / Helvetica / sans-serif stack via PhetFont.
  static const String fontFamily = 'Arial';

  static TextStyle label([double size = 12]) => TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
        height: 1.2,
      );

  static TextStyle labelBold([double size = 12]) => TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        height: 1.2,
      );

  static TextStyle panelTitle([double size = 13]) => TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      );

  static TextStyle probeReadout([double size = 14.4]) => TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.1,
      );

  static TextStyle button([double size = 12]) => TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      );
}
