import 'package:flutter/material.dart';

import 'data/bam_element.dart';

/// Layout + color constants. Ported from BAMConstants.ts.
class BamConstants {
  BamConstants._();

  // Approximate model size from PhET MODEL_VIEW_TRANSFORM (scale ~0.324).
  // VIEW ~768×504 → model ≈ 2370×1556.
  static const Size modelSize = Size(2370, 1556);
  static const double modelPadding = 55.6;
  static const double viewPadding = 18;
  static const double textMaxWidth = 200;
  static const double cornerRadius = 4;
  static const double dragLengthThreshold = 5000;

  static const Color playAreaBackgroundColor = Color.fromARGB(255, 198, 226, 246);
  static const Color moleculeCollectionBackground = Color.fromARGB(255, 238, 238, 238);
  static const Color moleculeCollectionBoxHighlight = Color(0xFFFFFF00);
  static const Color moleculeCollectionBoxBorderBlink = Color(0xFF0000FF);
  static const Color kitBackground = Colors.white;
  static const Color kitBorder = Colors.black;
  static const Color kitArrowBackgroundEnabled = Color(0xFFFFFF00);
  static const Color kitArrowBorderEnabled = Colors.black;
  static const Color completeBackgroundColor = Color.fromARGB(255, 238, 238, 238);

  static final List<BamElement> supportedElements = BamElement.supportedElements;

  /// Contrast text on element-colored atoms (light elements → dark text).
  static Color atomTextColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.55 ? Colors.black : Colors.white;
  }
}
