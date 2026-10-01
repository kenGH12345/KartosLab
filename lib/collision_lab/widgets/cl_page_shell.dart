import 'package:flutter/material.dart';

import '../collision_lab_constants.dart';

/// Fits a logical PhET 1024×618 ScreenView into the available cell.
class ClPageShell extends StatelessWidget {
  const ClPageShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: CollisionLabConstants.layoutWidth,
            height: CollisionLabConstants.layoutHeight,
            child: child,
          ),
        );
      },
    );
  }
}
