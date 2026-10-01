import 'dart:ui';

import '../gfl_strings.dart';
import '../model/force_notation.dart';
import '../model/force_solver.dart';
import '../model/gravity_force_constants.dart';
import '../model/gravity_force_lab_model.dart';
import '../transform/math_coordinate_transform.dart';
import 'gfl_render_data.dart';

/// Builds [GflRenderData] from Full model + MVT (no painter-side physics).
class GflRenderBuilder {
  const GflRenderBuilder();

  static const int pullerFrameCount = 31;

  GflRenderData build(
    GravityForceLabModel model, {
    MathCoordinateTransform? transform,
    Size? layoutSize,
  }) {
    final layout = layoutSize ??
        const Size(
          GravityForceConstants.layoutWidth,
          GravityForceConstants.layoutHeight,
        );
    final t = transform ??
        MathCoordinateTransform.forLayout(
          width: layout.width,
          height: layout.height,
        );

    final f = model.forceMagnitude;
    final forceMin = model.minForceMagnitude;
    final forceMax = model.maxForce;
    final mapped = ForceSolver.arrowMappedWidth(
      f,
      forceMin: forceMin,
      forceMax: forceMax,
    );
    final tipLen = ForceSolver.arrowTipLength(mapped);
    final pullerFrame = pullerFrameIndex(f, forceMin: forceMin, forceMax: forceMax);

    final mY = GravityForceConstants.massNodeY;
    final c1 = Offset(t.modelToViewX(model.mass1.positionX), mY);
    final c2 = Offset(t.modelToViewX(model.mass2.positionX), mY);

    final label1 = ForceNotationFormatter.formatForceLabel(
      forceAbs: f,
      display: model.forceValuesDisplay,
      thisObject: GflStrings.mass1Label,
      otherObject: GflStrings.mass2Label,
    );
    final label2 = ForceNotationFormatter.formatForceLabel(
      forceAbs: f,
      display: model.forceValuesDisplay,
      thisObject: GflStrings.mass2Label,
      otherObject: GflStrings.mass1Label,
    );

    final rulerCenter = t.modelToView(
      Offset(model.ruler.positionX, model.ruler.positionY),
    );

    return GflRenderData(
      layoutSize: layout,
      mass1Center: c1,
      mass2Center: c2,
      mass1RadiusView: t.modelToViewDeltaX(model.mass1.radius).abs(),
      mass2RadiusView: t.modelToViewDeltaX(model.mass2.radius).abs(),
      mass1Color: model.mass1.displayColor,
      mass2Color: model.mass2.displayColor,
      constantRadius: model.constantRadius,
      force: f,
      forceLabel1: label1,
      forceLabel2: label2,
      forceValuesDisplay: model.forceValuesDisplay,
      showForceValues: model.showForceValues,
      arrow1TipDx: model.forceOnMass1Sign * tipLen,
      arrow2TipDx: model.forceOnMass2Sign * tipLen,
      arrow1Y: mY - GravityForceConstants.forceArrowHeight1,
      arrow2Y: mY - GravityForceConstants.forceArrowHeight2,
      puller1Frame: pullerFrame,
      puller2Frame: pullerFrame,
      mass1Label: GflStrings.mass1Label,
      mass2Label: GflStrings.mass2Label,
      rulerCenterView: rulerCenter,
      rulerWidthView: GravityForceConstants.rulerWidthView,
      rulerHeightView: GravityForceConstants.rulerHeightView,
      majorTickSpacingView: GravityForceConstants.mvtScale, // 50 px = 1 m
    );
  }

  /// ISLCPullerNode `LinearFunction(forceMin, forceMax, 0, n-1)` +
  /// `Utils.roundSymmetric` — gravity uses pull images only
  /// (`attractNegative: false` → no pushers / zero-force insert).
  static int pullerFrameIndex(
    double forceAbs, {
    required double forceMin,
    required double forceMax,
    int frameCount = pullerFrameCount,
  }) {
    if ((forceMax - forceMin).abs() < 1e-30) return 0;
    final t = (forceAbs - forceMin) / (forceMax - forceMin);
    final clamped = t.clamp(0.0, 1.0);
    // PhET Utils.roundSymmetric for non-negative ≡ Dart round.
    final index = (clamped * (frameCount - 1)).round();
    return index.clamp(0, frameCount - 1);
  }

  /// Asset figure index 1..31 (for tests / ASSET_MAP).
  static int pullerFigureNumber(int frameIndex) =>
      (frameIndex + 1).clamp(1, pullerFrameCount);
}
