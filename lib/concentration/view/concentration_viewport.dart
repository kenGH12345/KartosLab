import 'package:flutter/material.dart';

import 'concentration_layout.dart';

/// 1100×700 PhET layoutBounds viewport (identity MVT).
class ConcentrationViewport extends StatelessWidget {
  const ConcentrationViewport({
    super.key,
    required this.child,
    this.layoutKey,
  });

  final Widget child;
  final Key? layoutKey;

  static Size get layoutSize => ConcentrationLayout.layoutBounds;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ConcentrationLayout.screenBackground,
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
