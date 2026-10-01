/// PhET original assets for Vector Addition Flutter port.
///
/// Source chain:
///   scenery-phet/images/eraser.svg  (EraserButton)
///     → assets/phet/vector_addition/scenery_phet/eraser.svg
///
/// Icons that PhET draws with ArrowNode / ResetShape / FontAwesome Path
/// are **not** image files — see ASSET_INVENTORY.md.
class VaAssets {
  VaAssets._();

  static const String _base = 'assets/phet/vector_addition';

  /// scenery-phet `images/eraser.svg` — used by `EraserButton` →
  /// `VectorAdditionEraserButton`. Display width PhET default `iconWidth: 20`.
  static const String eraserSvg = '$_base/scenery_phet/eraser.svg';

  /// PhET EraserButton scales SVG to this content width.
  static const double eraserIconWidth = 20;
}
