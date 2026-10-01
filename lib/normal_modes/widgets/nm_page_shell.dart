import 'package:flutter/material.dart';

import '../normal_modes_constants.dart';

/// Page-level geometry for Normal Modes (not screenshot pixel hacks).
///
/// ```
/// availableWidth / availableHeight  (below App chrome)
///   ├─ SimulationViewport  (left / main)
///   ├─ ControlColumn       (right, exclusive)
///   └─ BottomSpectrum      (1D only)
/// ```
class NmPageMetrics {
  const NmPageMetrics({
    required this.availableWidth,
    required this.availableHeight,
    required this.rightPanelWidth,
    required this.bottomPanelHeight,
    required this.simViewportWidth,
    required this.simViewportHeight,
  });

  final double availableWidth;
  final double availableHeight;
  final double rightPanelWidth;
  final double bottomPanelHeight;
  final double simViewportWidth;
  final double simViewportHeight;

  /// PhET reserves ~420 logical px on the right for 2D panels.
  static const double twoDRightReserveLogical =
      NormalModesConstants.twoDRightReserve;

  /// 1D spring span ends near x=759; keep ~250+ for right column.
  static const double oneDRightReserveLogical = 250;

  /// Spectrum band in PhET sits under the play area.
  static const double oneDBottomReserveLogical = 280;

  static NmPageMetrics oneDimension(BoxConstraints constraints) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    final right = (w * 0.26).clamp(220.0, 280.0);
    final bottom = (h * 0.36).clamp(160.0, 280.0);
    return NmPageMetrics(
      availableWidth: w,
      availableHeight: h,
      rightPanelWidth: right,
      bottomPanelHeight: bottom,
      simViewportWidth: (w - right).clamp(0.0, w),
      simViewportHeight: (h - bottom).clamp(0.0, h),
    );
  }

  static NmPageMetrics twoDimensions(BoxConstraints constraints) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    // Amplitudes grid is 270 + axis radios ≈ 340 content; panel chrome ~360.
    final right = (w * 0.32).clamp(300.0, 380.0);
    return NmPageMetrics(
      availableWidth: w,
      availableHeight: h,
      rightPanelWidth: right,
      bottomPanelHeight: 0,
      simViewportWidth: (w - right).clamp(0.0, w),
      simViewportHeight: h,
    );
  }
}

/// Fits a logical PhET play canvas into [viewport], clipping to the
/// simulation region so right/bottom panel reserves are not shown empty
/// under Flutter panels (panels live in sibling columns).
class SimulationViewport extends StatelessWidget {
  const SimulationViewport({
    super.key,
    required this.logicalWidth,
    required this.logicalHeight,
    required this.child,
  });

  /// Width of the logical play region (may be < full 1024).
  final double logicalWidth;
  final double logicalHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox(
          width: logicalWidth,
          height: logicalHeight,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: NormalModesConstants.layoutWidth,
              maxWidth: NormalModesConstants.layoutWidth,
              minHeight: NormalModesConstants.layoutHeight,
              maxHeight: NormalModesConstants.layoutHeight,
              child: SizedBox(
                width: NormalModesConstants.layoutWidth,
                height: NormalModesConstants.layoutHeight,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Right column: exclusive width, never overlays [SimulationViewport].
/// Scrolls when control + amplitudes exceed available height.
class ControlColumn extends StatelessWidget {
  const ControlColumn({
    super.key,
    required this.width,
    required this.children,
  });

  final double width;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    children[i],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
