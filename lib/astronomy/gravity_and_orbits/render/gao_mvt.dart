/// Model↔view transform — rectangle inverted-Y mapping from `GravityAndOrbitsScene.createTransform`.
library;

import 'dart:ui';

import '../gao_constants.dart';
import '../model/gao_vec.dart';

class GaoMvt {
  GaoMvt({
    required this.modelBounds,
    required this.viewBounds,
  });

  final Rect modelBounds;
  final Rect viewBounds;

  factory GaoMvt.fromZoom({
    required double defaultZoomScale,
    required double zoomLevel,
    required GaoVec gridCenter,
    Size? stageSize,
  }) {
    final stageW = stageSize?.width ?? GaoConstants.stageWidth;
    final stageH = stageSize?.height ?? GaoConstants.stageHeight;

    final targetScale = defaultZoomScale * zoomLevel;
    final z = targetScale * GaoConstants.mvtScaleFactor;
    final modelWidth = stageW / z;
    final modelHeight = stageH / z;
    final modelBounds = Rect.fromLTWH(
      -modelWidth / 2 + gridCenter.x,
      -modelHeight / 2 + gridCenter.y,
      modelWidth,
      modelHeight,
    );

    final playAreaHeight = stageH - 50;
    final scale = playAreaHeight / stageH;
    final viewBounds = Rect.fromLTWH(30, 0, stageW * scale, stageH * scale);

    return GaoMvt(modelBounds: modelBounds, viewBounds: viewBounds);
  }

  Offset modelToView(GaoVec p) {
    final nx = (p.x - modelBounds.left) / modelBounds.width;
    final ny = (p.y - modelBounds.top) / modelBounds.height;
    // Inverted Y
    return Offset(
      viewBounds.left + nx * viewBounds.width,
      viewBounds.top + (1 - ny) * viewBounds.height,
    );
  }

  GaoVec viewToModel(Offset p) {
    final nx = (p.dx - viewBounds.left) / viewBounds.width;
    final ny = 1 - (p.dy - viewBounds.top) / viewBounds.height;
    return GaoVec(
      modelBounds.left + nx * modelBounds.width,
      modelBounds.top + ny * modelBounds.height,
    );
  }

  double modelDeltaToViewDelta(double modelDelta) {
    return modelDelta / modelBounds.width * viewBounds.width;
  }
}
