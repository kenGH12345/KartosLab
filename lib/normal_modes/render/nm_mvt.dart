import 'package:flutter/material.dart';

import '../model/nm_vec.dart';
import '../normal_modes_constants.dart';

/// ModelViewTransform2.createSinglePointScaleInvertedYMapping
class NmMvt {
  const NmMvt({
    required this.origin,
    required this.scale,
  });

  final Offset origin;
  final double scale;

  Offset modelToView(NmVec p) => Offset(origin.dx + p.x * scale, origin.dy - p.y * scale);

  NmVec viewToModel(Offset p) => NmVec((p.dx - origin.dx) / scale, (origin.dy - p.dy) / scale);

  static NmMvt oneDimension() {
    const origin = Offset(
      NormalModesConstants.viewSpringWidth / 2 +
          NormalModesConstants.screenViewXMargin +
          4,
      (NormalModesConstants.layoutHeight - 300) / 2,
    );
    return const NmMvt(
      origin: origin,
      scale: NormalModesConstants.viewSpringWidth / 2,
    );
  }

  static NmMvt twoDimensions() {
    const origin = Offset(
      (NormalModesConstants.layoutWidth - NormalModesConstants.twoDRightReserve) /
          2,
      NormalModesConstants.layoutHeight / 2,
    );
    const scale =
        (NormalModesConstants.layoutWidth -
            2 * NormalModesConstants.screenViewXMargin -
            NormalModesConstants.twoDRightReserve) /
        2;
    return const NmMvt(origin: origin, scale: scale);
  }
}
