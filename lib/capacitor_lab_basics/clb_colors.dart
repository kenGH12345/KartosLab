import 'package:flutter/material.dart';

/// Colors from `CLBConstants.js` + `PhetColorScheme.ts`.
class ClbColors {
  ClbColors._();

  /// `PhetColorScheme.RED_COLORBLIND` — `PhetColorScheme.ts:20`
  static const Color redColorblind = Color.fromRGBO(255, 85, 0, 1);

  static const Color screenBackground = Color.fromRGBO(153, 193, 255, 1);
  static const Color capacitance = Color.fromRGBO(61, 179, 79, 1);
  static const Color eField = Colors.black;
  static const Color storedEnergy = Color.fromRGBO(255, 255, 0, 1);
  static const Color positiveCharge = redColorblind;
  static const Color negativeCharge = Color.fromRGBO(0, 0, 255, 1);
  static const Color meterPanelFill = Color.fromRGBO(255, 245, 237, 1);
  static const Color connectionPoint = Colors.black;
  static const Color pin = Color.fromRGBO(211, 211, 211, 1); // lightgray
  static const Color disconnectedPoint = Color.fromRGBO(200, 230, 255, 1);
  static const Color disconnectedPointStroke = redColorblind;
  static const Color connectionHighlighted = Color.fromRGBO(255, 255, 0, 1);

  static const Color currentElectronsArrow = Color.fromRGBO(83, 200, 236, 1);
  static const Color currentConventionalArrow = redColorblind;

  static const Color wireFill = Color.fromRGBO(170, 170, 170, 1);
  static const Color wireStroke = Color.fromRGBO(143, 143, 143, 1);

  static const Color plate = Color.fromRGBO(245, 245, 245, 1);
}
