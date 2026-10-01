import 'package:flutter/material.dart';

/// Colors from PhET `BlackbodyColors.js` — default profile (black background).
///
/// [来源: phet/js/blackbody-spectrum/view/BlackbodyColors.js:16-71]
class BlackbodySpectrumColors {
  BlackbodySpectrumColors._();

  /// [来源: BlackbodyColors.js:19-22] default='black'
  static const Color background = Colors.black;

  /// [来源: BlackbodyColors.js:23-26] default='white'
  static const Color panelStroke = Colors.white;

  /// [来源: BlackbodyColors.js:27-30] default='white'
  static const Color panelText = Colors.white;

  /// [来源: BlackbodyColors.js:31-34] default='white'
  static const Color graphAxesStroke = Colors.white;

  /// [来源: BlackbodyColors.js:35-38] default='yellow'
  static const Color graphValuesDashedLine = Colors.yellow;

  /// [来源: BlackbodyColors.js:39-42] default='yellow'
  static const Color graphValuesLabels = Colors.yellow;

  /// [来源: BlackbodyColors.js:43-46] default='white'
  static const Color graphValuesPoint = Colors.white;

  /// [来源: BlackbodyColors.js:47-50] default='white'
  static const Color titlesText = Colors.white;

  /// [来源: BlackbodyColors.js:51-54] default='white'
  static const Color thermometerTubeStroke = Colors.white;

  /// [来源: BlackbodyColors.js:55-58] default='black'
  static const Color thermometerTrack = Colors.black;

  /// [来源: BlackbodyColors.js:59-62] default=Color.YELLOW
  static const Color temperatureText = Colors.yellow;

  /// [来源: BlackbodyColors.js:63-66] default='white'
  static const Color triangleStroke = Colors.white;

  /// [来源: BlackbodyColors.js:67-70] default='rgba(0,0,0,0)'
  static const Color starStroke = Color(0x00000000);

  // —— Additional colors from view components ——

  /// Main curve color (red colorblind). [来源: GraphDrawingNode.js:73-74]
  static const Color mainCurve = Color.fromRGBO(180, 95, 95, 1);

  /// Saved curve stroke. [来源: SavedGraphInformationPanel.js:42]
  static const Color savedCurve = Colors.grey;

  /// Triangle thumb fill. [来源: TriangleSliderThumb.js:38]
  static const Color triangleFill = Color.fromRGBO(50, 145, 184, 1);

  /// Triangle thumb fill highlighted. [来源: TriangleSliderThumb.js:39]
  static const Color triangleFillHighlighted = Color.fromRGBO(71, 207, 255, 1);

  /// Cueing arrows color (green). [来源: TriangleSliderThumb.js:44]
  static const Color cueingArrow = Color.fromRGBO(50, 220, 50, 1);

  /// Panel fill transparent. [来源: SavedGraphInformationPanel.js:35]
  static const Color panelFill = Color(0x00000000);
}
