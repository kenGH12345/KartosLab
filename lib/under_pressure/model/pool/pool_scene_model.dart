/// Shared contract for Under Pressure scenes.
///
/// Source scenes: Square / Trapezoid / Chamber / Mystery.
abstract class PoolSceneModel {
  /// Scene fluid volume proxy (source volumeProperty).
  double get volume;

  /// Advance scene dynamics by [dt] seconds.
  void step(double dt);

  void reset();

  /// Height of fluid column above model point (x, y), meters.
  double getWaterHeightAboveY(double x, double y);

  /// Whether (x, y) is inside the pool geometry.
  bool isPointInsidePool(double x, double y);
}
