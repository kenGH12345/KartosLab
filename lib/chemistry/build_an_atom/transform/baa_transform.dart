/// Model ↔ view transform — PhET ModelViewTransform2 inverted-Y for BAA.
library;

import 'dart:ui';

import '../constants/baa_constants.dart';

class BaaTransform {
  const BaaTransform({
    this.scale = BAAConstants.mvtScale,
    required this.viewOriginX,
    required this.viewOriginY,
  });

  factory BaaTransform.atomScreen() {
    return BaaTransform(
      scale: BAAConstants.mvtScale,
      viewOriginX: BAAConstants.mvtViewX,
      viewOriginY: BAAConstants.mvtViewY,
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
