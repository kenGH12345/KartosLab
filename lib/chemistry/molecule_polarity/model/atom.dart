import 'package:flutter/material.dart';

import '../mp_colors.dart';
import '../mp_constants.dart';
import 'mp_vector2.dart';

/// Make-believe atom with mutable electronegativity.
/// Source: `js/common/model/Atom.ts`
class MpAtom {
  MpAtom({
    required this.label,
    required this.color,
    double? diameter,
    MpVector2? position,
    double? electronegativity,
  })  : diameter = diameter ?? MpConstants.atomDiameter,
        position = position ?? MpVector2.zero,
        electronegativity =
            electronegativity ?? MpConstants.electronegativityDefault,
        _initialElectronegativity =
            electronegativity ?? MpConstants.electronegativityDefault;

  final String label; // 'A' | 'B' | 'C'
  final Color color;
  final double diameter;
  final double _initialElectronegativity;

  MpVector2 position;
  double electronegativity;
  double partialCharge = 0;

  double get radius => diameter / 2;

  void reset() {
    electronegativity = _initialElectronegativity;
    // position / partialCharge reset by parent molecule
  }
}

MpAtom createAtomA({double? electronegativity}) => MpAtom(
      label: 'A',
      color: MpColors.atomA,
      electronegativity: electronegativity,
    );

MpAtom createAtomB({double? electronegativity}) => MpAtom(
      label: 'B',
      color: MpColors.atomB,
      electronegativity:
          electronegativity ?? MpConstants.electronegativityMid,
    );

MpAtom createAtomC({double? electronegativity}) => MpAtom(
      label: 'C',
      color: MpColors.atomC,
      electronegativity: electronegativity,
    );
