import 'dart:ui';

import 'solute.dart';
import 'solute_color_scheme.dart';
import 'solvent.dart';

/// All 9 solutes — beers-law-lab `Solute.ts` static instances (ROYGBIV order).
abstract final class SoluteDefinitions {
  static final Solute drinkMix = Solute(
    id: 'drinkMix',
    displayName: 'Drink mix',
    stockSolutionConcentration: 5.5,
    molarMass: 342.296, // sucrose
    colorScheme: SoluteColorScheme(
      minConcentration: 0,
      minColor: const Color.fromARGB(255, 224, 255, 255),
      midConcentration: 0.05,
      midColor: const Color.fromARGB(255, 255, 225, 225),
      maxConcentration: 5.96,
      maxColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  static final Solute cobaltIINitrate = Solute(
    id: 'cobaltIINitrate',
    displayName: 'Cobalt(II) nitrate',
    formula: 'Co(NO<sub>3</sub>)<sub>2</sub>',
    stockSolutionConcentration: 5.0,
    molarMass: 182.942,
    colorScheme: SoluteColorScheme(
      minConcentration: 0,
      minColor: Solvent.water.color,
      midConcentration: 0.05,
      midColor: const Color.fromARGB(255, 255, 225, 225),
      maxConcentration: 5.64,
      maxColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  static final Solute cobaltChloride = Solute(
    id: 'cobaltChloride',
    displayName: 'Cobalt(II) chloride',
    formula: 'CoCl<sub>2</sub>',
    stockSolutionConcentration: 4.0,
    molarMass: 129.839,
    colorScheme: SoluteColorScheme(
      minConcentration: 0,
      minColor: Solvent.water.color,
      midConcentration: 0.05,
      midColor: const Color.fromARGB(255, 255, 242, 242),
      maxConcentration: 4.33,
      maxColor: const Color.fromARGB(255, 255, 106, 106),
    ),
  );

  static final Solute potassiumDichromate = Solute(
    id: 'potassiumDichromate',
    displayName: 'Potassium dichromate',
    formula: 'K<sub>2</sub>Cr<sub>2</sub>O<sub>7</sub>',
    stockSolutionConcentration: 0.5,
    molarMass: 294.185,
    colorScheme: SoluteColorScheme(
      minConcentration: 0,
      minColor: Solvent.water.color,
      midConcentration: 0.01,
      midColor: const Color.fromARGB(255, 255, 204, 153),
      maxConcentration: 0.51,
      maxColor: const Color.fromARGB(255, 255, 127, 0),
    ),
  );

  static final Solute potassiumChromate = Solute(
    id: 'potassiumChromate',
    displayName: 'Potassium chromate',
    formula: 'K<sub>2</sub>CrO<sub>4</sub>',
    stockSolutionConcentration: 3.0,
    molarMass: 194.191,
    colorScheme: SoluteColorScheme(
      minConcentration: 0,
      minColor: Solvent.water.color,
      midConcentration: 0.05,
      midColor: const Color.fromARGB(255, 255, 255, 153),
      maxConcentration: 3.35,
      maxColor: const Color.fromARGB(255, 255, 255, 0),
    ),
  );

  static final Solute nickelIIChloride = Solute(
    id: 'nickelIIChloride',
    displayName: 'Nickel(II) chloride',
    formula: 'NiCl<sub>2</sub>',
    stockSolutionConcentration: 5.0,
    molarMass: 129.599,
    colorScheme: SoluteColorScheme(
      minConcentration: 0,
      minColor: Solvent.water.color,
      midConcentration: 0.2,
      midColor: const Color.fromARGB(255, 170, 255, 170),
      maxConcentration: 5.21,
      maxColor: const Color.fromARGB(255, 0, 128, 0),
    ),
  );

  static final Solute copperSulfate = Solute(
    id: 'copperSulfate',
    displayName: 'Copper(II) sulfate',
    formula: 'CuSO<sub>4</sub>',
    stockSolutionConcentration: 1.0,
    molarMass: 159.609,
    colorScheme: SoluteColorScheme(
      minConcentration: 0,
      minColor: Solvent.water.color,
      midConcentration: 0.2,
      midColor: const Color.fromARGB(255, 200, 225, 255),
      maxConcentration: 1.38,
      maxColor: const Color.fromARGB(255, 30, 144, 255),
    ),
  );

  static final Solute potassiumPermanganate = Solute(
    id: 'potassiumPermanganate',
    displayName: 'Potassium permanganate',
    formula: 'KMnO<sub>4</sub>',
    stockSolutionConcentration: 0.4,
    molarMass: 158.034,
    colorScheme: SoluteColorScheme(
      minConcentration: 0,
      minColor: Solvent.water.color,
      midConcentration: 0.01,
      midColor: const Color.fromARGB(255, 255, 0, 255),
      maxConcentration: 0.48,
      maxColor: const Color.fromARGB(255, 80, 0, 120),
    ),
    particleFill: const Color.fromARGB(255, 0, 0, 0),
  );

  static final Solute sodiumChloride = Solute(
    id: 'sodiumChloride',
    displayName: 'Sodium chloride',
    formula: 'NaCl',
    stockSolutionConcentration: 5.50,
    molarMass: 58.443,
    colorScheme: SoluteColorScheme(
      minConcentration: 0,
      minColor: Solvent.water.color,
      midConcentration: 5.00,
      midColor: const Color.fromARGB(255, 225, 250, 250),
      maxConcentration: 6.15,
      maxColor: const Color.fromARGB(255, 225, 240, 240),
    ),
  );

  /// ROYGBIV order — `ConcentrationModel` constructor.
  static final List<Solute> all = [
    drinkMix,
    cobaltIINitrate,
    cobaltChloride,
    potassiumDichromate,
    potassiumChromate,
    nickelIIChloride,
    copperSulfate,
    potassiumPermanganate,
    sodiumChloride,
  ];
}
