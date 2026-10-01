import 'dart:ui';

import '../gflb_constants.dart';
import '../gflb_strings.dart';
import '../model/gravity_model.dart';
import '../solver/force_solver.dart';
import '../transform/math_coordinate_transform.dart';
import 'gflb_render_data.dart';

/// Builds [GflbRenderData] from model + transform (no painter-side physics).
class GflbRenderBuilder {
  const GflbRenderBuilder();

  GflbRenderData build(
    GravityModel model, {
    MathCoordinateTransform? transform,
    Size? layoutSize,
  }) {
    final layout = layoutSize ??
        const Size(GflbConstants.layoutWidth, GflbConstants.layoutHeight);
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

    final label = f.toStringAsFixed(GflbConstants.forceReadoutDecimalPlaces);
    final distKm = model.separation / 1000;

    // Distance label: JS number→string (trim trailing zeros for whole km).
    final distStr = distKm == distKm.roundToDouble()
        ? distKm.round().toString()
        : distKm.toString();

    final pullerFrame = ForceSolver.pullerFrameIndex(
      f,
      forceMin: forceMin,
      forceMax: forceMax,
    );

    final m1y = GflbConstants.massNodeY;
    final m2y = GflbConstants.massNodeY;
    final c1 = Offset(t.modelToViewX(model.mass1.positionX), m1y);
    final c2 = Offset(t.modelToViewX(model.mass2.positionX), m2y);

    return GflbRenderData(
      layoutSize: layout,
      mass1Center: c1,
      mass2Center: c2,
      mass1RadiusView: t.modelToViewDeltaX(model.mass1.radius).abs(),
      mass2RadiusView: t.modelToViewDeltaX(model.mass2.radius).abs(),
      mass1Color: model.mass1.displayColor,
      mass2Color: model.mass2.displayColor,
      constantSize: model.constantSize,
      force: f,
      forceLabel: GflbStrings.forceNewtons(label),
      showForceValues: model.showForceValues,
      showDistance: model.showDistance,
      distanceKmLabel: GflbStrings.distanceKm(distStr),
      arrow1TipDx: model.forceOnMass1Sign * tipLen,
      arrow2TipDx: model.forceOnMass2Sign * tipLen,
      arrow1Y: m1y - GflbConstants.forceArrowHeight1,
      arrow2Y: m2y - GflbConstants.forceArrowHeight2,
      puller1Frame: pullerFrame,
      puller2Frame: pullerFrame,
      mass1Label: GflbStrings.mass1Label,
      mass2Label: GflbStrings.mass2Label,
    );
  }
}
