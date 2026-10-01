import 'dart:ui' show Size;

/// V5 Layout Policy — Gases Intro
///
/// ## Coordinate spaces
///
/// **Logical layoutBounds** (PhET ScreenView): 1008 × 618.
/// All V2 Anchor Map rules are defined in this space (MVT origin 645,475,
/// scale 0.040, margins 20, RIGHT_PANEL_WIDTH 225, …).
///
/// **Physical viewport**: size of the shell after fitting into NineGrid center.
/// `layoutScale = min(availW/1008, availH/618)` (uniform, capped ≤1). Physical =
/// logical × layoutScale.
///
/// This is **not** FittedBox-on-overflow. Anchors are re-evaluated with scaled
/// MVT; relative “who anchors whom” rules from V2 are unchanged.
///
/// ## Categories
///
/// | Kind | Examples | Why fixed / flexible |
/// |---|---|---|
/// | A. Source-derived fixed (logical) | pumpH 230, gauge r 50, margins 20 | GasPropertiesConstants / Node options |
/// | B. Flexible | shell physical size via layoutScale | viewport constraints |
/// | C. Anchored position | gauge ← containerNode; heater ← bottom | IdealGasLawScreenView rules |
/// | D. Viewport-constrained | Stopwatch/CC drag bounds = physical layoutBounds | DragBoundsProperty |
///
/// ## Right panel vs Fine/Coarse
///
/// PhET FineCoarseSpinner maxWidth ≈ 190 inside 225 panel. Flutter Material
/// 40×40 icon buttons need ~200 + padding → panel content width **236**
/// logical ([有意差异] Flutter chrome), not shrinking hit targets.
///
/// ## Forbidden
///
/// ClipRect / OverflowBox / FittedBox / Transform.scale to hide overflow;
/// shrinking Fine/Coarse/Pump/fonts; merging ControlPanel + Accordion.
class GasesIntroLayoutPolicy {
  GasesIntroLayoutPolicy._();

  static const double logicalWidth = 1008;
  static const double logicalHeight = 618;

  /// Flutter chrome compensation for Fine/Coarse row (logical px).
  static const double rightPanelWidthLogical = 236;

  /// Uniform fit into [maxWidth]×[maxHeight]. Floor avoids unreadably tiny UI;
  /// below floor → letterbox ([有意差异] vs forcing illegible scale).
  static double fitScale(double maxWidth, double maxHeight) {
    if (maxWidth <= 0 || maxHeight <= 0) return 1;
    final s = (maxWidth / logicalWidth < maxHeight / logicalHeight)
        ? maxWidth / logicalWidth
        : maxHeight / logicalHeight;
    if (s > 1) return 1;
    if (s < 0.55) return 0.55;
    return s;
  }

  static Size physicalSize(double scale) => Size(
        logicalWidth * scale,
        logicalHeight * scale,
      );
}
