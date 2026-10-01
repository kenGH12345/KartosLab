import 'dart:ui';

import 'ba_shared_constants.dart';
import 'model/ba_vector2.dart';

/// Model↔View transform for Balancing Act screens.
///
/// Intro/Lab: scale 105, origin `(w*0.375, h*0.79)`
/// Game: scale 115, origin `(w*0.45, h*0.86)`
class BaModelViewTransform {
  BaModelViewTransform({
    this.scale = BaSharedConstants.introLabMvtScale,
    Offset? originInView,
  }) : originInView = originInView ??
            Offset(
              BaSharedConstants.layoutWidth *
                  BaSharedConstants.introLabOriginViewXFactor,
              BaSharedConstants.layoutHeight *
                  BaSharedConstants.introLabOriginViewYFactor,
            );

  /// Source: `BalanceGameView.ts` MVT mapping.
  factory BaModelViewTransform.game() => BaModelViewTransform(
        scale: BaSharedConstants.gameMvtScale,
        originInView: Offset(
          BaSharedConstants.layoutWidth *
              BaSharedConstants.gameOriginViewXFactor,
          BaSharedConstants.layoutHeight *
              BaSharedConstants.gameOriginViewYFactor,
        ),
      );

  final double scale;
  final Offset originInView;

  double modelToViewX(double x) => originInView.dx + x * scale;

  double modelToViewY(double y) => originInView.dy - y * scale;

  Offset modelToView(BaVector2 p) =>
      Offset(modelToViewX(p.x), modelToViewY(p.y));

  double viewToModelX(double x) => (x - originInView.dx) / scale;

  double viewToModelY(double y) => (originInView.dy - y) / scale;

  BaVector2 viewToModel(Offset p) =>
      BaVector2(viewToModelX(p.dx), viewToModelY(p.dy));

  double modelToViewDeltaX(double dx) => dx * scale;

  double modelToViewDeltaY(double dy) => -dy * scale;
}
