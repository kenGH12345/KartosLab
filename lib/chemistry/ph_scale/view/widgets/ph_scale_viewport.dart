import 'package:flutter/material.dart';

import '../../model/ph_scale_constants.dart';

/// Shared 1100×700 PhET layoutBounds viewport — fills the parent body (平铺).
///
/// Uses [BoxFit.fill] so Macro / Micro / My Solution always cover the Tab body
/// with no letterboxing. Aspect stretch is acceptable (same pattern as SoM shell).
class PhScaleViewport extends StatelessWidget {
  const PhScaleViewport({
    super.key,
    required this.child,
    this.layoutKey,
  });

  final Widget child;
  final Key? layoutKey;

  static Size get layoutSize => PhScaleConstants.layoutBounds;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.fill,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              key: layoutKey,
              width: layoutSize.width,
              height: layoutSize.height,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
