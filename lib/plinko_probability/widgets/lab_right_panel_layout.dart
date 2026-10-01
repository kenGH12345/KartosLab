import 'package:flutter/material.dart';

/// Lab right-stack layout — `LabScreenView.js` + child panels.
///
/// All values are ScreenView **layout** px (× layoutScale in view).
class LabRightPanelLayout {
  LabRightPanelLayout._();

  static const double panelFixedWidth = 220;
  static const double panelCornerRadius = 10;
  static const double panelVerticalSpacing = 7; // PANEL_VERTICAL_SPACING
  static const double panelRightPadding = 30;

  // LabPlayPanel
  static const double playXMargin = 10;
  static const double playYMargin = 10;
  static const double playHBoxSpacing = 20;
  static const double playRadioSpacing = 13;
  static const double playRadioRadius = 8;
  static const double playButtonRadius = 30; // PLAY_PAUSE_BUTTON_RADIUS
  /// PlayButton.js baseColor
  static const Color playBaseColor = Color.fromRGBO(0, 224, 121, 1);

  // PegControls
  static const double pegXMargin = 10;
  static const double pegYMargin = 8;
  static const double pegVBoxSpacing = 20;
  static const double sliderTrackW = 170;
  static const double sliderTrackH = 2;

  // StatisticsAccordionBox
  static const double statsContentXMargin = 8;
  static const double statsContentYMargin = 10;
  static const double statsContentYSpacing = 10;
  static const double statsHBoxSpacing = 5;
  static const double expandButtonSide = 20;
  static const Color statsFill = Color.fromRGBO(255, 245, 238, 1);
}
