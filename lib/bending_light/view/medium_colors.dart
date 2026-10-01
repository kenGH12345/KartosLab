import 'dart:ui';

import '../model/substance.dart';

/// View wrapper around `MediumColorFactory`. Intro backgrounds stay on the white profile.
class MediumColors {
  MediumColors._();

  static Color getColorAgainstWhite(double indexForRed) =>
      Color(MediumColorFactory().getColor(indexForRed));

  static Color forSubstance(Substance s) =>
      getColorAgainstWhite(s.indexOfRefractionForRedLight);
}
