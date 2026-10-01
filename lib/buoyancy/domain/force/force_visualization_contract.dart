/// Force visualization contract — Model → View data only.
///
/// Source: `ForceDiagramNode.ts`
/// `arrowNode.setTip(0, -y * vectorZoom * 20)` with default zoom level 4 → scale 1/16.
///
/// PHASE 1A does not implement View. Painters must not recompute F_b / F_g.
class ForceVisualizationContract {
  ForceVisualizationContract._();

  /// Default pixels-per-Newton multiplier before vectorZoom (`ForceDiagramNode`).
  static const double pixelsPerNewtonBase = 20;

  /// `DisplayProperties` ZOOM_SCALES: powers of 0.5 from 2^-8 .. 2^-1.
  /// Default vectorZoomLevel = 4 → ZOOM_SCALES[4] = 2^-4 = 1/16.
  static const List<double> zoomScales = [
    1 / 256,
    1 / 128,
    1 / 64,
    1 / 32,
    1 / 16,
    1 / 8,
    1 / 4,
    1 / 2,
  ];

  static double zoomScaleForLevel(int level) {
    final i = level.clamp(0, zoomScales.length - 1);
    return zoomScales[i];
  }

  /// View tip offset in local arrow space (y component of force in Newtons).
  /// Model +y up; scenery arrow grows with -y so gravity points down on screen.
  static double arrowTipY(double forceYNewtons, int zoomLevel) =>
      -forceYNewtons * zoomScaleForLevel(zoomLevel) * pixelsPerNewtonBase;
}

/// Snapshot of forces a view may bind to.
class ForceViewData {
  const ForceViewData({
    required this.gravityY,
    required this.buoyancyY,
    required this.contactY,
    required this.showGravity,
    required this.showBuoyancy,
    required this.showContact,
    required this.showValues,
    required this.zoomLevel,
  });

  final double gravityY;
  final double buoyancyY;
  final double contactY;
  final bool showGravity;
  final bool showBuoyancy;
  final bool showContact;
  final bool showValues;
  final int zoomLevel;
}
