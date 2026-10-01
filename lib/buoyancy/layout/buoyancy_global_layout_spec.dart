/// Global Buoyancy layout constants — PHASE 2A archaeology only.
///
/// Source snapshot: LOCAL density-buoyancy-common HEAD `0c835c64`.
/// No Widget / Composer / UI painting.
library;

import 'dart:ui';

/// Joist `ScreenView.DEFAULT_LAYOUT_BOUNDS` = Bounds2(0,0,1024,618).
///
/// Evidence: `BuoyancyCompareScreenView.ts` passes
/// `layoutBounds: ScreenView.DEFAULT_LAYOUT_BOUNDS`. Other Buoyancy screens
/// do not override → same default via MobiusScreenView → ScreenView.
const double buoyancyDesignWidth = 1024;
const double buoyancyDesignHeight = 618;

/// `DensityBuoyancyCommonConstants.MARGIN` / `MARGIN_SMALL`
const double buoyancyMargin = 10;
const double buoyancyMarginSmall = 5;

/// `DensityBuoyancyCommonConstants.SPACING` / `SPACING_SMALL`
const double buoyancySpacing = 10;
const double buoyancySpacingSmall = 5;

/// `DensityBuoyancyCommonConstants.CORNER_RADIUS`
const double buoyancyPanelCornerRadius = 5;

/// Camera scaleIncrease in DensityBuoyancyScreenView constructor.
const double buoyancyCameraScaleIncrease = 3.5;

/// Default cameraZoom = 1.75 * scaleIncrease
const double buoyancyDefaultCameraZoom = 1.75 * buoyancyCameraScaleIncrease;

/// Camera position before lookAt: (0, 0.2, 2) * scaleIncrease
const Offset3 buoyancyDefaultCameraPosition =
    Offset3(0, 0.2 * buoyancyCameraScaleIncrease, 2 * buoyancyCameraScaleIncrease);

/// BuoyancyScreenView default lookAt (most screens).
const Offset3 buoyancyCameraLookAt = Offset3(0, -0.18, 0);

/// Compare / Buoyancy Basics lookAt override.
const Offset3 buoyancyBasicsCameraLookAt = Offset3(0, -0.1, 0);

/// Compare viewOffset (BUOYANCY_BASICS_VIEW_OFFSET).
const Offset buoyancyBasicsViewOffset = Offset(-25, 0);

/// DebugView 2D MVT scale (NOT production THREE MVT).
/// `ModelViewTransform2.createSinglePointScaleInvertedYMapping(ZERO, center, 600)`
const double buoyancyDebugMvtScale = 600;

/// Force arrow: tipY = -Fy * vectorZoom * 20 (ForceDiagramNode).
const double buoyancyForceArrowUnitsPerNewton = 20;

enum BuoyancyScaleMode {
  /// Joist ScreenView.getLayoutScale = min(w/designW, h/designH), centered.
  uniformCenter,
}

/// Trivial 3D offset (model meters).
class Offset3 {
  const Offset3(this.x, this.y, this.z);
  final double x;
  final double y;
  final double z;
}

class BuoyancyGlobalLayoutSpec {
  const BuoyancyGlobalLayoutSpec();

  double get designWidth => buoyancyDesignWidth;
  double get designHeight => buoyancyDesignHeight;

  Size get designSize =>
      const Size(buoyancyDesignWidth, buoyancyDesignHeight);

  ({double left, double top, double right, double bottom}) get contentInsets =>
      (
        left: buoyancyMarginSmall,
        top: buoyancyMarginSmall,
        right: buoyancyMarginSmall,
        bottom: buoyancyMarginSmall,
      );

  BuoyancyScaleMode get scaleMode => BuoyancyScaleMode.uniformCenter;

  /// Same formula as Joist `ScreenView.getLayoutScale`.
  double layoutScale(double viewWidth, double viewHeight) {
    final sx = viewWidth / designWidth;
    final sy = viewHeight / designHeight;
    return sx < sy ? sx : sy;
  }

  BuoyancyDesignFrame designFrame(Size viewport) {
    final scale = layoutScale(viewport.width, viewport.height);
    return BuoyancyDesignFrame(
      scale: scale,
      origin: Offset(
        (viewport.width - designWidth * scale) / 2,
        (viewport.height - designHeight * scale) / 2,
      ),
    );
  }

  /// ResetAll AlignBox: right/bottom of visibleBounds with MARGIN_SMALL.
  ({double right, double bottom}) resetAllAnchorInVisibleBounds(
    Rect visibleBounds,
  ) =>
      (
        right: visibleBounds.right - buoyancyMarginSmall,
        bottom: visibleBounds.bottom - buoyancyMarginSmall,
      );
}

class BuoyancyDesignFrame {
  const BuoyancyDesignFrame({required this.scale, required this.origin});

  final double scale;
  final Offset origin;

  Size get designSize =>
      const Size(buoyancyDesignWidth, buoyancyDesignHeight);

  Rect get contentBounds => Rect.fromLTWH(
        origin.dx,
        origin.dy,
        buoyancyDesignWidth * scale,
        buoyancyDesignHeight * scale,
      );

  /// Design (layoutBounds) → viewport pixels.
  Offset designToViewport(Offset designPoint) =>
      Offset(origin.dx + designPoint.dx * scale, origin.dy + designPoint.dy * scale);

  /// Viewport → design.
  Offset viewportToDesign(Offset viewportPoint) => Offset(
        (viewportPoint.dx - origin.dx) / scale,
        (viewportPoint.dy - origin.dy) / scale,
      );
}

/// Coordinate spaces used by Buoyancy (do not conflate).
enum BuoyancyCoordinateSpace {
  /// Model / physics meters, +y up, pool centered near x=0.
  modelMeters,

  /// Joist ScreenView layoutBounds design pixels (1024×618), +y down.
  designPixels,

  /// After ScreenView layout matrix (viewport pixels).
  viewportPixels,

  /// THREE.js world (same as model meters) projected by camera.
  threeWorld,

  /// Scenery overlay after THREEModelViewTransform.modelToViewPoint.
  sceneryOverlay,
}

/// Production MVT is Mobius THREE camera projection — not a 2D scale map.
///
/// Flutter Composer (Phase 3+) must implement camera-equivalent projection or
/// an explicitly labeled orthographic approximation. DebugView's 600-scale
/// inverted-Y map is DEBUG ONLY.
class BuoyancyMvtContract {
  const BuoyancyMvtContract();

  String get productionTransform =>
      'THREEModelViewTransform via MobiusScreenView (camera position/zoom/lookAt)';

  String get debugTransform =>
      'ModelViewTransform2.createSinglePointScaleInvertedYMapping(ZERO, layoutBounds.center, 600)';

  bool get productionIsTwoDimensionalScale => false;

  Offset3 get buoyancyLookAt => buoyancyCameraLookAt;
  Offset3 get compareLookAt => buoyancyBasicsCameraLookAt;
  Offset get compareViewOffset => buoyancyBasicsViewOffset;
  double get defaultCameraZoom => buoyancyDefaultCameraZoom;
}
