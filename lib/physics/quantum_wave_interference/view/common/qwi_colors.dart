import 'package:flutter/material.dart';

/// Port of `QuantumWaveInterferenceColors.ts` defaults.
class QwiColors {
  QwiColors._();

  static const Color screenBackground = Color(0xFFFFFFFF);
  static const Color panelFill = Color(0xFFF4F4F4);
  static const Color panelStroke = Color(0xFFC1C1C1);
  static const Color particleBeam = Color(0xFFB4B4B4);
  static const Color slitCoverFill = Color(0xFF3F3F3F);
  static const Color detectorOverlayFill = Color(0xFFFFC832);
  static const Color detectorOverlayStroke = Color(0xFFB48C00);

  /// PhetColorScheme.GREEN_COLORBLIND @ 0.65 alpha.
  static const Color probeDetectedFill = Color(0xA635AD35);

  static const Color probeReadyFill = Color(0x4D87CEFA); // skyblue @ 0.3
  static const Color probeNotDetectedFill = Color(0x80505050); // gray @ 0.5
  static const Color probeStroke = Color(0xFF323232);
  static const Color probeWire = Color(0xFF646464);

  static const Color frontFacingStroke = Color(0xFF333333);
  static const Color graphGridLine = Color(0xFFC8C8C8);
  static const Color graphAccordionStroke = Color(0xFFA0A0A0);

  /// Snapshot / Detect button base (PhET soft blue-gray push button family).
  static const Color snapshotButtonBase = Color(0xFFD4E4F7);

  static const Color selectedControl = Color(0xFF337AB7);
  static const Color unselectedControl = Color(0xFFE8E8E8);
}
