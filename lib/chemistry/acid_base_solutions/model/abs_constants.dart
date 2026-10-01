import 'dart:ui';

import 'abs_range.dart';

/// Constants from PhET `js/common/ABSConstants.ts`.
class AbsConstants {
  AbsConstants._();

  // --- Chemistry ---

  static const AbsRange phRange = AbsRange(0, 14);

  /// Acid/base solute concentration (mol/L).
  static const AbsRangeWithValue concentrationRange =
      AbsRangeWithValue(1e-3, 1, 1e-2);

  static const double _weakStrengthMax = 1e2;

  /// Strong acids/bases use a constant strength marker (> weak max).
  static const double strongStrength = _weakStrengthMax + 1; // 101

  static const AbsRangeWithValue strongStrengthRange =
      AbsRangeWithValue(strongStrength, strongStrength, strongStrength);

  /// Weak acid Ka / weak base Kb (unitless ionization constant).
  static const AbsRangeWithValue weakStrengthRange =
      AbsRangeWithValue(1e-10, _weakStrengthMax, 1e-7);

  /// Pure water concentration W (mol/L).
  static const double waterConcentration = 55.6;

  static const AbsRangeWithValue waterConcentrationRange = AbsRangeWithValue(
    waterConcentration,
    waterConcentration,
    waterConcentration,
  );

  static const double waterStrength = 0;

  static const AbsRangeWithValue waterStrengthRange =
      AbsRangeWithValue(waterStrength, waterStrength, waterStrength);

  /// Kw = [H3O+][OH-] = 1e-14.
  static const double waterEquilibriumConstant = 1e-14;

  /// My Solution concentration spinner — `InitialConcentrationControl.ts`.
  static const int concentrationDecimals = 3;
  static final double deltaConcentration =
      mathPow10(-concentrationDecimals); // 0.001

  // --- Beaker / layout (model ≡ view 1:1) ---

  /// `ABSScreenView` layoutBounds.
  static const Size layoutBounds = Size(768, 504);

  static const Size beakerSize = Size(360, 270);
  static const Offset beakerPosition = Offset(230, 410);

  /// pH paper float speed — `PHPaperNode.step`.
  static const double phPaperFloatSpeed = 250; // px/s

  /// Conductivity — `ConductivityTester.ts`.
  static const double neutralPh = 7;
  static const double neutralBrightness = 0.05;

  // --- Particles — `ParticlesCanvasNode.ts` ---

  static const double particleBaseConcentration = 1e-7;
  static const int particleBaseDots = 2;
  static const int particleMaxCount = 200;

  static double mathPow10(int n) {
    var r = 1.0;
    final abs = n.abs();
    for (var i = 0; i < abs; i++) {
      r *= 10;
    }
    return n < 0 ? 1 / r : r;
  }
}
