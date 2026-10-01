import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/baa_constants.dart';

/// Fits PhET 768×464 ScreenView into the available cell.
///
/// Uses the full cell at the largest contain-scale; letterbox is white so side
/// bars do not read as a gray frame around the sim.
class BaaPageShell extends StatelessWidget {
  const BaaPageShell({super.key, required this.child});

  final Widget child;

  static const _letterbox = Colors.white;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) {
          return const ColoredBox(color: _letterbox);
        }
        final scale = math.min(
          w / BAAConstants.designWidth,
          h / BAAConstants.designHeight,
        );
        final drawnW = BAAConstants.designWidth * scale;
        final drawnH = BAAConstants.designHeight * scale;
        return ColoredBox(
          color: _letterbox,
          child: SizedBox(
            width: w,
            height: h,
            child: Center(
              child: SizedBox(
                width: drawnW,
                height: drawnH,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: SizedBox(
                    width: BAAConstants.designWidth,
                    height: BAAConstants.designHeight,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
