import 'dart:ui';

import 'ph_scale_colors.dart';
import 'package:kratos/chemistry/ph_scale/phs_strings.dart';

/// Water solvent — PhET `Water.ts`.
///
/// **Critical:** concentration is **55 mol/L**, not 55.6.
class Water {
  Water._();

  static const String name = PhsStrings.water;
  static const double pH = 7;
  static const double concentration = 55; // mol/L
  static const Color color = PhScaleColors.water;
}
