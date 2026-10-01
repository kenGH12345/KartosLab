import 'dart:ui';

import 'ph_scale_colors.dart';

/// Water solvent — PhET `Water.ts`.
///
/// **Critical:** concentration is **55 mol/L**, not 55.6.
class Water {
  Water._();

  static const String name = 'Water';
  static const double pH = 7;
  static const double concentration = 55; // mol/L
  static const Color color = PhScaleColors.water;
}
