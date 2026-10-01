import 'package:flutter/material.dart';

import '../plinko_constants.dart';
import '../transform/plinko_mvt.dart';

/// View-space histogram chrome — `HistogramNode.js` layout constants.
///
/// HISTOGRAM_BOUNDS include the banner strip; Bin/Count labels sit **outside**.
class HistogramLayout {
  HistogramLayout(this.mvt);

  final PlinkoMvt mvt;

  /// Banner height in ScreenView / layout px (`BANNER_HEIGHT = 20`).
  static const bannerHeightLayout = 20.0;

  /// Gap between banner bottom and bar top (`maxBarHeight … - 3`).
  static const barTopGapLayout = 3.0;

  /// Tick label top offset below histogram bottom (`axisBottom + 5`).
  static const tickTopGapLayout = 5.0;

  /// Gap between tick bottoms and "Bin" label (`+ 5`).
  static const binLabelGapLayout = 5.0;

  /// Y-label left offset (`axisLeft - 30`).
  static const yLabelLeftGapLayout = 30.0;

  static const triangleWidthLayout = 20.0;
  static const triangleHeightLayout = 20.0;

  Rect get area {
    final topLeft = mvt.modelToView(
      const Offset(PlinkoConstants.histogramMinX, PlinkoConstants.histogramMaxY),
    );
    final bottomRight = mvt.modelToView(
      const Offset(PlinkoConstants.histogramMaxX, PlinkoConstants.histogramMinY),
    );
    return Rect.fromPoints(topLeft, bottomRight);
  }

  double get bannerH => mvt.layoutToViewDelta(bannerHeightLayout);

  Rect get banner {
    final a = area;
    return Rect.fromLTWH(a.left, a.top, a.width, bannerH);
  }

  /// Plot region for bars (below banner + gap).
  Rect get plot {
    final a = area;
    final top = a.top + bannerH + mvt.layoutToViewDelta(barTopGapLayout);
    return Rect.fromLTRB(a.left, top, a.right, a.bottom);
  }

  double get maxBarHeight => plot.height;

  double binLeft(int binIndex, int nBins) {
    final a = area;
    return a.left + (binIndex / nBins) * a.width;
  }

  double binCenterX(int binIndex, int nBins) {
    final a = area;
    return a.left + ((binIndex + 0.5) / nBins) * a.width;
  }

  double binWidthFor(int nBins) => area.width / nBins;

  double get tickLabelTop =>
      area.bottom + mvt.layoutToViewDelta(tickTopGapLayout);

  double get yLabelLeft =>
      area.left - mvt.layoutToViewDelta(yLabelLeftGapLayout);

  double get histogramCenterY {
    const cy =
        (PlinkoConstants.histogramMinY + PlinkoConstants.histogramMaxY) / 2;
    return mvt.modelToView(const Offset(0, cy)).dy;
  }

  double get triangleW => mvt.layoutToViewDelta(triangleWidthLayout);
  double get triangleH => mvt.layoutToViewDelta(triangleHeightLayout);
}
