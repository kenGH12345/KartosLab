/// PhET Joist `ScreenView.DEFAULT_LAYOUT_BOUNDS` + WOAS view geometry.
///
/// WOASScreenView does not override layoutBounds — uses Joist default 1024×618.
library;

import '../woas_constants.dart';

/// Joist `ScreenView.DEFAULT_LAYOUT_BOUNDS` width.
const double woasLayoutWidth = 1024;

/// Joist `ScreenView.DEFAULT_LAYOUT_BOUNDS` height.
const double woasLayoutHeight = 618;

/// Background `#FFFFB7` (`WOASColors.backgroundColorProperty`).
const int woasBackgroundArgb = 0xFFFFFFB7;

/// Center/equilibrium dashed line (`#6c4a1d`, dash [8,5], lw 2).
const int woasCenterLineArgb = 0xFF6C4A1D;

/// String path `#F00`.
const int woasStringArgb = 0xFFFF0000;

/// Regular bead fill `red`.
const int woasRegularBeadArgb = 0xFFFF0000;

/// Reference bead fill `rgb(128,243,255)`.
const int woasReferenceBeadArgb = 0xFF80F3FF;

/// Reference line stroke `#F00`, dash [10,6].
const int woasReferenceLineArgb = 0xFFFF0000;

/// View X of bead [i] under source MVT.
double beadViewX(int i) =>
    viewOriginX + scaleFromOriginal * (i * modelUnitsPerGap);

/// View Y from model Y under source MVT (`createSinglePointScaleMapping`).
double modelToViewY(double modelY) => viewOriginY + scaleFromOriginal * modelY;

/// Inverse of [modelToViewY].
double viewToModelY(double viewY) => (viewY - viewOriginY) / scaleFromOriginal;

/// Bead radius in view pixels: `modelToViewDeltaX(GAP/2)`.
double get beadViewRadius => scaleFromOriginal * (modelUnitsPerGap / 2);

/// `VIEW_END_X` — right apparatus X.
double get viewEndX =>
    viewOriginX + scaleFromOriginal * ((numberOfBeads - 1) * modelUnitsPerGap);

/// Asset paths (original PhET PNGs).
abstract final class WoasAssets {
  static const String wrench = 'assets/simulations/wave_on_a_string/wrench.png';
  static const String clamp = 'assets/simulations/wave_on_a_string/clamp.png';
  static const String ringBack = 'assets/simulations/wave_on_a_string/ringBack.png';
  static const String ringFront = 'assets/simulations/wave_on_a_string/ringFront.png';
  static const String windowBack = 'assets/simulations/wave_on_a_string/windowBack.png';
  static const String windowFront = 'assets/simulations/wave_on_a_string/windowFront.png';
}
