import '../constants/qwi_units.dart';

/// Port of `experiment/model/DetectorScreenScale.ts`.
///
/// Zoom changes the *visible* region only. Underlying detector data always uses
/// [fullDetectorScreenHalfWidthM] (±20 mm).
class DetectorScreenScale {
  DetectorScreenScale._();

  /// Ordered zoom levels: index 0 = widest (±20 mm).
  static const List<({double minMM, double maxMM})> options = [
    (minMM: -20, maxMM: 20),
    (minMM: -15, maxMM: 15),
    (minMM: -10, maxMM: 10),
    (minMM: -5, maxMM: 5),
  ];

  static const int defaultScaleIndex = 0;

  static double halfWidthMetersForScaleIndex(int scaleIndex) {
    final i = scaleIndex.clamp(0, options.length - 1);
    final opt = options[i];
    return (opt.maxMM - opt.minMM) * 0.5 * QwiUnits.metersPerMillimeter;
  }

  /// Physical half-width of the **full** detector face (meters). Zoom does not change this.
  static double get fullDetectorScreenHalfWidthM => halfWidthMetersForScaleIndex(defaultScaleIndex);

  /// Visible half-width for the current zoom index (meters).
  static double visibleHalfWidthMeters(int scaleIndex) => halfWidthMetersForScaleIndex(scaleIndex);

  /// Visible full width in millimeters for ruler labeling.
  static double visibleFullWidthMm(int scaleIndex) {
    final i = scaleIndex.clamp(0, options.length - 1);
    return options[i].maxMM - options[i].minMM;
  }
}
