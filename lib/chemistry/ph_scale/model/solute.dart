import 'dart:ui';

import 'ph_scale_constants.dart';
import 'water.dart';

/// Immutable solute stock — PhET `Solute.ts`.
///
/// No Ka/Kb: each solute is a stock solution with fixed [pH] and colors.
class Solute {
  const Solute({
    required this.id,
    required this.name,
    required this.pH,
    required this.stockColor,
    this.dilutedColor = Water.color,
    this.colorStopColor,
    this.colorStopRatio = 0.25,
  }) : assert(colorStopRatio > 0 && colorStopRatio < 1);

  final String id;
  final String name;
  final double pH;
  final Color stockColor;
  final Color dilutedColor;
  final Color? colorStopColor;
  final double colorStopRatio;

  /// Dilution color for [ratio] in [0,1] (0 = no solute, 1 = all solute).
  Color computeColor(double ratio) {
    assert(ratio >= 0 && ratio <= 1);
    final stop = colorStopColor;
    if (stop != null) {
      if (ratio > colorStopRatio) {
        return Color.lerp(
          stop,
          stockColor,
          (ratio - colorStopRatio) / (1 - colorStopRatio),
        )!;
      }
      return Color.lerp(dilutedColor, stop, ratio / colorStopRatio)!;
    }
    return Color.lerp(dilutedColor, stockColor, ratio)!;
  }

  // --- Static instances (alphabetical English order for combo box) ---

  static final batteryAcid = Solute(
    id: 'batteryAcid',
    name: 'Battery Acid',
    pH: 1,
    stockColor: const Color.fromARGB(255, 255, 255, 0),
    colorStopColor: const Color.fromARGB(255, 255, 224, 204),
  );

  static final blood = Solute(
    id: 'blood',
    name: 'Blood',
    pH: 7.4,
    stockColor: const Color.fromARGB(255, 211, 79, 68),
    colorStopColor: const Color.fromARGB(255, 255, 207, 204),
  );

  static final chickenSoup = Solute(
    id: 'chickenSoup',
    name: 'Chicken Soup',
    pH: 5.8,
    stockColor: const Color.fromARGB(255, 255, 240, 104),
    colorStopColor: const Color.fromARGB(255, 255, 250, 204),
  );

  static final coffee = Solute(
    id: 'coffee',
    name: 'Coffee',
    pH: 5,
    stockColor: const Color.fromARGB(255, 164, 99, 7),
    colorStopColor: const Color.fromARGB(255, 255, 240, 204),
  );

  static final drainCleaner = Solute(
    id: 'drainCleaner',
    name: 'Drain Cleaner',
    pH: 13,
    stockColor: const Color.fromARGB(255, 255, 255, 0),
    colorStopColor: const Color.fromARGB(255, 255, 255, 204),
  );

  static final handSoap = Solute(
    id: 'handSoap',
    name: 'Hand Soap',
    pH: 10,
    stockColor: const Color.fromARGB(255, 224, 141, 242),
    colorStopColor: const Color.fromARGB(255, 232, 204, 255),
  );

  static final milk = Solute(
    id: 'milk',
    name: 'Milk',
    pH: 6.5,
    stockColor: const Color.fromARGB(255, 250, 250, 250),
  );

  static final orangeJuice = Solute(
    id: 'orangeJuice',
    name: 'Orange Juice',
    pH: 3.5,
    stockColor: const Color.fromARGB(255, 255, 180, 0),
    colorStopColor: const Color.fromARGB(255, 255, 242, 204),
  );

  static final soda = Solute(
    id: 'soda',
    name: 'Soda',
    pH: 2.5,
    stockColor: const Color.fromARGB(255, 204, 255, 102),
    colorStopColor: const Color.fromARGB(255, 238, 255, 204),
  );

  static final spit = Solute(
    id: 'spit',
    name: 'Spit',
    pH: 7.4,
    stockColor: const Color.fromARGB(255, 202, 240, 239),
  );

  static final vomit = Solute(
    id: 'vomit',
    name: 'Vomit',
    pH: 2,
    stockColor: const Color.fromARGB(255, 255, 171, 120),
    colorStopColor: const Color.fromARGB(255, 255, 224, 204),
  );

  static final water = Solute(
    id: 'water',
    name: Water.name,
    pH: Water.pH,
    stockColor: Water.color,
  );

  /// Combo-box order (English alphabetical) — `PHModel.ts` L82–95.
  static final List<Solute> allAlphabetical = [
    batteryAcid,
    blood,
    chickenSoup,
    coffee,
    drainCleaner,
    handSoap,
    milk,
    orangeJuice,
    soda,
    spit,
    vomit,
    water,
  ];

  static void assertPhInRange(double pH) {
    assert(
      pH >= PhScaleConstants.phMin && pH <= PhScaleConstants.phMax,
      'invalid pH: $pH',
    );
  }
}
