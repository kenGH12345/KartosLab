import '../faradays_law_constants.dart';

/// PhET `BulbNode` brightness mapping from |voltage|.
///
/// Halo scale = `20 * |voltage|`; hidden when scale < 0.1.
class BulbModel {
  BulbModel({required double Function() voltageGetter})
      : _voltageGetter = voltageGetter;

  final double Function() _voltageGetter;

  double get voltage => _voltageGetter();

  /// Source halo scale factor (before transform normalize).
  double get haloScale =>
      FaradaysLawConstants.bulbHaloScaleFactor * voltage.abs();

  bool get haloVisible =>
      haloScale >= FaradaysLawConstants.bulbHaloVisibilityThreshold;

  /// Normalized brightness in [0, 1] for tests / future View.
  ///
  /// Maps |voltage| so that needle max (|π/2|) → 1.0; below visibility
  /// threshold → 0.
  double get brightness {
    if (!haloVisible) return 0;
    final maxScale = FaradaysLawConstants.bulbHaloScaleFactor *
        FaradaysLawConstants.needleMaxAngle;
    return (haloScale / maxScale).clamp(0.0, 1.0);
  }
}
