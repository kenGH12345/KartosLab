/// Re-export PhET colors from [GaoConstants].
library;

import 'package:flutter/material.dart';

import 'gao_constants.dart';

export 'gao_constants.dart' show GaoConstants;

class GaoColors {
  GaoColors._();

  static const Color background = GaoConstants.background;
  static const Color foreground = GaoConstants.foreground;
  static const Color controlPanelStroke = GaoConstants.controlPanelStroke;
  static const Color gravitationalForce = GaoConstants.gravitationalForce;
  static const Color velocity = GaoConstants.velocity;
  static const Color vectorOutline = GaoConstants.vectorOutline;
  static const Color returnObjectsBg = GaoConstants.returnObjectsBg;

  /// PhET time-control round button fill.
  static const Color playBlue = Color(0xFF6DCEF8);
}
