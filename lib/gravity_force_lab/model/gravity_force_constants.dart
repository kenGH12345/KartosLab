import 'dart:math' as math;
import 'dart:ui' show Color;

/// Constants from PhET `GravityForceLabConstants.js`, `ISLCConstants.js`,
/// `PhysicalConstants.js`, `GravityForceLabModel.js`, `MassNode.js`,
/// `GravityForceLabScreenView.js`, and `ISLCRulerNode.js`.
///
/// Full Version only — do not reuse Basics (billion kg / km / G=6.67430e-11).
class GravityForceConstants {
  GravityForceConstants._();

  // —— Physics (phet-core PhysicalConstants) ——
  /// G = 6.67408E-11 m³ kg⁻¹ s⁻²
  static const double gravitationalConstant = 6.67408e-11;

  static const double massMin = 10; // kg
  static const double massMax = 1000; // kg
  static const double massSliderInterval = 10;
  static const double massKeyboardStep = 50;
  /// MassControl / NumberControl shift step (interval-aligned).
  static const double massShiftKeyboardStep = 10;
  static const double massPageKeyboardStep = 100;
  static const double massDensity = 150; // kg/m³

  /// ISLCConstants.CONSTANT_RADIUS — used when Constant Size is ON.
  static const double constantRadius = 0.5; // m

  static const double pullPositionMax = 5; // m
  static const double positionSnap = 0.1; // m
  static const double positionStepSize = 0.5; // m (keyboard)
  /// AccessibleSlider pageKeyboardStep = stepSize * 2.
  static const double positionPageStepSize = 1.0; // m
  static const double minSeparationBetweenObjects = 0.1; // m surface gap

  static const double initialMass1 = 100; // kg
  static const double initialMass2 = 400; // kg
  static const double initialPosition1 = -3; // m
  static const double initialPosition2 = 1; // m

  static const bool defaultConstantRadius = false;

  /// Mass.js baseColor brighter factor when Constant Size is OFF.
  static const double baseColorModifier = 0.59;

  static const Color mass1BaseColor = Color(0xFF0000FF);
  static const Color mass2BaseColor = Color(0xFFFF0000);
  static const Color backgroundColor = Color(0xFFFFFFFF);

  // —— Force notation (ISLCConstants) ——
  static const int decimalNotationPrecision = 12;
  static const int scientificNotationPrecision = 2;

  // —— Force arrow mapping (MassNode → ISLCForceArrowNode) ——
  /// Prepared for View; must not inherit Basics (max 400 / threshold 7e-4).
  static const double minArrowWidth = 0.1;
  static const double thresholdArrowWidth = 1;
  static const double maxArrowWidth = 700;
  static const double forceThresholdPercent = 1.6e-4;
  static const double arrowLengthFactor = 8;
  static const double forceArrowHeight1 = 85;
  static const double forceArrowHeight2 = 135;
  static const bool mapArrowWidthWithTwoFunctions = true;

  // —— Layout / MVT (ScreenView) ——
  static const double layoutWidth = 768;
  static const double layoutHeight = 464;
  static const double mvtScale = 50; // view px per model meter
  static const double massNodeY = 185;

  // —— Ruler (ISLCRulerNode + ScreenView wiring) ——
  static const double rulerWidthView = 500;
  static const double rulerHeightView = 35;
  static const double rulerInitialX = 0;
  static const double rulerInitialY = -1;
  static const double rulerSnap = 0.1;
  /// ISLCRulerNode: dragDelta = 2 × snap (model).
  static const double rulerKeyboardStep = 0.2;
  /// ISLCRulerNode: shiftDragDelta = snap.
  static const double rulerShiftKeyboardStep = 0.1;
  static const double rulerModelYForCenterJump = 0.5;

  /// Half ruler width in model meters (zero-mark alignment offset).
  static double get rulerHalfWidthModel =>
      (rulerWidthView / 2) / mvtScale; // 5 m

  /// Drag bounds after ISLCRulerNode extends maxX by half ruler width.
  /// Vertical bounds from ScreenView MVT formulas (centerY=232).
  static const double rulerDragMinX = -pullPositionMax; // -5
  static const double rulerDragMaxX =
      pullPositionMax + (rulerWidthView / 2) / mvtScale; // 10
  /// Top of layout half-height in model (positive Y up).
  static const double rulerDragMaxY = (layoutHeight / 2) / mvtScale; // 4.64
  /// Conservative lower bound near mass controls (~view Y 326 → model ≈ -1.88).
  static const double rulerDragMinY = -2.0;

  /// Half ruler height dilation in model meters.
  static double get rulerHalfHeightModel =>
      (rulerHeightView / 2) / mvtScale; // 0.35

  /// Radius from mass at constant density (Mass.calculateRadius).
  static double calculateRadius(double mass, [double density = massDensity]) {
    return math.pow((3 * mass / density) / (4 * math.pi), 1 / 3).toDouble();
  }

  static double snapToGrid(double position, [double snap = positionSnap]) {
    if (snap <= 0) return position;
    var snapped = _roundSymmetric(position / snap) * snap;
    snapped = double.parse(snapped.toStringAsFixed(_decimalPlaces(snap)));
    return snapped.clamp(-pullPositionMax, pullPositionMax).toDouble();
  }

  static double roundMassToInterval(double value) {
    final stepped = _roundSymmetric(value / massSliderInterval) * massSliderInterval;
    return stepped.clamp(massMin, massMax).toDouble();
  }

  static double _roundSymmetric(double value) =>
      value < 0 ? -value.abs().roundToDouble() : value.roundToDouble();

  static int _decimalPlaces(double value) {
    final s = value.toString();
    final i = s.indexOf('.');
    if (i < 0) return 0;
    return s.length - i - 1;
  }
}
