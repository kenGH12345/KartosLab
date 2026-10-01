import 'package:flutter/material.dart';

import '../../model/substance.dart';
import 'formula_text.dart';
import 'molecule_icon.dart';

/// Substance visual for Game RandomBox / quantities.
/// Uses [MoleculeIcon] for the full Game/Molecules pool; FormulaText chip
/// only if [Substance.iconId] is unknown.
class SubstanceIcon extends StatelessWidget {
  const SubstanceIcon({
    super.key,
    required this.substance,
    this.scale = 1.0,
  });

  final Substance substance;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final id = RpalMoleculeIdX.fromIconId(substance.iconId);
    if (id != null) {
      return MoleculeIcon(id: id, scale: scale);
    }
    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FE),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF3176C4), width: 0.5),
        ),
        child: FormulaText(
          symbolHtml: substance.symbol,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }
}
