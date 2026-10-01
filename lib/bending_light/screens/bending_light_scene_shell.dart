import 'package:flutter/material.dart';

import 'bending_light_viewport.dart';

/// Fills the parent. The 834×504 stage is stretched to every edge.
class BendingLightSceneShell extends StatelessWidget {
  const BendingLightSceneShell({
    super.key,
    required this.child,
    this.background = const Color(0xFFFFFFFF),
  });

  final Widget child;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: SizedBox.expand(
        child: BendingLightViewport(
          background: background,
          child: child,
        ),
      ),
    );
  }
}
