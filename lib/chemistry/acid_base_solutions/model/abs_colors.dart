import 'dart:ui';

/// Colors from PhET `js/common/ABSColors.ts` needed by the model layer.
///
/// Particle colors are static (not ProfileColorProperty) in source.
class AbsColors {
  AbsColors._();

  // --- Screen / panels (ABSColors.ts) ---
  static const Color screenBackground = Color.fromRGBO(255, 255, 255, 1);
  static const Color controlPanelFill = Color.fromRGBO(208, 212, 255, 1);
  static const Color toolRadioButtonFill = Color.fromRGBO(255, 255, 255, 1);
  static const Color graphFill = Color.fromRGBO(255, 255, 255, 1);

  static const Color pHProbeShaftFill = Color.fromRGBO(192, 192, 192, 1);
  static const Color pHProbeTipFill = Color.fromRGBO(0, 0, 0, 1);
  static const Color magnifyingGlassHandleFill = Color.fromRGBO(85, 55, 33, 1);

  static const Color opaqueSolutionColor = Color.fromRGBO(211, 232, 236, 1);
  static const Color transparentSolutionColor = Color.fromRGBO(193, 222, 227, 0.7);

  static const Color grayParticle = Color.fromRGBO(120, 120, 120, 1);

  /// `PhetColorScheme.RED_COLORBLIND` ≈ rgb(255, 85, 0) used for H3O.
  /// PhET scenery-phet RED_COLORBLIND is typically `rgb(255,85,0)`.
  static const Color h3o = Color.fromRGBO(255, 85, 0, 1);

  static const Color a = Color.fromRGBO(0, 170, 255, 1);
  static const Color b = grayParticle;
  static const Color bh = Color.fromRGBO(255, 170, 0, 1);
  static const Color h2o = Color.fromRGBO(164, 189, 193, 1);
  static const Color ha = grayParticle;
  static const Color m = Color.fromRGBO(255, 170, 0, 1);
  static const Color moh = grayParticle;
  static const Color oh = Color.fromRGBO(90, 90, 255, 1);

  /// Blank pH paper fill — cream.
  static const Color phPaperFill = Color.fromRGBO(217, 215, 154, 1);

  /// pH paper indicator colors for integer pH 0–14.
  static const List<Color> phPaperColors = [
    Color.fromRGBO(198, 32, 97, 1), // 0
    Color.fromRGBO(219, 66, 63, 1), // 1
    Color.fromRGBO(222, 103, 40, 1), // 2
    Color.fromRGBO(216, 127, 63, 1), // 3
    Color.fromRGBO(218, 164, 68, 1), // 4
    Color.fromRGBO(198, 178, 46, 1), // 5
    Color.fromRGBO(177, 176, 57, 1), // 6
    Color.fromRGBO(85, 149, 81, 1), // 7
    Color.fromRGBO(79, 135, 72, 1), // 8
    Color.fromRGBO(51, 108, 80, 1), // 9
    Color.fromRGBO(48, 96, 75, 1), // 10
    Color.fromRGBO(0, 90, 98, 1), // 11
    Color.fromRGBO(24, 70, 111, 1), // 12
    Color.fromRGBO(23, 51, 91, 1), // 13
    Color.fromRGBO(0, 35, 49, 1), // 14
  ];

  /// `PHPaper.ts` `pHToColor` — integer lookup or RGBA interpolate.
  static Color pHToColor(double pH) {
    assert(pH >= 0 && pH <= phPaperColors.length - 1);
    // Match JS `Number.isInteger(pH)`.
    if (pH == pH.roundToDouble()) {
      return phPaperColors[pH.toInt()];
    }
    final lowerPh = pH.floor();
    final upperPh = lowerPh + 1;
    final t = pH - lowerPh;
    return Color.lerp(phPaperColors[lowerPh], phPaperColors[upperPh], t)!;
  }
}
