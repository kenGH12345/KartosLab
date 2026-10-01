import 'package:flutter/material.dart';

/// Colors from PhET `js/common/FMWColors.ts`.
class FmwColors {
  FmwColors._();

  /// Harmonic rainbow, order 1..11. `FMWColors.ts` HARMONIC_COLORS
  static const List<Color> harmonicColors = [
    Color.fromRGBO(255, 0, 0, 1),
    Color.fromRGBO(255, 128, 0, 1),
    Color.fromRGBO(255, 210, 0, 1),
    Color.fromRGBO(0, 255, 0, 1),
    Color.fromRGBO(0, 201, 87, 1),
    Color.fromRGBO(100, 149, 237, 1),
    Color.fromRGBO(0, 0, 255, 1),
    Color.fromRGBO(0, 0, 128, 1),
    Color.fromRGBO(145, 33, 158, 1),
    Color.fromRGBO(186, 85, 211, 1),
    Color.fromRGBO(255, 105, 180, 1),
  ];

  static Color harmonicColor(int order) {
    assert(order >= 1 && order <= harmonicColors.length);
    return harmonicColors[order - 1];
  }

  static const Color discreteScreenBackground = Color.fromRGBO(236, 255, 255, 1);
  static const Color waveGameScreenBackground = Color.fromRGBO(236, 255, 255, 1);
  static const Color wavePacketScreenBackground = Color.fromRGBO(255, 250, 227, 1);

  /// Chart plot area fill (white / cream backgrounds used by screens).
  static const Color chartBackground = Colors.white;
  static const Color chartBackgroundCream = Color.fromRGBO(255, 250, 227, 1);

  static const Color panelFill = Color.fromRGBO(245, 245, 245, 1);
  static const Color panelStroke = Color.fromRGBO(160, 160, 160, 1);
  static const Color separatorStroke = Color.fromRGBO(200, 200, 200, 1);

  static const Color amplitudesGridLinesStroke = Colors.black;
  static const Color chartGridLinesStroke = Color.fromRGBO(200, 200, 200, 1);
  static const Color axisStroke = Color.fromRGBO(170, 170, 170, 1);

  static const Color sumPlotStroke = Colors.black;

  /// Wave Game answer waveform. `FMWColors.ts` answerSumPlotStroke = magenta
  static const Color answerSumPlotStroke = Color.fromRGBO(255, 0, 255, 1);

  static const Color guessSumPlotStroke = Colors.black;
  static const Color secondaryWaveformStroke = Color.fromRGBO(189, 189, 189, 1);

  static const Color levelSelectionButtonFill = Color.fromRGBO(255, 214, 228, 1);
  static const Color widthIndicatorsColor = Colors.red;
  static const Color componentSpacingToolFill = Colors.yellow;
  static const Color wavePacketLengthToolFill = Color.fromRGBO(0, 255, 0, 1);

  /// Gray range for Wave Packet Fourier component strokes. [0, 230]
  static const double fourierComponentGrayMin = 0;
  static const double fourierComponentGrayMax = 230;
}
