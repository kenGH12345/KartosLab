import 'dart:ui';

import '../../domain/detector_screen_scale.dart';
import 'qwi_layout.dart';

/// Unified coordinate mapping for Experiment detector / graph / ruler.
///
/// ```text
/// Physical y (m)  →  normalized [-1,1] on full detector
///                 →  visible window (zoom)
///                 →  design px in front-facing detector
///                 →  screen px via FittedBox scale
/// ```
class QwiCoordinateTransform {
  const QwiCoordinateTransform({
    required this.detectorRect,
    required this.scaleIndex,
    this.fullHalfWidthM = 0.02,
  });

  /// Front-facing detector rectangle in design coordinates.
  final Rect detectorRect;

  /// [DetectorScreenScale] zoom index.
  final int scaleIndex;

  /// Full detector half-width in meters (always ±20 mm for Experiment).
  final double fullHalfWidthM;

  double get visibleHalfWidthM => DetectorScreenScale.visibleHalfWidthMeters(scaleIndex);

  /// Normalized full-detector coordinate ∈ [-1,1] → physical meters.
  double normalizedToPhysicalM(double normalizedY) => normalizedY * fullHalfWidthM;

  /// Physical meters → normalized full-detector ∈ [-1,1].
  double physicalToNormalized(double physicalM) => physicalM / fullHalfWidthM;

  /// Normalized full-detector y → design Y in [detectorRect] (top = -visible, bottom = +visible).
  ///
  /// Matches PhET canvas mapping: left of front-facing screen is −visibleHalfWidth.
  /// For the horizontal detector band, model x maps left→right; model y maps top→bottom.
  double normalizedXToDesignX(double normalizedX) {
    final visibleHalf = visibleHalfWidthM;
    final physical = normalizedX * fullHalfWidthM;
    final t = ((physical / visibleHalf) + 1) / 2; // 0 at left of visible window
    return detectorRect.left + t.clamp(0.0, 1.0) * detectorRect.width;
  }

  /// Model hit y ∈ [-1,1] → design Y (top of detector = -1 side of vertical extent).
  double normalizedYToDesignY(double normalizedY) {
    final t = (normalizedY + 1) / 2; // -1 → 0 (top), +1 → 1 (bottom)
    return detectorRect.top + t.clamp(0.0, 1.0) * detectorRect.height;
  }

  /// Design X → normalized full-detector x (inverse of [normalizedXToDesignX]).
  double designXToNormalizedX(double designX) {
    final t = ((designX - detectorRect.left) / detectorRect.width).clamp(0.0, 1.0);
    final physical = (t * 2 - 1) * visibleHalfWidthM;
    return physical / fullHalfWidthM;
  }

  double designYToNormalizedY(double designY) {
    final t = ((designY - detectorRect.top) / detectorRect.height).clamp(0.0, 1.0);
    return t * 2 - 1;
  }

  /// Whether a full-detector normalized x is inside the visible zoom window.
  bool isNormalizedXVisible(double normalizedX) {
    final physical = normalizedX * fullHalfWidthM;
    return physical.abs() <= visibleHalfWidthM + 1e-15;
  }

  static QwiCoordinateTransform experimentDefault({int scaleIndex = 0}) {
    return QwiCoordinateTransform(
      detectorRect: QwiLayout.frontFacingDetectorRect,
      scaleIndex: scaleIndex,
      fullHalfWidthM: DetectorScreenScale.fullDetectorScreenHalfWidthM,
    );
  }
}
