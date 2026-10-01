/// Global design canvas for Quantum Measurement — from PhET joist ScreenView + QM constants.
/// Spec only: no Widget, no Model business logic.
library;

import 'dart:ui';

/// Joist ScreenView.DEFAULT_LAYOUT_BOUNDS — evidence: joist ScreenView.ts
const qmDesignWidth = 1024.0;
const qmDesignHeight = 618.0;

/// QuantumMeasurementConstants.SCREEN_VIEW_X_MARGIN / Y_MARGIN
const qmScreenViewXMargin = 10.0;
const qmScreenViewYMargin = 10.0;

/// ExperimentDividingLine DIVIDER_HEIGHT
const qmDividerHeight = 525.0;

/// Uniform scale + letterbox/pillarbox via ScreenView.getLayoutScale / getLayoutMatrix.
enum QmScaleMode {
  /// min(viewW/designW, viewH/designH), center remaining axis (default ScreenView).
  uniformCenter,
}

class QmGlobalLayoutSpec {
  const QmGlobalLayoutSpec();

  double get designWidth => qmDesignWidth;
  double get designHeight => qmDesignHeight;

  /// Content inset rectangle inside layoutBounds.
  ({double left, double top, double right, double bottom}) get contentInsets => (
        left: qmScreenViewXMargin,
        top: qmScreenViewYMargin,
        right: qmScreenViewXMargin,
        bottom: qmScreenViewYMargin,
      );

  QmScaleMode get scaleMode => QmScaleMode.uniformCenter;

  /// Same formula as ScreenView.getLayoutScale.
  double layoutScale(double viewWidth, double viewHeight) {
    final sx = viewWidth / designWidth;
    final sy = viewHeight / designHeight;
    return sx < sy ? sx : sy;
  }

  /// Reset All button anchors (QuantumMeasurementScreenView).
  ({double right, double bottom}) resetAllAnchor(double layoutMaxX, double layoutMaxY) => (
        right: layoutMaxX - qmScreenViewXMargin,
        bottom: layoutMaxY - qmScreenViewYMargin,
      );

  /// Shared ScreenView transform for all four screens.
  QmDesignFrame designFrame(Size viewport) {
    final scale = layoutScale(viewport.width, viewport.height);
    return QmDesignFrame(
      scale: scale,
      origin: Offset(
        (viewport.width - designWidth * scale) / 2,
        (viewport.height - designHeight * scale) / 2,
      ),
    );
  }
}

/// Uniform-center design canvas placement in a viewport.
class QmDesignFrame {
  const QmDesignFrame({required this.scale, required this.origin});

  final double scale;
  final Offset origin;

  Size get designSize => const Size(qmDesignWidth, qmDesignHeight);

  Rect get contentBounds => Rect.fromLTWH(
        origin.dx,
        origin.dy,
        qmDesignWidth * scale,
        qmDesignHeight * scale,
      );
}
