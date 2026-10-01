import 'dart:ui';

/// Solvent model — beers-law-lab `Solvent.ts`.
class Solvent {
  const Solvent({
    required this.name,
    required this.formula,
    required this.density,
    required this.color,
  });

  final String name;
  final String formula;
  final double density; // g/L
  final Color color;

  /// Pure water — only solvent in this sim.
  static const Solvent water = Solvent(
    name: 'water',
    formula: 'H<sub>2</sub>O',
    density: 1000,
    color: Color.fromARGB(255, 224, 255, 255), // BLLColors.WATER
  );
}
