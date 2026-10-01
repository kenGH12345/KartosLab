import 'dart:math' as math;
import 'dart:ui' show Size;

import 'package:flutter/painting.dart' show Alignment;
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';

/// PhET EFAC `ScreenView.layout()` viewport → design mapping.
///
/// Source: `EFACIntroScreenView.layout` / `SystemsScreenView.layout`
/// (`getLayoutScale` = min(viewW/designW, viewH/designH), then):
/// - width-limited (`scale == viewW/designW`): bottom-align → `offsetY > 0`
/// - height-limited (`scale == viewH/designH`): horizontal center → `dx`
/// - equal scales: first branch → `offsetY == 0`, `dx == 0`
class EfacViewportLayout {
  const EfacViewportLayout({
    required this.viewport,
    required this.design,
    required this.scale,
    required this.widthLimited,
    required this.dx,
    required this.offsetYDesign,
  });

  final Size viewport;
  final Size design;

  /// Uniform scale = min(scaleX, scaleY).
  final double scale;

  /// True when width is the limiting dimension (incl. exact aspect match).
  final bool widthLimited;

  /// PhET `dx` in design coordinates.
  final double dx;

  /// PhET `offsetY` in design coordinates.
  final double offsetYDesign;

  double get scaleX => viewport.width / design.width;
  double get scaleY => viewport.height / design.height;

  /// Screen-space origin of the design rect (top-left of scaled scene).
  double get offsetX => dx * scale;
  double get offsetY => offsetYDesign * scale;

  double get sceneWidth => design.width * scale;
  double get sceneHeight => design.height * scale;

  /// FittedBox alignment matching PhET translate semantics.
  Alignment get fittedAlignment =>
      widthLimited ? Alignment.bottomCenter : Alignment.topCenter;

  static EfacViewportLayout compute(
    Size viewport, {
    Size design = const Size(
      EfacConstants.layoutWidth,
      EfacConstants.layoutHeight,
    ),
  }) {
    final scaleX = viewport.width / design.width;
    final scaleY = viewport.height / design.height;
    final scale = math.min(scaleX, scaleY);
    // Match PhET `scale === width/layoutBounds.width` first branch on ties.
    final widthLimited = scaleX <= scaleY;

    var dx = 0.0;
    var offsetYDesign = 0.0;
    if (widthLimited) {
      offsetYDesign = viewport.height / scale - design.height;
    } else {
      dx = (viewport.width - design.width * scale) / (2 * scale);
    }

    return EfacViewportLayout(
      viewport: viewport,
      design: design,
      scale: scale,
      widthLimited: widthLimited,
      dx: dx,
      offsetYDesign: offsetYDesign,
    );
  }
}
