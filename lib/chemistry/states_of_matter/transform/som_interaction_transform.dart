import 'dart:ui' show Offset;

/// PhET `AtomicInteractionsScreenView` model-view transform.
///
/// ```
/// ModelViewTransform2.createSinglePointScaleMapping(
///   (0,0) → (145, 360), scale 0.25
/// )
/// ```
///
/// Model units: picometers. View: ScreenView layoutBounds (834×504).
/// Y is **not** inverted (same direction as Flutter).
class SomInteractionTransform {
  const SomInteractionTransform();

  static const double originX = 145;
  static const double originY = 360;
  static const double scale = 0.25;

  double modelToViewX(double modelX) => originX + modelX * scale;

  double modelToViewY(double modelY) => originY + modelY * scale;

  double modelToViewScale(double modelLength) => modelLength * scale;

  double viewToModelX(double viewX) => (viewX - originX) / scale;

  Offset modelToView(double modelX, double modelY) =>
      Offset(modelToViewX(modelX), modelToViewY(modelY));
}
