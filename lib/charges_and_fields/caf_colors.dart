import 'package:flutter/material.dart';

/// Default (non-projector) color scheme from ChargesAndFieldsColors.ts
class CafColors {
  CafColors._();

  static const Color background = Color(0xFF000000);
  static const Color controlPanelBorder = Color(0xFFD2D2D2);
  static const Color controlPanelFill = Color(0xFF0A0A0A);
  static const Color controlPanelText = Color(0xFFE5E57E);
  static const Color enclosureText = Color(0xFFFFFFFF);
  static const Color enclosureFill = Color(0xFF0A0A0A);
  static const Color enclosureBorder = Color(0xFFD2D2D2);
  static const Color checkbox = Color(0xFFE6E6E6);
  static const Color checkboxBackground = Color(0xFF1E1E1E);

  static const Color voltageLabel = Color(0xFFFFFFFF);
  static const Color voltageLabelBackground = Color(0x80000000);
  static const Color electricPotentialLine = Color(0xFF32FF64);

  static const Color measuringTapeText = Color(0xFFFFFFFF);

  static const Color electricFieldSensorCircleFill = Color(0xFFFFFF00);
  static const Color electricFieldSensorCircleStroke = Color(0xFF807885);
  static const Color electricFieldSensorArrow = Color(0xFFFF0000);
  static const Color electricFieldSensorLabel = Color(0xFFE5E57E);

  static const Color gridStroke = Color(0xFF323232);
  static const Color gridLengthScaleArrowStroke = Color(0xFFFFFFFF);
  static const Color gridLengthScaleArrowFill = Color(0xFFFFFFFF);
  static const Color gridTextFill = Color(0xFFFFFFFF);

  static const Color electricPotentialSensorCircleStroke = Color(0xFFFFFFFF);
  static const Color electricPotentialSensorCrosshairStroke = Color(0xFFFFFFFF);
  static const Color electricPotentialPanelTitleText = Color(0xFFFFFFFF);
  static const Color electricPotentialSensorTextPanelTextFill = Color(0xFF000000);
  static const Color electricPotentialSensorTextPanelBorder = Color(0xFF000000);
  static const Color electricPotentialSensorTextPanelBackground =
      Color(0xFFFFFFFF);

  static const Color electricFieldGridSaturation = Color(0xFFFFFFFF);
  static const Color electricFieldGridSaturationStroke = Color(0xFF000000);
  static const Color electricFieldGridZero = Color(0xFF000000);

  static const Color electricPotentialGridSaturationPositive =
      Color(0xFFD20000);
  static const Color electricPotentialGridZero = Color(0xFF000000);
  static const Color electricPotentialGridSaturationNegative =
      Color(0xFF0000FF);

  // Charge radial gradient stops (ChargedParticleRepresentationNode)
  static const Color positiveChargeOuter = Color(0xFFFF2B4F);
  static const Color positiveChargeMid = Color(0xFFF53C2C);
  static const Color positiveChargeInner = Color(0xFFE80900);

  static const Color negativeChargeOuter = Color(0xFF4FCFFF);
  static const Color negativeChargeMid = Color(0xFF2CBEF5);
  static const Color negativeChargeInner = Color(0xFF00A9E8);
}
