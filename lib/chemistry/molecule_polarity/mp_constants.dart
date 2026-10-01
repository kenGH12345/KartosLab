/// Molecule Polarity layout & chemistry constants.
/// Source: `js/common/MPConstants.ts` + `MPModel.ts` MAX_RADIANS_PER_STEP.
library;

import 'dart:math' as math;

abstract final class MpConstants {
  static const double layoutWidth = 1100;
  static const double layoutHeight = 700;

  static const double electronegativityMin = 2;
  static const double electronegativityMax = 4;
  static const double electronegativityDefault = 2;
  static const double electronegativityTickSpacing = 0.2;

  static double get electronegativityRangeLength =>
      electronegativityMax - electronegativityMin;

  /// Midpoint of EN range (= 3.0) — default for atom B.
  static double get electronegativityMid =>
      electronegativityMin + electronegativityRangeLength / 2;

  static const double atomDiameter = 100;
  static const double bondLength = 150;

  static const double angleMin = -math.pi;
  static const double angleMax = math.pi;

  static const double surfaceGradientWidthMultiplier = 5;

  static const double controlPanelTop = 65;
  static const double horizontalMargin = 40;
  static const double verticalMargin = 20;
  static const double controlPanelYSpacing = 15;

  /// E-field alignment max step (radians per frame). `MPModel.ts`.
  static const double maxRadiansPerStep = 0.17;

  /// Molecule angle drag quantization (degrees).
  static const double angleDragSnapDegrees = 5;

  /// Two Atoms molecule center in model coords (`TwoAtomsScreenView`).
  static const double twoAtomsMoleculeX = 380;
  static const double twoAtomsMoleculeY = 280;

  /// Three Atoms molecule center (`ThreeAtomsScreenView`).
  static const double threeAtomsMoleculeX = 400;
  static const double threeAtomsMoleculeY = 280;

  static const double platesSpacingTwoAtoms = 500;
  static const double platesSpacingThreeAtoms = 600;
}
