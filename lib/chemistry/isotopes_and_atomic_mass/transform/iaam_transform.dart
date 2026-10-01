/// Model ↔ view transform for IAAM (PhET ModelViewTransform2 inverted-Y).
library;

import 'dart:ui';

import '../iaam_constants.dart';

class IaamTransform {
  const IaamTransform({
    this.scale = IaamConstants.mvtScale,
    this.viewOriginX = 0,
    this.viewOriginY = 0,
  });

  factory IaamTransform.makeScreen() {
    return IaamTransform(
      scale: IaamConstants.mvtScale,
      viewOriginX: IaamConstants.mvtViewX,
      viewOriginY: IaamConstants.mvtViewY,
    );
  }

  factory IaamTransform.mixScreen() {
    return IaamTransform(
      scale: IaamConstants.mvtScale,
      viewOriginX: IaamConstants.mixMvtViewX,
      viewOriginY: IaamConstants.mixMvtViewY,
    );
  }

  final double scale;
  final double viewOriginX;
  final double viewOriginY;

  Offset modelToView(double modelX, double modelY) {
    return Offset(
      viewOriginX + scale * modelX,
      viewOriginY - scale * modelY,
    );
  }

  Offset viewToModel(double viewX, double viewY) {
    return Offset(
      (viewX - viewOriginX) / scale,
      (viewOriginY - viewY) / scale,
    );
  }

  double modelToViewDelta(double modelDelta) => modelDelta * scale;
}
