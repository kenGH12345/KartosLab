import 'package:flutter/material.dart';

import 'beers_law_layout.dart';

/// 1100×700 PhET layoutBounds viewport (Beer's Law MVT applied inside child).
class BeersLawViewport extends StatelessWidget {
  const BeersLawViewport({super.key, required this.child, this.layoutKey});

  final Widget child;
  final Key? layoutKey;

  static Size get layoutSize => BeersLawLayout.layoutBounds;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BeersLawLayout.screenBackground,
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
