import 'package:flutter/material.dart';

/// Scales [child] visually **and** in layout (unlike bare [Transform.scale]).
///
/// PhET Scenery `node.scale(s)` shrinks bounds; Flutter [Transform.scale] does
/// not — leaving empty accordion space equal to the unscaled size.
class BaaScaledBox extends StatelessWidget {
  const BaaScaledBox({
    super.key,
    required this.scale,
    required this.intrinsicWidth,
    required this.intrinsicHeight,
    required this.child,
    this.alignment = Alignment.topLeft,
  });

  final double scale;
  final double intrinsicWidth;
  final double intrinsicHeight;
  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final s = scale.clamp(0.01, 10.0);
    return SizedBox(
      width: intrinsicWidth * s,
      height: intrinsicHeight * s,
      child: Transform.scale(
        scale: s,
        alignment: alignment,
        child: OverflowBox(
          alignment: alignment,
          minWidth: intrinsicWidth,
          maxWidth: intrinsicWidth,
          minHeight: intrinsicHeight,
          maxHeight: intrinsicHeight,
          child: SizedBox(
            width: intrinsicWidth,
            height: intrinsicHeight,
            child: child,
          ),
        ),
      ),
    );
  }
}
