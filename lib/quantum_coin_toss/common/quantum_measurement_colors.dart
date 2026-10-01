// Copyright 2024-2026, University of Colorado Boulder
/// Static colors matching `QuantumMeasurementColors.ts` defaults (coins screen).
library;

import 'package:flutter/material.dart';

abstract final class QuantumMeasurementColors {
  static const Color screenBackground = Colors.white;

  static const Color selectorButtonSelected = Color(0xFFFFFFFF);
  static const Color selectorButtonDeselected = Color(0xFFAAAAAA);
  static const Color selectorButtonSelectedStroke = Color(0xFF0094BD);
  static const Color selectorButtonDeselectedStroke = Colors.black;

  static const Color classicalSceneBackground = Color(0xFFFFF9F0);
  static const Color quantumSceneBackground = Color(0xFFF5FAFE);

  static const Color classicalSceneText = Colors.black;
  static const Color quantumSceneText = Colors.black;

  static const Color headsColor = Color(0xFF000000);
  static const Color tailsColor = Color(0xFFCC00CC);
  static const Color upColor = Color(0xFF000000);
  static const Color downColor = Color(0xFFCC00CC);

  static const Color testBoxRectangleStroke = Color(0xFF777777);
  static const Color testBoxGradientStart = Color(0xCCEEEEEE);
  static const Color testBoxGradientEnd = Color(0xCCBAE3E0);

  static const Color maskedFill = Color(0xFFCCCCCC);
  static const Color headsFill = Color(0xFFF0F0F0);
  static const Color tailsFill = Color(0xFFF0F0F0);
  static const Color upFill = Color(0xFF00FFFF);
  static const Color downFill = Color(0xFFFFFF00);

  static const Color coinStroke = Color(0xFF888888);

  static const Color startMeasurementButton = Color(0xFF72EB97);
  static const Color newCoinButton = Color(0xFF72EB97);
  static const Color experimentButton = Color(0xFF99CDFF);

  static const Color dividerLineStroke = Colors.black;

  static const Color expectedPercentageFill = Color(0xFF00AA00);
}
