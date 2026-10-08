import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bending_light_constants.dart';
import '../phet_font.dart';
import 'stage_scale.dart';

/// Maps the 834×504 layout bounds onto the whole window.
///
/// Each axis is scaled on its own so the stage touches every edge. A uniform
/// contain-scale leaves empty bars; those bars are what the running pages
/// were showing as margins.
class BendingLightViewport extends StatelessWidget {
  const BendingLightViewport({
    super.key,
    required this.child,
    this.background = const Color(0xFFFFFFFF),
  });

  final Widget child;
  final Color background;

  static const double stageWidth = BendingLightConstants.layoutBoundsWidth;
  static const double stageHeight = BendingLightConstants.layoutBoundsHeight;

  static double scaleX(Size view) {
    if (view.width <= 0) return 1;
    return view.width / stageWidth;
  }

  static double scaleY(Size view) {
    if (view.height <= 0) return 1;
    return view.height / stageHeight;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final view = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : stageWidth,
          constraints.maxHeight.isFinite ? constraints.maxHeight : stageHeight,
        );
        final sx = scaleX(view);
        final sy = scaleY(view);
        final textScale = math.min(sx, sy);
        final mq = MediaQuery.of(context);
        return Semantics(
          label: '光的折射视口',
          container: true,
          child: SizedBox(
            width: view.width,
            height: view.height,
            child: ColoredBox(
              color: background,
              child: StageScale(
                scaleX: sx,
                scaleY: sy,
                child: MediaQuery(
                  data: mq.copyWith(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: SizedBox(
                    width: view.width,
                    height: view.height,
                    child: DefaultTextStyle(
                      style: PhetFont.of(12),
                      child: child,
                    ),
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
