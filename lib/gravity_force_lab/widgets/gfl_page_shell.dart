import 'package:flutter/material.dart';

import '../model/gravity_force_constants.dart';

/// Fits PhET 768×464 ScreenView into the available cell (uniform contain).
///
/// Letterbox margins use the same white as the ScreenView so the result
/// matches PhET’s full-bleed look (no floating “postage stamp” frame).
class GflPageShell extends StatelessWidget {
  const GflPageShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Force fill viewport so FittedBox scales 768×464 into available space
    // (otherwise FittedBox shrink-wraps → top-left cluster + empty margins).
    return ColoredBox(
      color: GravityForceConstants.backgroundColor,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox(
            width: GravityForceConstants.layoutWidth,
            height: GravityForceConstants.layoutHeight,
            child: child,
          ),
        ),
      ),
    );
  }
}
