import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/hookes_law_constants.dart';

/// Uniform contain-scale of the 1024×618 ScreenView, centered.
///
/// Same rule as joist `ScreenView.getLayoutScale` / `getLayoutMatrix`.
/// Axes are not stretched independently.
class HookesLawStage extends StatelessWidget {
  const HookesLawStage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : HookesLawConstants.layoutBoundsWidth;
        final viewH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : HookesLawConstants.layoutBoundsHeight;
        final scale = math.min(
          viewW / HookesLawConstants.layoutBoundsWidth,
          viewH / HookesLawConstants.layoutBoundsHeight,
        );
        return ColoredBox(
          color: const Color(0xFFFFFFFF),
          child: Center(
            child: SizedBox(
              width: HookesLawConstants.layoutBoundsWidth * scale,
              height: HookesLawConstants.layoutBoundsHeight * scale,
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: HookesLawConstants.layoutBoundsWidth,
                  height: HookesLawConstants.layoutBoundsHeight,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
