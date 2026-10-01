import 'package:flutter/material.dart';

import '../ba_shared_constants.dart';

/// Fixed PhET layoutBounds viewport: 768 × 504.
class BaViewport extends StatelessWidget {
  const BaViewport({super.key, required this.child, this.layoutKey});

  final Widget child;
  final Key? layoutKey;

  static Size get layoutSize => const Size(
        BaSharedConstants.layoutWidth,
        BaSharedConstants.layoutHeight,
      );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.contain,
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
