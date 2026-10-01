import 'package:flutter/material.dart';

import '../collision_lab_colors.dart';
import '../collision_lab_constants.dart';

/// Page metrics for Collision Lab (not Normal Modes spectrum layout).
class ClPageMetrics {
  const ClPageMetrics({
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

  static const double rightReserveLogical = 250;
  static const double bottomReserveLogical = 200;

  static ClPageMetrics compute(BoxConstraints constraints) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    final right = (w * 0.28).clamp(220.0, 280.0);
    final bottom = (h * 0.32).clamp(140.0, 220.0);
    return ClPageMetrics(
      availableWidth: w,
      availableHeight: h,
      rightPanelWidth: right,
      bottomPanelHeight: bottom,
      simViewportWidth: (w - right).clamp(0.0, w),
      simViewportHeight: (h - bottom).clamp(0.0, h),
    );
  }
}

/// Fits PhET logical play canvas into the simulation region.
class SimulationViewport extends StatelessWidget {
  const SimulationViewport({
    super.key,
    required this.logicalWidth,
    required this.logicalHeight,
    required this.child,
  });

  final double logicalWidth;
  final double logicalHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CollisionLabColors.screenBackground,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox(
          width: logicalWidth,
          height: logicalHeight,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: CollisionLabConstants.layoutWidth,
              maxWidth: CollisionLabConstants.layoutWidth,
              minHeight: CollisionLabConstants.layoutHeight,
              maxHeight: CollisionLabConstants.layoutHeight,
              child: SizedBox(
                width: CollisionLabConstants.layoutWidth,
                height: CollisionLabConstants.layoutHeight,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

class BottomPanel extends StatelessWidget {
  const BottomPanel({
    super.key,
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: child,
      ),
    );
  }
}
