import 'package:flutter/material.dart';

import '../gflb_constants.dart';

/// Fits PhET 768×464 ScreenView into the available cell.
class GflbPageShell extends StatelessWidget {
  const GflbPageShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Same as Full [GflPageShell]: expand first or FittedBox shrink-wraps.
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox(
          width: GflbConstants.layoutWidth,
          height: GflbConstants.layoutHeight,
          child: child,
        ),
      ),
    );
  }
}
