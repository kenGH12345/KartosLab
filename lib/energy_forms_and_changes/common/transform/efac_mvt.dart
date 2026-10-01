import 'dart:ui';

import 'package:kratos/energy_forms_and_changes/efac_constants.dart';

/// Model-view transform: single-point scale + inverted Y (PhET MVT pattern).
class EfacMvt {
  EfacMvt({
    required this.originView,
    required this.scale,
  });

  /// Intro: origin at (layoutW*0.5, layoutH*0.85), scale 1700.
  factory EfacMvt.intro({
    double layoutWidth = EfacConstants.layoutWidth,
    double layoutHeight = EfacConstants.layoutHeight,
  }) {
    return EfacMvt(
      originView: Offset(layoutWidth * 0.5, layoutHeight * 0.85),
      scale: EfacConstants.introMvtScaleFactor,
    );
  }

  /// Systems: origin at (layoutW*0.5, layoutH*0.475), scale 2200.
  factory EfacMvt.systems({
    double layoutWidth = EfacConstants.layoutWidth,
    double layoutHeight = EfacConstants.layoutHeight,
  }) {
    return EfacMvt(
      originView: Offset(layoutWidth * 0.5, layoutHeight * 0.475),
      scale: EfacConstants.systemsMvtScaleFactor,
    );
  }

  final Offset originView;
  final double scale;

  Offset modelToView(Offset model) {
    return Offset(
      originView.dx + model.dx * scale,
      originView.dy - model.dy * scale,
    );
  }

  Offset viewToModel(Offset view) {
    return Offset(
      (view.dx - originView.dx) / scale,
      (originView.dy - view.dy) / scale,
    );
  }

  double modelToViewDelta(double modelDelta) => modelDelta * scale;

  /// View Δy → model Δy (Y inverted).
  double viewToModelDeltaY(double viewDy) => -viewDy / scale;

  /// View Δ → model Δ (Y inverted). Used by thermometer extraction jump (5,5).
  Offset viewToModelDelta(Offset viewDelta) => Offset(
        viewDelta.dx / scale,
        -viewDelta.dy / scale,
      );
}
